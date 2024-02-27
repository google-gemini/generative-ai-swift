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

final class JSONValueTests: XCTestCase {
  func testDecodeNull() throws {
    let jsonData = try XCTUnwrap("null".data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .null)
  }

  func testDecodeNumber() throws {
    let expectedNumber = 3.14159
    let jsonData = try XCTUnwrap("\(expectedNumber)".data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .number(expectedNumber))
  }

  func testDecodeString() throws {
    let expectedString = "hello-world"
    let jsonData = try XCTUnwrap("\"\(expectedString)\"".data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .string(expectedString))
  }

  func testDecodeBool() throws {
    let expectedBool = true
    let jsonData = try XCTUnwrap("\(expectedBool)".data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .bool(expectedBool))
  }

  func testDecodeObject() throws {
    let numberKey = "pi"
    let numberValue = 3.14159
    let stringKey = "hello"
    let stringValue = "world"
    let expectedObject: JSONObject = [
      numberKey: .number(numberValue),
      stringKey: .string(stringValue),
    ]
    let json = """
    {
      "\(numberKey)": \(numberValue),
      "\(stringKey)": "\(stringValue)"
    }
    """
    let jsonData = try XCTUnwrap(json.data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .object(expectedObject))
  }

  func testDecodeArray() throws {
    let numberValue = 3.14159
    let expectedArray: [JSONValue] = [.null, .number(numberValue)]
    let jsonData = try XCTUnwrap("[ null, \(numberValue) ]".data(using: .utf8))

    let jsonObject = try XCTUnwrap(JSONDecoder().decode(JSONValue.self, from: jsonData))

    XCTAssertEqual(jsonObject, .array(expectedArray))
  }
}
