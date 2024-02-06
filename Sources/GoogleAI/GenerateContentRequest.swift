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

struct GenerateContentRequest {
  /// Model name.
  let model: String
  let contents: [ModelContent]
  let tools: [Tool]?
  let generationConfig: GenerationConfig?
  let safetySettings: [SafetySetting]?
  let isStreaming: Bool
}

extension GenerateContentRequest: Encodable {
  enum CodingKeys: String, CodingKey {
    case contents
    case tools
    case generationConfig
    case safetySettings
  }
}

extension GenerateContentRequest: GenerativeAIRequest {
  typealias Response = GenerateContentResponse

  var url: URL {
    if isStreaming {
      URL(string: "\(GenerativeAISwift.baseURL)/\(model):streamGenerateContent?alt=sse")!
    } else {
      URL(string: "\(GenerativeAISwift.baseURL)/\(model):generateContent")!
    }
  }

  var previewOnly: Bool {
    if tools != nil {
      return true
    } else if contents.previewOnly {
      return true
    }

    return false
  }
}
