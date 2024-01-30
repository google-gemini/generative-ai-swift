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
  let generationConfig: GenerationConfig?
  let safetySettings: [SafetySetting]?
  let isStreaming: Bool
  let options: RequestOptions
  let projectID: String
}

extension GenerateContentRequest: Encodable {
  enum CodingKeys: String, CodingKey {
    case contents
    case generationConfig
    case safetySettings
  }
}

extension GenerateContentRequest: GenerativeAIRequest {
  typealias Response = GenerateContentResponse

  var url: URL {
    let modelResource = "projects/\(projectID)/locations/us-central1/publishers/google/\(model)"
    if isStreaming {
      return URL(
        string: "\(GenerativeAISwift.baseURL)/\(modelResource):streamGenerateContent?alt=sse"
      )!
    } else {
      return URL(string: "\(GenerativeAISwift.baseURL)/\(modelResource):generateContent")!
    }
  }
}
