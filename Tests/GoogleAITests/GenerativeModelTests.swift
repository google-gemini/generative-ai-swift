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

@available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *)
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
    XCTAssertEqual(response.functionCalls, [])
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
    XCTAssertEqual(part.text, "Mountain View, California")
    XCTAssertEqual(response.text, part.text)
    XCTAssertNil(response.promptFeedback)
    XCTAssertEqual(response.functionCalls, [])
  }

  func testGenerateContent_success_citations() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-citations",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 1)
    XCTAssertEqual(response.text, "Some information cited from an external source")
    let citationMetadata = try XCTUnwrap(candidate.citationMetadata)
    XCTAssertEqual(citationMetadata.citationSources.count, 4)
    let citationSource1 = try XCTUnwrap(citationMetadata.citationSources[0])
    XCTAssertEqual(citationSource1.uri, "https://www.example.com/some-citation-1")
    XCTAssertEqual(citationSource1.startIndex, 0)
    XCTAssertEqual(citationSource1.endIndex, 128)
    XCTAssertNil(citationSource1.license)
    let citationSource2 = try XCTUnwrap(citationMetadata.citationSources[1])
    XCTAssertEqual(citationSource2.uri, "https://www.example.com/some-citation-2")
    XCTAssertEqual(citationSource2.startIndex, 130)
    XCTAssertEqual(citationSource2.endIndex, 265)
    XCTAssertNil(citationSource2.license)
    let citationSource3 = try XCTUnwrap(citationMetadata.citationSources[2])
    XCTAssertEqual(citationSource3.uri, "https://www.example.com/some-citation-3")
    XCTAssertEqual(citationSource3.startIndex, 272)
    XCTAssertEqual(citationSource3.endIndex, 431)
    XCTAssertNil(citationSource3.license)
    let citationSource4 = try XCTUnwrap(citationMetadata.citationSources[3])
    XCTAssertEqual(citationSource4.uri, "https://www.example.com/some-citation-4")
    XCTAssertEqual(citationSource4.startIndex, 444)
    XCTAssertEqual(citationSource4.endIndex, 630)
    XCTAssertEqual(citationSource4.license, "mit")
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

  func testGenerateContent_success_unknownEnum_safetyRatings() async throws {
    let expectedSafetyRatings = [
      SafetyRating(category: .harassment, probability: .medium),
      SafetyRating(category: .dangerousContent, probability: .unknown),
      SafetyRating(category: .unknown, probability: .high),
    ]
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-unknown-enum-safety-ratings",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.text, "Some text")
    XCTAssertEqual(response.candidates.first?.safetyRatings, expectedSafetyRatings)
    XCTAssertEqual(response.promptFeedback?.safetyRatings, expectedSafetyRatings)
  }

  func testGenerateContent_success_prefixedModelName() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-short",
        withExtension: "json"
      )
    let model = GenerativeModel(
      // Model name is prefixed with "models/".
      name: "models/test-model",
      apiKey: "API_KEY",
      urlSession: urlSession
    )

    _ = try await model.generateContent(testPrompt)
  }

  func testGenerateContent_success_functionCall_emptyArguments() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-function-call-empty-arguments",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    guard case let .functionCall(functionCall) = part else {
      XCTFail("Part is not a FunctionCall.")
      return
    }
    XCTAssertEqual(functionCall.name, "current_time")
    XCTAssertTrue(functionCall.args.isEmpty)
    XCTAssertEqual(response.functionCalls, [functionCall])
  }

  func testGenerateContent_success_functionCall_noArguments() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-function-call-no-arguments",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    guard case let .functionCall(functionCall) = part else {
      XCTFail("Part is not a FunctionCall.")
      return
    }
    XCTAssertEqual(functionCall.name, "current_time")
    XCTAssertTrue(functionCall.args.isEmpty)
    XCTAssertEqual(response.functionCalls, [functionCall])
  }

  func testGenerateContent_success_functionCall_withArguments() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-function-call-with-arguments",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 1)
    let part = try XCTUnwrap(candidate.content.parts.first)
    guard case let .functionCall(functionCall) = part else {
      XCTFail("Part is not a FunctionCall.")
      return
    }
    XCTAssertEqual(functionCall.name, "sum")
    XCTAssertEqual(functionCall.args.count, 2)
    let argX = try XCTUnwrap(functionCall.args["x"])
    XCTAssertEqual(argX, .number(4))
    let argY = try XCTUnwrap(functionCall.args["y"])
    XCTAssertEqual(argY, .number(5))
    XCTAssertEqual(response.functionCalls, [functionCall])
  }

  func testGenerateContent_success_functionCall_parallelCalls() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-function-call-parallel-calls",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 3)
    let functionCalls = response.functionCalls
    XCTAssertEqual(functionCalls.count, 3)
  }

  func testGenerateContent_success_functionCall_mixedContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-function-call-mixed-content",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 4)
    let functionCalls = response.functionCalls
    XCTAssertEqual(functionCalls.count, 2)
    let text = try XCTUnwrap(response.text)
    XCTAssertEqual(text, "The sum of [1, 2,\n3] is")
  }

  func testGenerateContent_success_codeExecution() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-code-execution",
        withExtension: "json"
      )
    let expectedText1 = """
    To print strings in Python, you use the `print()` function. \
    Here's how you can print \"Hello, world!\":\n\n
    """
    let expectedText2 = "The code successfully prints the string \"Hello, world!\". \n"
    let expectedLanguage = "PYTHON"
    let expectedCode = "\nprint(\"Hello, world!\")\n"
    let expectedOutput = "Hello, world!\n"

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
    let candidate = try XCTUnwrap(response.candidates.first)
    XCTAssertEqual(candidate.content.parts.count, 4)
    guard case let .text(text1) = candidate.content.parts[0] else {
      XCTFail("Expected first part to be text.")
      return
    }
    XCTAssertEqual(text1, expectedText1)
    guard case let .executableCode(executableCode) = candidate.content.parts[1] else {
      XCTFail("Expected second part to be executable code.")
      return
    }
    XCTAssertEqual(executableCode.language, expectedLanguage)
    XCTAssertEqual(executableCode.code, expectedCode)
    guard case let .codeExecutionResult(codeExecutionResult) = candidate.content.parts[2] else {
      XCTFail("Expected second part to be a code execution result.")
      return
    }
    XCTAssertEqual(codeExecutionResult.outcome, .ok)
    XCTAssertEqual(codeExecutionResult.output, expectedOutput)
    guard case let .text(text2) = candidate.content.parts[3] else {
      XCTFail("Expected fourth part to be text.")
      return
    }
    XCTAssertEqual(text2, expectedText2)
    XCTAssertEqual(try XCTUnwrap(response.text), """
    \(expectedText1)
    ```\(expectedLanguage.lowercased())
    \(expectedCode)
    ```
    ```
    \(expectedOutput)
    ```
    \(expectedText2)
    """)
  }

  func testGenerateContent_usageMetadata() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-short",
        withExtension: "json"
      )

    let response = try await model.generateContent(testPrompt)

    let usageMetadata = try XCTUnwrap(response.usageMetadata)
    // TODO(andrewheard): Re-run prompt when `promptTokenCount` and `totalTokenCount` added.
    XCTAssertEqual(usageMetadata.promptTokenCount, 0)
    XCTAssertEqual(usageMetadata.candidatesTokenCount, 4)
    XCTAssertEqual(usageMetadata.totalTokenCount, 0)
  }

  func testGenerateContent_failure_invalidAPIKey() async throws {
    let expectedStatusCode = 400
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-api-key",
        withExtension: "json",
        statusCode: expectedStatusCode
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw GenerateContentError.internalError; no error thrown.")
    } catch let GenerateContentError.invalidAPIKey(message) {
      XCTAssertEqual(message, "API key not valid. Please pass a valid API key.")
    } catch {
      XCTFail("Should throw GenerateContentError.invalidAPIKey; error thrown: \(error)")
    }
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
    } catch let GenerateContentError
      .internalError(underlying: invalidCandidateError as InvalidCandidateError) {
      guard case let .emptyContent(decodingError) = invalidCandidateError else {
        XCTFail("Not an InvalidCandidateError.emptyContent error: \(invalidCandidateError)")
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
    let expectedStatusCode = 400
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-image-rejected",
        withExtension: "json",
        statusCode: 400
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw GenerateContentError.internalError; no error thrown.")
    } catch let GenerateContentError.internalError(underlying: rpcError as RPCError) {
      XCTAssertEqual(rpcError.status, .invalidArgument)
      XCTAssertEqual(rpcError.httpResponseCode, expectedStatusCode)
      XCTAssertEqual(rpcError.message, "Request contains an invalid argument.")
    } catch {
      XCTFail("Should throw GenerateContentError.internalError; error thrown: \(error)")
    }
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
      XCTFail("Should throw a promptBlocked")
    }
  }

  func testGenerateContent_failure_unknownEnum_finishReason() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unknown-enum-finish-reason",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw")
    } catch let GenerateContentError.responseStoppedEarly(reason, response) {
      XCTAssertEqual(reason, .unknown)
      XCTAssertEqual(response.text, "Some text")
    } catch {
      XCTFail("Should throw a responseStoppedEarly")
    }
  }

  func testGenerateContent_failure_unknownEnum_promptBlocked() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unknown-enum-prompt-blocked",
        withExtension: "json"
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw")
    } catch let GenerateContentError.promptBlocked(response) {
      let promptFeedback = try XCTUnwrap(response.promptFeedback)
      XCTAssertEqual(promptFeedback.blockReason, .unknown)
    } catch {
      XCTFail("Should throw a promptBlocked")
    }
  }

  func testGenerateContent_failure_unknownModel() async throws {
    let expectedStatusCode = 404
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unknown-model",
        withExtension: "json",
        statusCode: 404
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw GenerateContentError.internalError; no error thrown.")
    } catch let GenerateContentError.internalError(underlying: rpcError as RPCError) {
      XCTAssertEqual(rpcError.status, .notFound)
      XCTAssertEqual(rpcError.httpResponseCode, expectedStatusCode)
      XCTAssertTrue(rpcError.message.hasPrefix("models/unknown is not found"))
    } catch {
      XCTFail("Should throw GenerateContentError.internalError; error thrown: \(error)")
    }
  }

  func testGenerateContent_failure_unsupportedUserLocation() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unsupported-user-location",
        withExtension: "json",
        statusCode: 400
      )

    do {
      _ = try await model.generateContent(testPrompt)
      XCTFail("Should throw GenerateContentError.unsupportedUserLocation; no error thrown.")
    } catch GenerateContentError.unsupportedUserLocation {
      return
    }

    XCTFail("Expected an unsupported user location error.")
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
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "unary-success-missing-safety-ratings",
      withExtension: "json"
    )

    let content = try await model.generateContent(testPrompt)
    let promptFeedback = try XCTUnwrap(content.promptFeedback)
    XCTAssertEqual(promptFeedback.safetyRatings.count, 0)
    XCTAssertEqual(content.text, "This is the generated content.")
  }

  func testGenerateContent_requestOptions_customTimeout() async throws {
    let expectedTimeout = 150.0
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-short",
        withExtension: "json",
        timeout: expectedTimeout
      )
    let requestOptions = RequestOptions(timeout: expectedTimeout)
    model = GenerativeModel(
      name: "my-model",
      apiKey: "API_KEY",
      requestOptions: requestOptions,
      urlSession: urlSession
    )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
  }

  func testGenerateContent_requestOptions_defaultTimeout() async throws {
    let expectedTimeout = 300.0 // Default in timeout in RequestOptions()
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-success-basic-reply-short",
        withExtension: "json",
        timeout: expectedTimeout
      )

    let response = try await model.generateContent(testPrompt)

    XCTAssertEqual(response.candidates.count, 1)
  }

  // MARK: - Generate Content (Streaming)

  func testGenerateContentStream_failureInvalidAPIKey() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-api-key",
        withExtension: "json"
      )

    do {
      let stream = model.generateContentStream("Hi")
      for try await _ in stream {
        XCTFail("No content is there, this shouldn't happen.")
      }
    } catch GenerateContentError.invalidAPIKey {
      // invalidAPIKey error is as expected, nothing else to check.
      return
    }

    XCTFail("Should have caught an error.")
  }

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
    } catch GenerateContentError.internalError(_ as InvalidCandidateError) {
      // Underlying error is as expected, nothing else to check.
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

    XCTAssertEqual(responses, 10)
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

    let stream = model.generateContentStream("Hi")
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
      .contains(where: {
        $0.startIndex == 0 && $0.endIndex == 128 && !$0.uri.isEmpty && $0.license == nil
      }))
    XCTAssertTrue(citations
      .contains(where: {
        $0.startIndex == 130 && $0.endIndex == 265 && !$0.uri.isEmpty && $0.license == nil
      }))
    XCTAssertTrue(citations
      .contains(where: {
        $0.startIndex == 272 && $0.endIndex == 431 && !$0.uri.isEmpty && $0.license == nil
      }))
    XCTAssertTrue(citations
      .contains(where: {
        $0.startIndex == 444 && $0.endIndex == 630 && !$0.uri.isEmpty && $0.license == "mit"
      }))
  }

  func testGenerateContentStream_success_codeExecution() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-code-execution",
        withExtension: "txt"
      )
    let expectedTexts1 = [
      "Thoughts",
      ": I can use the `print()` function in Python to print strings. ",
      "\n\n",
    ]
    let expectedTexts2 = [
      "OK",
      ". I have printed \"Hello, world!\" using the `print()` function in",
      " Python. \n",
    ]
    let expectedTexts = Set(expectedTexts1 + expectedTexts2)
    let expectedLanguage = "PYTHON"
    let expectedCode = "\nprint(\"Hello, world!\")\n"
    let expectedOutput = "Hello, world!\n"

    var textValues = [String]()
    let stream = model.generateContentStream(testPrompt)
    for try await content in stream {
      let candidate = try XCTUnwrap(content.candidates.first)
      let part = try XCTUnwrap(candidate.content.parts.first)
      switch part {
      case let .text(textPart):
        XCTAssertTrue(expectedTexts.contains(textPart))
      case let .executableCode(executableCode):
        XCTAssertEqual(executableCode.language, expectedLanguage)
        XCTAssertEqual(executableCode.code, expectedCode)
      case let .codeExecutionResult(codeExecutionResult):
        XCTAssertEqual(codeExecutionResult.outcome, .ok)
        XCTAssertEqual(codeExecutionResult.output, expectedOutput)
      default:
        XCTFail("Unexpected part type: \(part)")
      }
      try textValues.append(XCTUnwrap(content.text))
    }

    XCTAssertEqual(textValues.joined(separator: "\n"), """
    \(expectedTexts1.joined(separator: "\n"))
    ```\(expectedLanguage.lowercased())
    \(expectedCode)
    ```
    ```
    \(expectedOutput)
    ```
    \(expectedTexts2.joined(separator: "\n"))
    """)
  }

  func testGenerateContentStream_usageMetadata() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-basic-reply-short",
        withExtension: "txt"
      )
    var responses = [GenerateContentResponse]()

    let stream = model.generateContentStream(testPrompt)
    for try await response in stream {
      responses.append(response)
    }

    for (index, response) in responses.enumerated() {
      if index == responses.endIndex - 1 {
        let usageMetadata = try XCTUnwrap(response.usageMetadata)
        // TODO(andrewheard): Re-run prompt when `promptTokenCount` and `totalTokenCount` added.
        XCTAssertEqual(usageMetadata.promptTokenCount, 0)
        XCTAssertEqual(usageMetadata.candidatesTokenCount, 4)
        XCTAssertEqual(usageMetadata.totalTokenCount, 0)
      } else {
        // Only the last streamed response contains usage metadata
        XCTAssertNil(response.usageMetadata)
      }
    }
  }

  func testGenerateContentStream_errorMidStream() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "streaming-failure-error-mid-stream",
      withExtension: "txt"
    )

    var responseCount = 0
    do {
      let stream = model.generateContentStream("Hi")
      for try await content in stream {
        XCTAssertNotNil(content.text)
        responseCount += 1
      }
    } catch let GenerateContentError.internalError(rpcError as RPCError) {
      XCTAssertEqual(rpcError.httpResponseCode, 499)
      XCTAssertEqual(rpcError.status, .cancelled)

      // Check the content count is correct.
      XCTAssertEqual(responseCount, 2)
      return
    }

    XCTFail("Expected an internalError with an RPCError.")
  }

  func testGenerateContentStream_nonHTTPResponse() async throws {
    MockURLProtocol.requestHandler = try nonHTTPRequestHandler()

    let stream = model.generateContentStream("Hi")
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch let GenerateContentError.internalError(underlying) {
      XCTAssertEqual(underlying.localizedDescription, "Response was not an HTTP response.")
      return
    }

    XCTFail("Expected an internal error.")
  }

  func testGenerateContentStream_invalidResponse() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-invalid-json",
        withExtension: "txt"
      )

    let stream = model.generateContentStream(testPrompt)
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch let GenerateContentError.internalError(underlying as DecodingError) {
      guard case let .dataCorrupted(context) = underlying else {
        XCTFail("Not a data corrupted error: \(underlying)")
        return
      }
      XCTAssert(context.debugDescription.hasPrefix("Failed to decode GenerateContentResponse"))
      return
    }

    XCTFail("Expected an internal error.")
  }

  func testGenerateContentStream_malformedContent() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-failure-malformed-content",
        withExtension: "txt"
      )

    let stream = model.generateContentStream(testPrompt)
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch let GenerateContentError.internalError(underlyingError as InvalidCandidateError) {
      guard case let .malformedContent(contentError) = underlyingError else {
        XCTFail("Not a malformed content error: \(underlyingError)")
        return
      }

      XCTAssert(contentError is DecodingError)
      return
    }

    XCTFail("Expected an internal decoding error.")
  }

  func testGenerateContentStream_failure_unsupportedUserLocation() async throws {
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "unary-failure-unsupported-user-location",
        withExtension: "json",
        statusCode: 400
      )

    let stream = model.generateContentStream(testPrompt)
    do {
      for try await content in stream {
        XCTFail("Unexpected content in stream: \(content)")
      }
    } catch GenerateContentError.unsupportedUserLocation {
      return
    }

    XCTFail("Expected an unsupported user location error.")
  }

  func testGenerateContentStream_requestOptions_customTimeout() async throws {
    let expectedTimeout = 150.0
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-basic-reply-short",
        withExtension: "txt",
        timeout: expectedTimeout
      )
    let requestOptions = RequestOptions(timeout: expectedTimeout)
    model = GenerativeModel(
      name: "my-model",
      apiKey: "API_KEY",
      requestOptions: requestOptions,
      urlSession: urlSession
    )

    var responses = 0
    let stream = model.generateContentStream(testPrompt)
    for try await content in stream {
      XCTAssertNotNil(content.text)
      responses += 1
    }

    XCTAssertEqual(responses, 1)
  }

  func testGenerateContentStream_requestOptions_defaultTimeout() async throws {
    let expectedTimeout = 300.0 // Default in timeout in RequestOptions()
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "streaming-success-basic-reply-short",
        withExtension: "txt",
        timeout: expectedTimeout
      )

    var responses = 0
    let stream = model.generateContentStream(testPrompt)
    for try await content in stream {
      XCTAssertNotNil(content.text)
      responses += 1
    }

    XCTAssertEqual(responses, 1)
  }

  // MARK: - Count Tokens

  func testCountTokens_succeeds() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "success-total-tokens",
      withExtension: "json"
    )

    let response = try await model.countTokens("Why is the sky blue?")
    XCTAssertEqual(response.totalTokens, 6)
  }

  func testCountTokens_modelNotFound() async throws {
    MockURLProtocol.requestHandler = try httpRequestHandler(
      forResource: "failure-model-not-found", withExtension: "json",
      statusCode: 404
    )

    do {
      _ = try await model.countTokens("Why is the sky blue?")
      XCTFail("Request should not have succeeded.")
    } catch let CountTokensError.internalError(rpcError as RPCError) {
      XCTAssertEqual(rpcError.httpResponseCode, 404)
      XCTAssertEqual(rpcError.status, .notFound)
      XCTAssert(rpcError.message.hasPrefix("models/test-model-name is not found"))
      return
    }

    XCTFail("Expected internal RPCError.")
  }

  func testCountTokens_requestOptions_customTimeout() async throws {
    let expectedTimeout = 150.0
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "success-total-tokens",
        withExtension: "json",
        timeout: expectedTimeout
      )
    let requestOptions = RequestOptions(timeout: expectedTimeout)
    model = GenerativeModel(
      name: "my-model",
      apiKey: "API_KEY",
      requestOptions: requestOptions,
      urlSession: urlSession
    )

    let response = try await model.countTokens(testPrompt)

    XCTAssertEqual(response.totalTokens, 6)
  }

  func testCountTokens_requestOptions_defaultTimeout() async throws {
    let expectedTimeout = 300.0
    MockURLProtocol
      .requestHandler = try httpRequestHandler(
        forResource: "success-total-tokens",
        withExtension: "json",
        timeout: expectedTimeout
      )

    let response = try await model.countTokens(testPrompt)

    XCTAssertEqual(response.totalTokens, 6)
  }

  // MARK: - Model Resource Name

  func testModelResourceName_noPrefix() async throws {
    let modelName = "my-model"
    let modelResourceName = "models/\(modelName)"

    model = GenerativeModel(name: modelName, apiKey: "API_KEY")

    XCTAssertEqual(model.modelResourceName, modelResourceName)
  }

  func testModelResourceName_modelsPrefix() async throws {
    let modelResourceName = "models/my-model"

    model = GenerativeModel(name: modelResourceName, apiKey: "API_KEY")

    XCTAssertEqual(model.modelResourceName, modelResourceName)
  }

  func testModelResourceName_tunedModelsPrefix() async throws {
    let tunedModelResourceName = "tunedModels/my-model"

    model = GenerativeModel(name: tunedModelResourceName, apiKey: "API_KEY")

    XCTAssertEqual(model.modelResourceName, tunedModelResourceName)
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
                                  statusCode: Int = 200,
                                  timeout: TimeInterval = RequestOptions()
                                    .timeout) throws -> ((URLRequest) throws -> (
    URLResponse,
    AsyncLineSequence<URL.AsyncBytes>?
  )) {
    let fileURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: ext))
    return { request in
      let requestURL = try XCTUnwrap(request.url)
      XCTAssertEqual(requestURL.path.occurrenceCount(of: "models/"), 1)
      XCTAssertEqual(request.timeoutInterval, timeout)
      let response = try XCTUnwrap(HTTPURLResponse(
        url: requestURL,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      ))
      return (response, fileURL.lines)
    }
  }
}

private extension String {
  /// Returns the number of occurrences of `substring` in the `String`.
  func occurrenceCount(of substring: String) -> Int {
    return components(separatedBy: substring).count - 1
  }
}

private extension URLRequest {
  /// Returns the default `timeoutInterval` for a `URLRequest`.
  static func defaultTimeoutInterval() -> TimeInterval {
    let placeholderURL = URL(string: "https://example.com")!
    return URLRequest(url: placeholderURL).timeoutInterval
  }
}
