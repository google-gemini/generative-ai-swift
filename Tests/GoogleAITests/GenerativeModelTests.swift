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

@testable import GoogleGenerativeAI
import XCTest

@available(iOS 15.0, tvOS 15.0, *)
final class GenerativeModelTests: XCTestCase {
  let testPrompt = "What sorts of questions can I ask you?"
  let safetyRatingsNegligible: [SafetyRating] = [
    .init(category: .sexuallyExplicit, probability: .negligible),
    .init(category: .hateSpeech, probability: .negligible),
    .init(category: .harassment, probability: .negligible),
    .init(category: .dangerousContent, probability: .negligible),
  ]

  var urlSession: URLSession!
  var model: GenerativeModel!

  override func setUp() async throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockURLProtocol.self]
    urlSession = try XCTUnwrap(URLSession(configuration: configuration))
    model = GenerativeModel(name: "my-model", apiKey: "API_KEY", urlSession: urlSession)
  }

  override func tearDown() {
    MockURLProtocol.requestHandler = nil
  }

  // MARK: - Generate Content

  func testGenerateContent_success_basicReplyLong() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-long",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    let finishReason = try XCTUnwrap(candidate.finishReason)
    XCTAssertEqual(finishReason, .stop)
    XCTAssertEqual(candidate.safetyRatings, safetyRatingsNegligible)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    let partText = try XCTUnwrap(part.text)
    XCTAssertTrue(partText.hasPrefix("You can ask me a wide range of questions"))
    XCTAssertEqual(response.text, partText)
    let promptFeedback = try XCTUnwrap(response.promptFeedback)
    XCTAssertNil(promptFeedback.blockReason)
    XCTAssertEqual(promptFeedback.safetyRatings, safetyRatingsNegligible)
  }

  func testGenerateContent_success_basicReplyShort() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-short",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    let finishReason = try XCTUnwrap(candidate.finishReason)
    XCTAssertEqual(finishReason, .stop)
    XCTAssertEqual(candidate.safetyRatings, safetyRatingsNegligible)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    XCTAssertEqual(part.text, "Mountain View, California, United States")
    XCTAssertEqual(response.text, part.text)
    let promptFeedback = try XCTUnwrap(response.promptFeedback)
    XCTAssertNil(promptFeedback.blockReason)
    XCTAssertEqual(promptFeedback.safetyRatings, safetyRatingsNegligible)
  }

  func testGenerateContent_success_citations() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-citations",
        withExtension: "json"
      )

    let content = try await model.generateContent(testPrompt)

    XCTAssertNotNil(content.text)
    // TODO: Add assertions
  }

  func testGenerateContent_success_quoteReply() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-quote-reply",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    let finishReason = try XCTUnwrap(candidate.finishReason)
    XCTAssertEqual(finishReason, .stop)
    XCTAssertEqual(candidate.safetyRatings, safetyRatingsNegligible)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    let partText = try XCTUnwrap(part.text)
    XCTAssertTrue(partText.hasPrefix("Google"))
    XCTAssertEqual(response.text, part.text)
    let promptFeedback = try XCTUnwrap(response.promptFeedback)
    XCTAssertNil(promptFeedback.blockReason)
    XCTAssertEqual(promptFeedback.safetyRatings, safetyRatingsNegligible)
  }

  func testGenerateContent_success_unknownEnum() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-unknown-enum",
        withExtension: "json"
      )

    let content = try await model.generateContent(testPrompt)

    XCTAssertNotNil(content.text)
    // TODO: Add assertions
  }

  private func internalTestGenerateContent(resource: String,
                                           safetyRatingsCount: Int = 6) async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: resource,
      withExtension: "json"
    )

    let content = try await model.generateContent("What sorts of questions can I ask you?")

    // TODO: Add assertions for response content
    let promptFeedback = try XCTUnwrap(content.promptFeedback)
    XCTAssertEqual(promptFeedback.safetyRatings.count, safetyRatingsCount)
    XCTAssertNotNil(content.text)
  }

  func testGenerateContent_failure_invalidAPIKey() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-api-key",
        withExtension: "json",
        statusCode: 400
      )

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    XCTAssertNil(content)
    // TODO: Add assertions about `responseError`.
  }

  func testGenerateContent_failure_emptyContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-empty-content",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw GenerateContentError.internalError; no error thrown.")
    } catch let GenerateContentError.internalError(underlying: underlyingError) {
      guard case let .emptyContent(decodingError) =
        try XCTUnwrap(underlyingError as? InvalidCandidateError) else {
        XCTFail("Not an InvalidCandidateError.emptyContent error: \(underlyingError)")
        return
      }
      _ = try XCTUnwrap(decodingError as? DecodingError,
                        "Not a DecodingError: \(decodingError)")
    } catch {
      XCTFail("Should throw GenerateContentError.internalError; error thrown: \(error)")
    }
  }

  func testGenerateContent_failure_finishReasonSafety() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-finish-reason-safety",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw")
    } catch let GenerateContentError.responseStoppedEarly(reason, response) {
      XCTAssertEqual(reason, .safety)
      XCTAssertEqual(response.text, "No")
    } catch {
      XCTFail("Should throw a responseStoppedEarly")
    }
  }

  func testGenerateContent_failure_finishReasonSafety_noContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-finish-reason-safety-no-content",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw")
    } catch let GenerateContentError.responseStoppedEarly(reason, response) {
      XCTAssertEqual(reason, .safety)
      XCTAssertNil(response.text)
    } catch {
      XCTFail("Should throw a responseStoppedEarly")
    }
  }

  func testGenerateContent_failure_imageRejected() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-image-rejected",
        withExtension: "json",
        statusCode: 400
      )

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    XCTAssertNil(content)
    // TODO: Add assertions about `responseError`.
  }

  func testGenerateContent_failure_promptBlockedSafety() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-prompt-blocked-safety",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw")
    } catch let GenerateContentError.promptBlocked(response) {
      XCTAssertNil(response.text)
    } catch {
      XCTFail("Should throw a promptBlocked]")
    }
  }

  func testGenerateContent_failure_unknownModel() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unknown-model",
        withExtension: "json",
        statusCode: 404
      )

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    XCTAssertNil(content)
    // TODO: Add assertions about `responseError`.
  }

  func testGenerateContent_failure_nonHTTPResponse() async throws {
    MockURLProtocol.requestHandler = try nonHTTPRequestHandler()

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNil(content)
    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    XCTAssertEqual(underlyingError.localizedDescription, "Response was not an HTTP response.")
  }

  func testGenerateContent_failure_invalidResponse() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "unary-failure-invalid-response",
      withExtension: "json"
    )

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNil(content)
    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    let decodingError = try XCTUnwrap(underlyingError as? DecodingError)
    guard case let .dataCorrupted(context) = decodingError else {
      XCTFail("Not a data corrupted error: \(decodingError)")
      return
    }
    XCTAssert(context.debugDescription.hasPrefix("Failed to decode GenerateContentResponse"))
  }

  func testGenerateContent_failure_malformedContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-malformed-content",
        withExtension: "json"
      )

    var responseError: Error?
    var content: GenerateContentResponse?
    do {
      content = try await model.generateContent(testPrompt)
    } catch {
      responseError = error
    }

    XCTAssertNil(content)
    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    let invalidCandidateError = try XCTUnwrap(underlyingError as? InvalidCandidateError)
    guard case let .malformedContent(malformedContentUnderlyingError) = invalidCandidateError else {
      XCTFail("Not a malformed content error: \(invalidCandidateError)")
      return
    }
    _ = try XCTUnwrap(
      malformedContentUnderlyingError as? DecodingError,
      "Not a decoding error: \(malformedContentUnderlyingError)"
    )
  }

  func testGenerateContentMissingSafetyRatings() async throws {
    try await internalTestGenerateContent(resource: "MissingSafetyRatings", safetyRatingsCount: 0)
  }

  // MARK: - Generate Content (Streaming)

  func testGenerateContentStream_failureEmptyContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-empty-content",
        withExtension: "txt"
      )

    do {
      let stream = model.generateContentStream("Hi")
      for try await _ in stream {
        XCTFail("No content is there, this shouldn't happen.")
      }
    } catch {
      // TODO: Catch specific error.
      return
    }

    XCTFail("Should have caught an error.")
  }

  func testGenerateContentStream_failureFinishReasonSafety() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-finish-reason-safety",
        withExtension: "txt"
      )

    do {
      let stream = model.generateContentStream("Hi")
      for try await _ in stream {
        XCTFail("Content shouldn't be shown, this shouldn't happen.")
      }
    } catch let GenerateContentError.responseStoppedEarly(reason, _) {
      XCTAssertEqual(reason, .safety)
      return
    } catch {
      XCTFail("Wrong error generated: \(error)")
    }

    XCTFail("Should have caught an error.")
  }

  func testGenerateContentStream_failurePromptBlockedSafety() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-prompt-blocked-safety",
        withExtension: "txt"
      )

    do {
      let stream = model.generateContentStream("Hi")
      for try await _ in stream {
        XCTFail("Content shouldn't be shown, this shouldn't happen.")
      }
    } catch let GenerateContentError.promptBlocked(response) {
      XCTAssertEqual(response.promptFeedback?.blockReason, .safety)
      return
    }

    XCTFail("Should have caught an error.")
  }

  func testGenerateContentStream_failureUnknownFinishEnum() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-unknown-finish-enum",
        withExtension: "txt"
      )

    let stream = model.generateContentStream("Hi")
    do {
      for try await content in stream {
        XCTAssertNotNil(content.text)
      }
    } catch let GenerateContentError.responseStoppedEarly(reason, _) {
      XCTAssertEqual(reason, .unknown)
      return
    }

    XCTFail("Should have caught an error.")
  }

  func testGenerateContentStream_successBasicReplyLong() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-basic-reply-long",
        withExtension: "txt"
      )

    var responses = 0
    let stream = model.generateContentStream("Hi")
    for try await content in stream {
      XCTAssertNotNil(content.text)
      responses += 1
    }

    XCTAssertEqual(responses, 6)
  }

  func testGenerateContentStream_successBasicReplyShort() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-basic-reply-short",
        withExtension: "txt"
      )

    var responses = 0
    let stream = model.generateContentStream("Hi")
    for try await content in stream {
      XCTAssertNotNil(content.text)
      responses += 1
    }

    XCTAssertEqual(responses, 1)
  }

  func testGenerateContentStream_successUnknownSafetyEnum() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-unknown-safety-enum",
        withExtension: "txt"
      )

    var hadUnknown = false
    let stream = model.generateContentStream("Hi")
    for try await content in stream {
      XCTAssertNotNil(content.text)
      if let ratings = content.candidates.first?.safetyRatings,
         ratings.contains(where: { $0.category == .unknown }) {
        hadUnknown = true
      }
    }

    XCTAssertTrue(hadUnknown)
  }

  func testGenerateContentStream_successWithCitations() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-citations",
        withExtension: "txt"
      )

    let stream = model.generateContentStream("Can you explain quantum physics?")
    var citations: [Citation] = []
    for try await content in stream {
      XCTAssertNotNil(content.text)
      let candidate = try XCTUnwrap(content.candidates.first)
      XCTAssertEqual(candidate.finishReason, .stop)
      if let sources = candidate.citationMetadata?.citationSources {
        citations.append(contentsOf: sources)
      }
    }

    XCTAssertEqual(citations.count, 8)
    XCTAssertTrue(citations
      .contains(where: { $0.startIndex == 574 && $0.endIndex == 705 && !$0.uri.isEmpty }))
    XCTAssertTrue(citations
      .contains(where: { $0.startIndex == 899 && $0.endIndex == 1026 && !$0.uri.isEmpty }))
  }

  func testGenerateContentStream_errorMidStream() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "ExampleErrorMidStream",
      withExtension: "json"
    )

    let stream = model.generateContentStream("What sorts of questions can I ask you?")

    var textResponses = [String]()
    var errorResponse: Error?
    do {
      for try await content in stream {
        XCTAssertNotNil(content.text)
        let text = try XCTUnwrap(content.text)
        textResponses.append(text)
      }
    } catch {
      errorResponse = error
    }

    // TODO: Add assertions for response content
    XCTAssertEqual(textResponses.count, 2)
    XCTAssertNotNil(errorResponse)
  }

  func testGenerateContentStream_nonHTTPResponse() async throws {
    MockURLProtocol.requestHandler = try nonHTTPRequestHandler()

    let stream = model.generateContentStream("What sorts of questions can I ask you?")
    var responseError: Error?
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    XCTAssertEqual(underlyingError.localizedDescription, "Response was not an HTTP response.")
  }

  func testGenerateContentStream_invalidResponse() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "InvalidStreamingResponse",
        withExtension: "json"
      )

    let stream = model.generateContentStream(testPrompt)
    var responseError: Error?
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    let decodingError = try XCTUnwrap(underlyingError as? DecodingError)
    guard case let .dataCorrupted(context) = decodingError else {
      XCTFail("Not a data corrupted error: \(decodingError)")
      return
    }
    XCTAssert(context.debugDescription.hasPrefix("Failed to decode GenerateContentResponse"))
  }

  func testGenerateContentStream_emptyContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "EmptyContentStreamingResponse",
        withExtension: "json"
      )

    let stream = model.generateContentStream(testPrompt)
    var responseError: Error?
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    let invalidCandidateError = try XCTUnwrap(underlyingError as? InvalidCandidateError)
    guard case let .emptyContent(emptyContentUnderlyingError) = invalidCandidateError else {
      XCTFail("Not an empty content error: \(invalidCandidateError)")
      return
    }
    _ = try XCTUnwrap(
      emptyContentUnderlyingError as? DecodingError,
      "Not a decoding error: \(emptyContentUnderlyingError)"
    )
  }

  func testGenerateContentStream_malformedContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "MalformedContentStreamingResponse",
        withExtension: "json"
      )

    let stream = model.generateContentStream(testPrompt)
    var responseError: Error?
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch {
      responseError = error
    }

    XCTAssertNotNil(responseError)
    let generateContentError = try XCTUnwrap(responseError as? GenerateContentError)
    guard case let .internalError(underlyingError) = generateContentError else {
      XCTFail("Not an internal error: \(generateContentError)")
      return
    }
    let invalidCandidateError = try XCTUnwrap(underlyingError as? InvalidCandidateError)
    guard case let .malformedContent(malformedContentUnderlyingError) = invalidCandidateError else {
      XCTFail("Not a malformed content error: \(invalidCandidateError)")
      return
    }
    _ = try XCTUnwrap(
      malformedContentUnderlyingError as? DecodingError,
      "Not a decoding error: \(malformedContentUnderlyingError)"
    )
  }

  // MARK: - Count Tokens

  func testCountTokens_succeeds() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "CountTokensResponse",
      withExtension: "json"
    )

    let response = try await model.countTokens("Why is the sky blue?")

    XCTAssertEqual(response.totalTokens, 6)
  }

  func testCountTokens_modelNotFound() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "CountTokensModelNotFound", withExtension: "json",
      statusCode: 404
    )

    var response: CountTokensResponse?
    var responseError: Error?
    do {
      response = try await model.countTokens("Why is the sky blue?")
    } catch {
      responseError = error
    }

    XCTAssertNil(response)
    XCTAssertNotNil(responseError)
    let countTokensError = try XCTUnwrap(responseError as? CountTokensError)
    guard case let .internalError(underlyingError) = countTokensError else {
      XCTFail("Not an internal error: \(countTokensError)")
      return
    }
    let rpcError = try XCTUnwrap(underlyingError as? RPCError)
    XCTAssertEqual(rpcError.httpResponseCode, 404)
    XCTAssertEqual(rpcError.status, .notFound)
    XCTAssert(rpcError.message.hasPrefix("models/test-model-name is not found"))
  }

  // MARK: - Helpers

  private func nonHTTPRequestHandler() throws -> ((URLRequest) -> (
    URLResponse,
    AsyncLineSequence<URL.AsyncBytes>?
  )) {
    return { request in
      // This is *not* an HTTPURLResponse
      let response = URLResponse(
        url: request.url!,
        mimeType: nil,
        expectedContentLength: 0,
        textEncodingName: nil
      )
      return (response, nil)
    }
  }

  private func httpRequestHandler(forResource name: String,
                                  withExtension ext: String,
                                  statusCode: Int = 200) throws -> ((URLRequest) -> (
    URLResponse,
    AsyncLineSequence<URL.AsyncBytes>?
  )) {
    let fileURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: ext))
    return { request in
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
      return (response, fileURL.lines)
    }
  }
}
