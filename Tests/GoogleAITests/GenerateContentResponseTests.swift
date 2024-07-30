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
final class GenerateContentResponseTests: XCTestCase {
  let testText1 = "test-text-1"
  let testText2 = "test-text-2"
  let testLanguage = "PYTHON"
  let testCode = "print('Hello, world!')"
  let testOutput = "Hello, world!"

  override func setUp() {}

  func testText_textPart() throws {
    let parts = [ModelContent.Part.text(testText1)]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, "\(testText1)")
  }

  func testText_textParts_concatenated() throws {
    let parts = [ModelContent.Part.text(testText1), ModelContent.Part.text(testText2)]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, """
    \(testText1)
    \(testText2)
    """)
  }

  func testText_executableCodePart_python() throws {
    let parts = [ModelContent.Part.executableCode(ExecutableCode(
      language: testLanguage,
      code: testCode
    ))]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, """
    ```\(testLanguage.lowercased())
    \(testCode)
    ```
    """)
  }

  func testText_executableCodePart_unspecifiedLanguage() throws {
    let parts = [ModelContent.Part.executableCode(ExecutableCode(
      language: "LANGUAGE_UNSPECIFIED",
      code: "echo $SHELL"
    ))]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, """
    ```
    echo $SHELL
    ```
    """)
  }

  func testText_codeExecutionResultPart_hasOutput() throws {
    let parts = [ModelContent.Part.codeExecutionResult(CodeExecutionResult(
      outcome: .ok,
      output: testOutput
    ))]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, """
    ```
    \(testOutput)
    ```
    """)
  }

  func testText_codeExecutionResultPart_emptyOutput() throws {
    let parts = [ModelContent.Part.codeExecutionResult(CodeExecutionResult(
      outcome: .deadlineExceeded,
      output: ""
    ))]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    XCTAssertNil(response.text)
  }

  func testText_codeExecution_concatenated() throws {
    let parts: [ModelContent.Part] = [
      .text("test-text-1"),
      .executableCode(ExecutableCode(language: testLanguage, code: testCode)),
      .codeExecutionResult(CodeExecutionResult(outcome: .ok, output: testOutput)),
      .text("test-text-2"),
    ]
    let candidate = CandidateResponse(
      content: ModelContent(role: "model", parts: parts),
      safetyRatings: [],
      finishReason: nil,
      citationMetadata: nil
    )
    let response = GenerateContentResponse(candidates: [candidate])

    let text = try XCTUnwrap(response.text)

    XCTAssertEqual(text, """
    \(testText1)
    ```\(testLanguage.lowercased())
    \(testCode)
    ```
    ```
    \(testOutput)
    ```
    \(testText2)
    """)
  }
}
