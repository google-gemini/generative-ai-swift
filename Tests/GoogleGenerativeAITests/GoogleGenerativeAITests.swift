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
  var client: GenerativeLanguage!
  /// Fetch the API key from `PaLM-Info.plist`
  private var apiKey: String {
    get {
      guard let fileURL = Bundle.module.url(forResource: "PaLM-Info", withExtension: "plist") else {
        fatalError("Couldn't find file 'PaLM-Info.plist'.")
      }
      let plist = NSDictionary(contentsOf: fileURL)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'PaLM-Info.plist'.")
      }
      if (value.starts(with: "_")) {
        fatalError("Follow the instructions at https://developers.generativeai.google/tutorials/setup to get a PaLM API key.")
      }
      return value
    }
  }
  
  override func setUp() {
    super.setUp()
    client = GenerativeLanguage(apiKey: apiKey)
    
    XCTAssertNotNil(client)
    XCTAssertEqual(client.apiKey, apiKey)
  }
  
  func testGenerateText() async throws {
    let model = "models/text-bison-001"
    
    let result = try await client.generateText(with: "Say something nice", model: model)
    print(result)
  }
  
  func testChat() async throws {
    let model = "models/chat-bison-001"
    
    let result = try await client.chat(message: "Say something nice", model: model)
    print(result)
  }
  
  func testGenerateEmbeddings() async throws {
    let model = "models/embedding-gecko-001"
    
    let result = try await client.generateEmbeddings(from: "Say something nice", model: model)
    print(result)
  }
  
  func testListModels() async throws {
    let result = try await client.listModels()
    print(result.models ?? [])
  }
  
  func testGetModel() async throws {
    let model = "chat-bison-001"
    
    let result = try await client.getModel(name: model)
    print(result.displayName ?? "")
  }
}
