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
public struct GenerateContentRequest {
  /// Model name.
  public let model: String
  public let contents: [ModelContent]
  public let generationConfig: GenerationConfig?
  public let safetySettings: [SafetySetting]?
  public let isStreaming: Bool
  public let options: RequestOptions

  public init(model: String, contents: [ModelContent], generationConfig: GenerationConfig?,
              safetySettings: [SafetySetting]?, isStreaming: Bool, options: RequestOptions) {
    self.model = model
    self.contents = contents
    self.generationConfig = generationConfig
    self.safetySettings = safetySettings
    self.isStreaming = isStreaming
    self.options = options
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension GenerateContentRequest: Encodable {
  enum CodingKeys: String, CodingKey {
    case contents
    case generationConfig
    case safetySettings
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension GenerateContentRequest: GenerativeAIRequest {
  public typealias Response = GenerateContentResponse

  public var url: URL {
    let modelURL = "\(options.baseURL)/\(options.apiVersion)/\(model)"
    if isStreaming {
      return URL(string: "\(modelURL):streamGenerateContent?alt=sse")!
    } else {
      return URL(string: "\(modelURL):generateContent")!
    }
  }
}
