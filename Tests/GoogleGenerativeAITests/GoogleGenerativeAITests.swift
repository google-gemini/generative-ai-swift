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

import XCTest
@testable import GoogleGenerativeAI

final class GenerativeLanguageTests: XCTestCase {
  let apiKey = "<INSERT-YOUR-API-KEY>"

  func testSetup() {
    let client = GenerativeLanguage(apiKey: apiKey)
    
    XCTAssertNotNil(client)
    XCTAssertEqual(client.apiKey, apiKey)
  }

  func testGenerateText() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)
    let model = "models/text-bison-001"

    let result = try await client.generateText(with: "Say something nice", model: model)
    print(result)
  }
    
  func testChat() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)
    let model = "models/chat-bison-001"
      
    let result = try await client.chat(message: "Say something nice", model: model)
    print(result)
  }

  func testListModels() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)

    let result = try await client.listModels()
    print(result.models ?? [])
  }

  func testGetModel() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)
    let model = "chat-bison-001"

    let result = try await client.getModel(name: model)
    print(result.displayName ?? [])
  }
}
