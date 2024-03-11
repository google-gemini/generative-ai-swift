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
            parameters: getExchangeRateSchema(),
            function: getExchangeRateWrapper
          ),
        ])],
        requestOptions: RequestOptions(apiVersion: "v1beta")
      )

      let chat = model.startChat()

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

      let input = [ModelContent(parts: parts)]

      if isStreaming {
        let contentStream = chat.sendMessageStream(input)
        print("Generated Content <streaming>:")
        for try await content in contentStream {
          if let text = content.text {
            print(text)
          }
        }
      } else {
        // Unary generate content
        let content = try await chat.sendMessage(input)
        if let text = content.text {
          print("Generated Content:\n\(text)")
        }
      }
    } catch {
      print("Generate Content Error: \(error)")
    }
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

  // Returns exchange rates from the Frankfurter API
  // This is an example function that a developer might provide.
  func getExchangeRate(amount: Double, date: String, from: String,
                       to: String) async throws -> String {
    var urlComponents = URLComponents(string: "https://api.frankfurter.app")!
    urlComponents.path = "/\(date)"
    urlComponents.queryItems = [
      .init(name: "amount", value: String(amount)),
      .init(name: "from", value: from),
      .init(name: "to", value: to),
    ]

    let (data, _) = try await URLSession.shared.data(from: urlComponents.url!)
    return String(data: data, encoding: .utf8)!
  }

  // This is a wrapper for the `getExchangeRate` function.
  func getExchangeRateWrapper(args: JSONObject) async throws -> JSONObject {
    // 1. Validate and extract the parameters provided by the model (from a `FunctionCall`)
    guard case let .string(date) = args["currency_date"] else {
      fatalError()
    }
    guard case let .string(from) = args["currency_from"] else {
      fatalError()
    }
    guard case let .string(to) = args["currency_to"] else {
      fatalError()
    }
    guard case let .number(amount) = args["amount"] else {
      fatalError()
    }

    // 2. Call the wrapped function
    let response = try await getExchangeRate(amount: amount, date: date, from: from, to: to)

    // 3. Return the exchange rates as a JSON object (returned to the model in a `FunctionResponse`)
    return ["content": .string(response)]
  }

  // Returns the schema of the `getExchangeRate` function
  func getExchangeRateSchema() -> Schema {
    return Schema(
      type: .object,
      properties: [
        "currency_date": Schema(
          type: .string,
          description: """
          A date that must always be in YYYY-MM-DD format or the value 'latest' if a time period
          is not specified
          """
        ),
        "currency_from": Schema(
          type: .string,
          description: "The currency to convert from in ISO 4217 format"
        ),
        "currency_to": Schema(
          type: .string,
          description: "The currency to convert to in ISO 4217 format"
        ),
        "amount": Schema(
          type: .number,
          description: "The amount of currency to convert as a double value"
        ),
      ],
      required: ["currency_date", "currency_from", "currency_to", "amount"]
    )
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
