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

import XCTest

@testable import GoogleGenerativeAI

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
final class CodeExecutionTests: XCTestCase {
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  let languageKey = "language"
  let languageValue = "PYTHON"
  let codeKey = "code"
  let codeValue = "print('Hello, world!')"
  let outcomeKey = "outcome"
  let outcomeValue = "OUTCOME_OK"
  let outputKey = "output"
  let outputValue = "Hello, world!"

  override func setUp() {
    encoder.outputFormatting = .init(
      arrayLiteral: .prettyPrinted, .sortedKeys, .withoutEscapingSlashes
    )
  }

  func testEncodeCodeExecution() throws {
    let jsonData = try encoder.encode(CodeExecution())

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, """
    {

    }
    """)
  }

  func testDecodeExecutableCode() throws {
    let expectedExecutableCode = ExecutableCode(language: languageValue, code: codeValue)
    let json = """
    {
      "\(languageKey)": "\(languageValue)",
      "\(codeKey)": "\(codeValue)"
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let executableCode = try XCTUnwrap(decoder.decode(ExecutableCode.self, from: jsonData))

    XCTAssertEqual(executableCode, expectedExecutableCode)
  }

  func testEncodeExecutableCode() throws {
    let executableCode = ExecutableCode(language: languageValue, code: codeValue)

    let jsonData = try encoder.encode(executableCode)

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, """
    {
      "\(codeKey)" : "\(codeValue)",
      "\(languageKey)" : "\(languageValue)"
    }
    """)
  }

  func testDecodeCodeExecutionResultOutcome_ok() throws {
    let expectedOutcome = CodeExecutionResult.Outcome.ok
    let json = "\"\(outcomeValue)\""
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let outcome = try XCTUnwrap(decoder.decode(CodeExecutionResult.Outcome.self, from: jsonData))

    XCTAssertEqual(outcome, expectedOutcome)
  }

  func testDecodeCodeExecutionResultOutcome_unknown() throws {
    let expectedOutcome = CodeExecutionResult.Outcome.unknown
    let json = "\"OUTCOME_NEW_VALUE\""
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let outcome = try XCTUnwrap(decoder.decode(CodeExecutionResult.Outcome.self, from: jsonData))

    XCTAssertEqual(outcome, expectedOutcome)
  }

  func testEncodeCodeExecutionResultOutcome() throws {
    let jsonData = try encoder.encode(CodeExecutionResult.Outcome.ok)

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, "\"\(outcomeValue)\"")
  }

  func testDecodeCodeExecutionResult() throws {
    let expectedCodeExecutionResult = CodeExecutionResult(outcome: .ok, output: "Hello, world!")
    let json = """
    {
      "\(outcomeKey)": "\(outcomeValue)",
      "\(outputKey)": "\(outputValue)"
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let codeExecutionResult = try XCTUnwrap(decoder.decode(
      CodeExecutionResult.self,
      from: jsonData
    ))

    XCTAssertEqual(codeExecutionResult, expectedCodeExecutionResult)
  }

  func testDecodeCodeExecutionResult_missingOutput() throws {
    let expectedCodeExecutionResult = CodeExecutionResult(outcome: .deadlineExceeded, output: "")
    let json = """
    {
      "\(outcomeKey)": "OUTCOME_DEADLINE_EXCEEDED"
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let codeExecutionResult = try XCTUnwrap(decoder.decode(
      CodeExecutionResult.self,
      from: jsonData
    ))

    XCTAssertEqual(codeExecutionResult, expectedCodeExecutionResult)
  }

  func testEncodeCodeExecutionResult() throws {
    let codeExecutionResult = CodeExecutionResult(outcome: .ok, output: outputValue)

    let jsonData = try encoder.encode(codeExecutionResult)

    let json = try XCTUnwrap(String(data: jsonData, encoding: .utf8))
    XCTAssertEqual(json, """
    {
      "\(outcomeKey)" : "\(outcomeValue)",
      "\(outputKey)" : "\(outputValue)"
    }
    """)
  }
}
