// Copyright 2024 Google LLC
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

import Foundation
import XCTest

@testable import GoogleGenerativeAI

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
final class GenerateContentRequestTests: XCTestCase {
  let encoder = JSONEncoder()
  let role = "test-role"
  let prompt = "test-prompt"
  let modelName = "test-model-name"

  override func setUp() {
    encoder.outputFormatting = .init(
      arrayLiteral: .prettyPrinted, .sortedKeys, .withoutEscapingSlashes
    )
  }

  // MARK: GenerateContentRequest Encoding

  func testEncodeRequest_allFieldsIncluded() throws {
    let content = [ModelContent(role: role, parts: prompt)]
    let request = GenerateContentRequest(
      model: modelName,
      contents: content,
      generationConfig: GenerationConfig(temperature: 0.5),
      safetySettings: [SafetySetting(
        harmCategory: .dangerousContent,
        threshold: .blockLowAndAbove
      )],
      tools: [Tool(functionDeclarations: [FunctionDeclaration(
        name: "test-function-name",
        description: "test-function-description",
        parameters: nil
      )])],
      toolConfig: ToolConfig(functionCallingConfig: FunctionCallingConfig(mode: .auto)),
      systemInstruction: ModelContent(role: "system", parts: "test-system-instruction"),
      isStreaming: false,
      options: RequestOptions()
    )

    let jsonData = try encoder.encode(request)

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, """
    {
      "contents" : [
        {
          "parts" : [
            {
              "text" : "\(prompt)"
            }
          ],
          "role" : "\(role)"
        }
      ],
      "generationConfig" : {
        "temperature" : 0.5
      },
      "model" : "\(modelName)",
      "safetySettings" : [
        {
          "category" : "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold" : "BLOCK_LOW_AND_ABOVE"
        }
      ],
      "systemInstruction" : {
        "parts" : [
          {
            "text" : "test-system-instruction"
          }
        ],
        "role" : "system"
      },
      "toolConfig" : {
        "functionCallingConfig" : {
          "mode" : "AUTO"
        }
      },
      "tools" : [
        {
          "functionDeclarations" : [
            {
              "description" : "test-function-description",
              "name" : "test-function-name",
              "parameters" : {
                "type" : "OBJECT"
              }
            }
          ]
        }
      ]
    }
    """)
  }

  func testEncodeRequest_optionalFieldsOmitted() throws {
    let content = [ModelContent(role: role, parts: prompt)]
    let request = GenerateContentRequest(
      model: modelName,
      contents: content,
      generationConfig: nil,
      safetySettings: nil,
      tools: nil,
      toolConfig: nil,
      systemInstruction: nil,
      isStreaming: false,
      options: RequestOptions()
    )

    let jsonData = try encoder.encode(request)

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, """
    {
      "contents" : [
        {
          "parts" : [
            {
              "text" : "\(prompt)"
            }
          ],
          "role" : "\(role)"
        }
      ],
      "model" : "\(modelName)"
    }
    """)
  }
}
