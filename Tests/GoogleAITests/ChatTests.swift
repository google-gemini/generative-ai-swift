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

import Foundation
@testable import GoogleGenerativeAI
import XCTest

@available(iOS 15.0, tvOS 15.0, *)
final class ChatTests: XCTestCase {
  var urlSession: URLSession!

  override func setUp() {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    urlSession = URLSession(configuration: configuration)
  }

  override func tearDown() {
    MockURLProtocol.requestHandler = nil
  }

  func testMergingText() async throws {
    let fileURL = try XCTUnwrap(Bundle.module.url(
      forResource: "ExampleStreamingResponse",
      withExtension: "json"
    ))

    MockURLProtocol.requestHandler = { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, fileURL.lines)
    }

    let model = GenerativeModel(name: "my-model", apiKey: "API_KEY", urlSession: urlSession)
    let chat = Chat(model: model, history: [])
    let input = "Test input"
    let stream = chat.sendMessageStream(input)

    // Ensure the values are parsed correctly
    for try await value in stream {
      XCTAssertNotNil(value.text)
    }

    XCTAssertEqual(chat.history.count, 2)
    XCTAssertEqual(chat.history[0].parts[0].text, input)

    let finalText = """
     As an AI language model, I am designed to help you with a wide range of topics and \
    questions. Here are some examples of the types of questions you can ask me:
    - **General knowledge:** Ask me about a variety of topics, including history, science, \
    technology, art, culture, and more.
    - **Creative writing:** Request me to write a story, poem, or any other creative piece \
    based on your specifications.
    - **Language translation:** I can translate text from one language to another.
    - **Math problems:** I can solve math equations and provide step-by-step solutions.
    - **Trivia and quizzes:** Test your knowledge by asking me trivia questions or creating \
    quizzes on various subjects.
    - **Conversation:** Engage in casual conversation on any topic of your interest.
    - **Advice and suggestions:** Seek advice on various matters, such as relationships, \
    career choices, or personal growth.
    - **Entertainment:** Request jokes, riddles, or fun facts to lighten up your day.
    - **Code generation:** Ask me to write code snippets in different programming languages.
    - **Real-time information:** Inquire about current events, weather conditions, or other \
    up-to-date information.
    - **Creative ideas:** Generate creative ideas for projects, hobbies, or any other endeavor.
    - **Health and wellness:** Get information about health, fitness, and nutrition.
    - **Travel and geography:** Ask about places, landmarks, cultures, and travel tips.

    Remember that my responses are based on the information available to me up until my \
    training cutoff date in September 2021. For the most up-to-date information, especially \
    on rapidly changing topics, it's always a good idea to consult reliable and recent sources.
    """
    let assembledExpectation = ModelContent(role: "model", parts: finalText)
    XCTAssertEqual(chat.history[0].parts[0].text, input)
    XCTAssertEqual(chat.history[1], assembledExpectation)
  }
}
