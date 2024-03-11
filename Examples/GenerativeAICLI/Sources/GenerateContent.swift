// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArgumentParser
import Foundation
import GoogleGenerativeAI

@main
struct GenerateContent: AsyncParsableCommand {
  @Option(help: "The API key to use when calling the Generative Language API.")
  var apiKey: String

  @Option(name: .customLong("model"), help: "The name of the model to use (e.g., \"gemini-pro\").")
  var modelName: String?

  @Option(help: "The text prompt for the model in natural language.")
  var textPrompt: String?

  @Option(
    name: .customLong("image-path"),
    help: "The file path of an image to pass to the model; must be in JPEG or PNG format.",
    transform: URL.filePath(_:)
  )
  var imageURL: URL?

  @Flag(
    name: .customLong("streaming"),
    help: "Stream response data, printing it incrementally as it's received."
  ) var isStreaming = false

  @Flag(
    name: .customLong("GoogleGenerativeAIDebugLogEnabled", withSingleDash: true),
    help: "Enable additional debug logging."
  ) var debugLogEnabled = false

  // Function calls pending processing
  var functionCalls = [FunctionCall]()

  // Input to the model
  var input = [ModelContent]()

  mutating func validate() throws {
    if textPrompt == nil && imageURL == nil {
      throw ValidationError(
        "Missing expected argument(s) '--text-prompt <text-prompt>' and/or" +
          " '--image-path <image-path>'."
      )
    }
  }

  mutating func run() async throws {
    do {
      let safetySettings = [SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone)]
      // Let the server pick the default config.
      let config = GenerationConfig(
        temperature: 0.2,
        topP: 0.1,
        topK: 16,
        candidateCount: 1,
        maxOutputTokens: isStreaming ? nil : 256,
        stopSequences: nil
      )

      let model = GenerativeModel(
        name: modelNameOrDefault(),
        apiKey: apiKey,
        generationConfig: config,
        safetySettings: safetySettings,
        tools: [Tool(functionDeclarations: [
          FunctionDeclaration(
            name: "get_exchange_rate",
            description: "Get the exchange rate for currencies between countries",
            parameters: Schema(
              type: .object,
              properties: [
                "currency_from": Schema(
                  type: .string,
                  format: "enum",
                  description: "The currency to convert from in ISO 4217 format",
                  enumValues: ["USD", "EUR", "JPY", "GBP", "AUD", "CAD"]
                ),
                "currency_to": Schema(
                  type: .string,
                  format: "enum",
                  description: "The currency to convert to in ISO 4217 format",
                  enumValues: ["USD", "EUR", "JPY", "GBP", "AUD", "CAD"]
                ),
              ],
              required: ["currency_from", "currency_to"]
            )
          ),
        ])],
        requestOptions: RequestOptions(apiVersion: "v1beta")
      )

      var parts = [ModelContent.Part]()

      if let textPrompt = textPrompt {
        parts.append(.text(textPrompt))
      }

      if let imageURL = imageURL {
        let mimeType: String
        switch imageURL.pathExtension {
        case "jpg", "jpeg":
          mimeType = "image/jpeg"
        case "png":
          mimeType = "image/png"
        default:
          throw CLIError.unsupportedImageType
        }
        let imageData = try Data(contentsOf: imageURL)
        parts.append(.data(mimetype: mimeType, imageData))
      }

      input = [ModelContent(parts: parts)]

      repeat {
        try await processFunctionCalls()

        if isStreaming {
          let contentStream = model.generateContentStream(input)
          print("Generated Content <streaming>:")
          for try await content in contentStream {
            processResponseContent(content: content)
          }
        } else {
          // Unary generate content
          let content = try await model.generateContent(input)
          print("Generated Content:")
          processResponseContent(content: content)
        }
      } while !functionCalls.isEmpty
    } catch {
      print("Generate Content Error: \(error)")
    }
  }

  mutating func processResponseContent(content: GenerateContentResponse) {
    guard let candidate = content.candidates.first else {
      fatalError("No candidate.")
    }

    for part in candidate.content.parts {
      switch part {
      case let .text(text):
        print(text)
      case .data:
        fatalError("Inline data not supported.")
      case let .functionCall(functionCall):
        functionCalls.append(functionCall)
      case let .functionResponse(functionResponse):
        print("FunctionResponse: \(functionResponse)")
      }
    }
  }

  mutating func processFunctionCalls() async throws {
    for functionCall in functionCalls {
      input.append(ModelContent(
        role: "model",
        parts: [ModelContent.Part.functionCall(functionCall)]
      ))
      switch functionCall.name {
      case "get_exchange_rate":
        let exchangeRates = getExchangeRate(args: functionCall.args)
        input.append(ModelContent(
          role: "function",
          parts: [ModelContent.Part.functionResponse(FunctionResponse(
            name: "get_exchange_rate",
            response: exchangeRates
          ))]
        ))
      default:
        fatalError("Unknown function named \"\(functionCall.name)\".")
      }
    }
    functionCalls = []
  }

  func modelNameOrDefault() -> String {
    if let modelName = modelName {
      return modelName
    } else if imageURL != nil {
      return "gemini-1.0-pro-vision-latest"
    } else {
      return "gemini-1.0-pro"
    }
  }

  // MARK: - Callable Functions

  func getExchangeRate(args: JSONObject) -> JSONObject {
    // 1. Validate and extract the parameters provided by the model (from a `FunctionCall`)
    guard case let .string(from) = args["currency_from"] else {
      fatalError("Missing `currency_from` parameter.")
    }
    guard case let .string(to) = args["currency_to"] else {
      fatalError("Missing `currency_to` parameter.")
    }

    // 2. Get the exchange rate
    let allRates: [String: [String: Double]] = [
      "AUD": ["CAD": 0.89265, "EUR": 0.6072, "GBP": 0.51714, "JPY": 97.75, "USD": 0.66379],
      "CAD": ["AUD": 1.1203, "EUR": 0.68023, "GBP": 0.57933, "JPY": 109.51, "USD": 0.74362],
      "EUR": ["AUD": 1.6469, "CAD": 1.4701, "GBP": 0.85168, "JPY": 160.99, "USD": 1.0932],
      "GBP": ["AUD": 1.9337, "CAD": 1.7261, "EUR": 1.1741, "JPY": 189.03, "USD": 1.2836],
      "JPY": ["AUD": 0.01023, "CAD": 0.00913, "EUR": 0.00621, "GBP": 0.00529, "USD": 0.00679],
      "USD": ["AUD": 1.5065, "CAD": 1.3448, "EUR": 0.91475, "GBP": 0.77907, "JPY": 147.26],
    ]
    guard let fromRates = allRates[from] else {
      return ["error": .string("No data for currency \(from).")]
    }
    guard let toRate = fromRates[to] else {
      return ["error": .string("No data for currency \(to).")]
    }

    // 3. Return the exchange rates as a JSON object (returned to the model in a `FunctionResponse`)
    return ["rates": .number(toRate)]
  }
}

enum CLIError: Error {
  case unsupportedImageType
}

private extension URL {
  static func filePath(_ filePath: String) throws -> URL {
    return URL(fileURLWithPath: filePath)
  }
}
