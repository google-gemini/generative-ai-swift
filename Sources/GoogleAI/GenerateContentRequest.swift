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

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
struct GenerateContentRequest {
  // Model name.
  let model: String
  // If true, the `model` field above is encoded in requests; currently only required when nested in
  // a `CountTokensRequest`.
  let isModelEncoded: Bool
  let contents: [ModelContent]
  let generationConfig: GenerationConfig?
  let safetySettings: [SafetySetting]?
  let tools: [Tool]?
  let toolConfig: ToolConfig?
  let systemInstruction: ModelContent?
  let isStreaming: Bool
  let options: RequestOptions
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension GenerateContentRequest: Encodable {
  enum CodingKeys: String, CodingKey {
    case model
    case contents
    case generationConfig
    case safetySettings
    case tools
    case toolConfig
    case systemInstruction
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    if isModelEncoded {
      try container.encode(model, forKey: .model)
    }
    try container.encode(contents, forKey: .contents)
    if let generationConfig {
      try container.encode(generationConfig, forKey: .generationConfig)
    }
    if let safetySettings {
      try container.encode(safetySettings, forKey: .safetySettings)
    }
    if let tools {
      try container.encode(tools, forKey: .tools)
    }
    if let toolConfig {
      try container.encode(toolConfig, forKey: .toolConfig)
    }
    if let systemInstruction {
      try container.encode(systemInstruction, forKey: .systemInstruction)
    }
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension GenerateContentRequest: GenerativeAIRequest {
  typealias Response = GenerateContentResponse

  var url: URL {
    let modelURL = "\(GenerativeAISwift.baseURL)/\(options.apiVersion)/\(model)"
    if isStreaming {
      return URL(string: "\(modelURL):streamGenerateContent?alt=sse")!
    } else {
      return URL(string: "\(modelURL):generateContent")!
    }
  }
}
