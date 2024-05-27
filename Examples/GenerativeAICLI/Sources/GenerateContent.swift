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

// TODO(andrewheard): Revert the changes in this file after manual testing.

struct CartoonCharacter: Decodable {
  let firstName: String
  let lastName: String
  let occupation: String
  let children: [ChildCartoonCharacter]
  let birthYear: Int
}

struct ChildCartoonCharacter: Decodable {
  let firstName: String
  let lastName: String
}

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
    let responseSchema = Schema(
      type: .array,
      description: "List of characters.",
      items: Schema(
        type: .object,
        description: "Details about a character.",
        properties: [
          "firstName": Schema(type: .string, description: "The character's first name."),
          "lastName": Schema(type: .string, description: "The character's last name."),
          "occupation": Schema(type: .string, description: "The character's occupation."),
          "children": Schema(
            type: .array,
            description: "A list of the character's children ordered from oldest to youngest.",
            items: Schema(
              type: .object,
              description: "Details about a child character.",
              properties: [
                "firstName": Schema(type: .string,
                                    description: "The child character's first name."),
                "lastName": Schema(type: .string, description: "The child character's last name."),
              ],
              requiredProperties: ["firstName", "lastName"]
            )
          ),
          "birthYear": Schema(type: .integer, format: "int32",
                              description: "The character's birth year."),
        ],
        requiredProperties: ["firstName", "lastName", "occupation", "children", "birthYear"]
      )
    )
    let generationConfig = GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: responseSchema
    )

    do {
      let model = GenerativeModel(
        name: modelNameOrDefault(),
        apiKey: apiKey,
        generationConfig: generationConfig
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

      let input = [ModelContent(parts: parts)]

      var generatedText = ""
      if isStreaming {
        let contentStream = model.generateContentStream(input)
        print("Generated Content <streaming>:")
        for try await content in contentStream {
          guard let text = content.text else {
            fatalError("No text generated.")
          }
          generatedText += text
        }
      } else {
        let content = try await model.generateContent(input)
        guard let text = content.text else {
          fatalError("No text generated.")
        }
        generatedText += text
      }

      guard let jsonData = generatedText.data(using: .utf8) else {
        fatalError("Generated text is not UTF-8 compatible.")
      }

      let jsonDecoder = JSONDecoder()
      let cartoonCharacters = try jsonDecoder.decode([CartoonCharacter].self, from: jsonData)
      for cartoonCharacter in cartoonCharacters {
        print(cartoonCharacter)
      }
    } catch {
      print("Generate Content Error: \(error)")
    }
  }

  func modelNameOrDefault() -> String {
    if let modelName {
      return modelName
    } else {
      return "gemini-1.5-flash-latest"
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
