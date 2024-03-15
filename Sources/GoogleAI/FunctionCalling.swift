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

/// A predicted function call returned from the model.
///
/// REST Docs: https://ai.google.dev/api/rest/v1beta/Content#functioncall
public struct FunctionCall: Equatable, Encodable {
  /// The name of the function to call.
  public let name: String

  /// The function parameters and values.
  public let args: JSONObject
}

// REST Docs: https://ai.google.dev/api/rest/v1beta/Tool#schema
public class Schema: Encodable {
  let type: DataType

  let format: String?

  let description: String?

  let nullable: Bool?

  let enumValues: [String]?

  let items: Schema?

  let properties: [String: Schema]?

  let required: [String]?

  public init(type: DataType, format: String? = nil, description: String? = nil,
              nullable: Bool? = nil,
              enumValues: [String]? = nil, items: Schema? = nil,
              properties: [String: Schema]? = nil,
              required: [String]? = nil) {
    self.type = type
    self.format = format
    self.description = description
    self.nullable = nullable
    self.enumValues = enumValues
    self.items = items
    self.properties = properties
    self.required = required
  }
}

// REST Docs: https://ai.google.dev/api/rest/v1beta/Tool#Type
public enum DataType: String, Encodable {
  case string = "STRING"
  case number = "NUMBER"
  case integer = "INTEGER"
  case boolean = "BOOLEAN"
  case array = "ARRAY"
  case object = "OBJECT"
}

// REST Docs: https://ai.google.dev/api/rest/v1beta/Tool#FunctionDeclaration
public struct FunctionDeclaration {
  let name: String

  let description: String

  let parameters: Schema

  let function: ((JSONObject) async throws -> JSONObject)?

  public init(name: String, description: String, parameters: Schema,
              function: ((JSONObject) async throws -> JSONObject)?) {
    self.name = name
    self.description = description
    self.parameters = parameters
    self.function = function
  }
}

// REST Docs: https://ai.google.dev/api/rest/v1beta/Tool
public struct Tool: Encodable {
  let functionDeclarations: [FunctionDeclaration]?

  public init(functionDeclarations: [FunctionDeclaration]?) {
    self.functionDeclarations = functionDeclarations
  }
}

// REST Docs: https://ai.google.dev/api/rest/v1beta/Content#functionresponse
public struct FunctionResponse: Equatable, Encodable {
  let name: String

  let response: JSONObject
}

// MARK: - Codable Conformance

extension FunctionCall: Decodable {
  enum CodingKeys: CodingKey {
    case name
    case args
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    if let args = try container.decodeIfPresent(JSONObject.self, forKey: .args) {
      self.args = args
    } else {
      args = JSONObject()
    }
  }
}

extension FunctionDeclaration: Encodable {
  enum CodingKeys: String, CodingKey {
    case name
    case description
    case parameters
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(description, forKey: .description)
    try container.encode(parameters, forKey: .parameters)
  }
}
