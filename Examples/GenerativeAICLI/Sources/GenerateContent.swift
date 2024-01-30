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
        safetySettings: safetySettings
      )

      var input = [ModelContent]()
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

      input.append(ModelContent(parts: parts))
//      content.append(ModelContent(
//        role: "model",
//        parts: ModelContent.Part.functionCall(name: "sum", args: ["x": 3, "y": 5])
//      ))
//      content.append(ModelContent(
//        role: "function",
//        parts: ModelContent.Part.functionResponse(name: "sum", response: ["sum": 8])
//      ))
//      content.append(ModelContent(
//        role: "model",
//        parts: ModelContent.Part.functionCall(name: "sum", args: ["x": 8, "y": 7])
//      ))
//      content.append(ModelContent(
//        role: "function",
//        parts: ModelContent.Part.functionResponse(name: "sum", response: ["sum": 15])
//      ))

      let xParam = Schema(
        type: .integer,
        format: "int64",
        description: "The first number.",
        nullable: nil,
        enumValues: nil,
        properties: nil,
        required: nil
      )
      let yParam = Schema(
        type: .integer,
        format: "int64",
        description: "The second number.",
        nullable: nil,
        enumValues: nil,
        properties: nil,
        required: nil
      )
      let parameters = Schema(
        type: .object,
        format: nil,
        description: "Returns the sum of `x` and `y`.",
        nullable: nil,
        enumValues: nil,
        properties: ["x": xParam, "y": yParam],
        required: nil
      )
      let functionDeclaration = FunctionDeclaration(
        name: "sum",
        description: "Returns the sum of `x` and `y`.",
        parameters: parameters
      )
      let tool = Tool(functionDeclarations: [functionDeclaration])

      while true {
        let content = try await model.generateContent(input, tools: [tool])
        guard let candidate = content.candidates.first else {
          print("Response had no candidates.")
          return
        }
        guard let part = candidate.content.parts.first else {
          print("Candidate had no parts.")
          return
        }
        switch part {
        case let .text(text):
          print("Text: \(text)")
          return
        case let .data(mimetype: mimetype, _):
          print("Data with mimetype: \(mimetype)")
        case let .functionCall(name: name, args: args):
          print("Function call \"\(name)\" with args: \(args)")
          input.append(ModelContent(
            role: "model",
            parts: ModelContent.Part.functionCall(name: name, args: args)
          ))
          if name == "sum" {
            guard let x = args["x"], let y = args["y"] else {
              print("Expected x and y arguments in 'sum' function call, found \(args).")
              return
            }
            input.append(ModelContent(
              role: "function",
              parts: ModelContent.Part.functionResponse(name: "sum", response: ["sum": x + y])
            ))
          } else {
            print("Unknown function named \(name).")
            return
          }
        case let .functionResponse(name: name, response: response):
          print("Function response \"\(name)\" with value: \(response)")
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
      return "gemini-pro-vision"
    } else {
      return "gemini-pro"
    }
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
