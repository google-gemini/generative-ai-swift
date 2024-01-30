import Foundation

public struct Tool: Encodable {
  let functionDeclarations: [FunctionDeclaration]

  public init(functionDeclarations: [FunctionDeclaration]) {
    self.functionDeclarations = functionDeclarations
  }
}

public struct FunctionDeclaration: Encodable {
  let name: String
  let description: String
  let parameters: Schema

  public init(name: String, description: String, parameters: Schema) {
    self.name = name
    self.description = description
    self.parameters = parameters
  }
}

// struct FunctionParameters {
//  let type = "OBJECT"
//  let properties: [String:FunctionParameterProperties]
// }
//
// struct FunctionParameterProperties {
//  let type = "OBJECT"
//  let properties: [String:FunctionParameterProperties]
// }

public struct Schema: Codable {
  enum CodingKeys: String, CodingKey {
    case type
    case format
    case description
    case nullable
    case enumValues = "enum"
    case properties
    case required
  }

  public init(type: Type, format: String?, description: String?, nullable: Bool?,
              enumValues: [String]?, properties: [String: Schema]?, required: [String]?) {
    self.type = type
    self.format = format
    self.description = description
    self.nullable = nullable
    self.enumValues = enumValues
    self.properties = properties
    self.required = required
  }

  // Data type.
  let type: Type?

  // The format of the data. This is used only for primitive datatypes.
  // Supported formats:
  //  for NUMBER type: float, double
  //  for INTEGER type: int32, int64
  let format: String?

  // A brief description of the parameter. This could contain examples of use.
  // Parameter description may be formatted as Markdown.
  let description: String?

  // Indicates if the value may be null.
  let nullable: Bool?

  // Possible values of the element of Type.STRING with enum format.
  // For example we can define an Enum Direction as :
  // {type:STRING, format:enum, enum:["EAST", NORTH", "SOUTH", "WEST"]}
  // (-- api-linter: core::0140::reserved-words=disabled
  //     aip.dev/not-precedent: impacts JSON to Schema 1:1 mapping. --)
  let enumValues: [String]?

  // Schema of the elements of Type.ARRAY.
//  let items: Schema?

  // Properties of Type.OBJECT.
  let properties: [String: Schema]?

  // Required properties of Type.OBJECT.
  let required: [String]?
}

public enum Type: String, Codable {
  // Not specified, should not be used.
  case TYPE_UNSPECIFIED
  // String type.
  case string
  // Number type.
  case number
  // Integer type.
  case integer
  // Boolean type.
  case boolean
  // Array type.
  case array
  // Object type.
  case object
}

// A predicted `FunctionCall` returned from the model that contains
// a string representing the `FunctionDeclaration.name` with the
// arguments and their values.
// (-- api-linter: core::0123::resource-annotation=disabled
//     aip.dev/not-precedent: Not a resource name. --)
struct FunctionCall: Codable {
  enum CodingKeys: CodingKey {
    case name
    case args
  }

  // The name of the function to call.
  // Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  // length of 63.
  let name: String

  // The function parameters and values in JSON object format.
  let args: [String: Int]
}

// The result output from a `FunctionCall` that contains a string
// representing the `FunctionDeclaration.name` and a structured JSON
// object containing any output from the function is used as context to
// the model. This should contain the result of a`FunctionCall` made
// based on model prediction.
struct FunctionResponse: Encodable {
  enum CodingKeys: CodingKey {
    case name
    case response
  }

  // The name of the function to call.
  // Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  // length of 63.
  let name: String

  // The function response in JSON object format.
  let response: [String: Int]
}
