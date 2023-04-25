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
import Get
import URLQueryEncoder

extension API {
  public static var v1beta1: V1beta1 {
    V1beta1(path: "/v1beta1")
  }

  public struct V1beta1 {
    /// Path: `/v1beta1`
    public let path: String
  }
}

extension API.V1beta1 {
  public func generateMessage(_ model: String) -> GenerateMessage {
    GenerateMessage(path: "\(path)/\(model):generateMessage")
  }

  public struct GenerateMessage {
    /// Path: `/v1beta1/{+model}:generateMessage`
    public let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    public func post(_ body: GenerateMessageRequest? = nil) -> Request<GenerateMessageResponse> {
      Request(method: "POST", url: path, body: body, id: "generativelanguage.models.generateMessage")
    }
  }
}

extension API.V1beta1 {
  public var models: Models {
    Models(path: path + "/models")
  }

  public struct Models {
    /// Path: `/v1beta1/models`
    public let path: String

    /// Lists models available through the API.
    public func get(parameters: GetParameters? = nil) -> Request<ListModelsResponse> {
      Request(method: "GET", url: path, query: parameters?.asQuery, id: "generativelanguage.models.list")
    }

    /// Gets information about a specific Model.
    public func get(name: String) -> Request<Model> {
      let modelPath = path.appending("/\(name)")
      return Request(method: "GET", url: modelPath, id: "generativelanguage.models.get")
    }

    public struct GetParameters {
      public var pageSize: Int?
      public var pageToken: String?

      public init(pageSize: Int? = nil, pageToken: String? = nil) {
        self.pageSize = pageSize
        self.pageToken = pageToken
      }

      public var asQuery: [(String, String?)] {
        let encoder = URLQueryEncoder()
        encoder.encode(pageSize, forKey: "pageSize")
        encoder.encode(pageToken, forKey: "pageToken")
        return encoder.items
      }
    }
  }
}
