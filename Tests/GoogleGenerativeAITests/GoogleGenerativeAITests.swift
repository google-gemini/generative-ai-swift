import XCTest
@testable import GenerativeLanguage

final class GenerativeLanguageTests: XCTestCase {
  let apiKey = "<INSERT-YOUR-API-KEY>"
  
  func testSetup() {
    let client = GenerativeLanguage(apiKey: apiKey)

    XCTAssertNotNil(client)
    XCTAssertEqual(client.apiKey, apiKey)
  }

  func testGenerateMessage() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)
    let model = "models/chat-bison-001"

    let result = try await client.generateMessage(with: "Say something nice", model: model)
    print(result)
  }

  func testListModels() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)

    let result = try await client.listModels()
    print(result?.models)
  }

  func testGetModel() async throws {
    let client = GenerativeLanguage(apiKey: apiKey)
    let model = "chat-bison-001"

    let result = try await client.getModel(name: model)
    print(result?.displayName)
  }
}
