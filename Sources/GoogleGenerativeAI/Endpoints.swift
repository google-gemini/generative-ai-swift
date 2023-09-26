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
  static var v1beta2: V1beta2 {
    V1beta2(path: "/v1beta2")
  }

  struct V1beta2 {
    /// Path: `/v1beta2`
    let path: String
      
    enum Resource: String, Identifiable {
      case generateMessage
      case generateText
      case embedText
      case list
      case get
          
      var baseID: String { "generativelanguage.models" }
      var id: String { "\(baseID).\(self.rawValue)" }
    }
  }
}

extension API.V1beta2 {
  func generateMessage(_ model: String) -> GenerateMessageResource {
    GenerateMessageResource(path: "\(path)/\(model):\(Resource.generateMessage.rawValue)")
  }

  struct GenerateMessageResource {
    /// Path: `/v1beta2/{+model}:generateMessage`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: GenerateMessageRequest? = nil) -> Request<GenerateMessageResponse> {
      Request(path: path, method: .post, body: body, id: Resource.generateMessage.id)
    }
  }
}

extension API.V1beta2 {
  func generateText(_ model: String) -> GenerateTextResource {
    GenerateTextResource(path: "\(path)/\(model):\(Resource.generateText.rawValue)")
  }

  struct GenerateTextResource {
    /// Path: `/v1beta2/{+model}:generateText`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: GenerateTextRequest? = nil) -> Request<GenerateTextResponse> {
      Request(path: path, method: .post, body: body, id: Resource.generateText.id)
    }
  }
}

extension API.V1beta2 {
  func embedText(_ model: String) -> EmbedTextResource {
    EmbedTextResource(path: "\(path)/\(model):\(Resource.embedText.rawValue)")
  }

  struct EmbedTextResource {
    /// Path: `/v1beta2/{+model}:generateText`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: EmbedTextRequest? = nil) -> Request<EmbedTextResponse> {
      Request(path: path, method: .post, body: body, id: Resource.embedText.id)
    }
  }
}


extension API.V1beta2 {
  var models: ModelsResource {
    ModelsResource(path: path + "/models")
  }

  struct ModelsResource {
    /// Path: `/v1beta2/models`
    let path: String

    /// Lists models available through the API.
    func get(parameters: Parameters? = nil) -> Request<ListModelsResponse> {
      Request(path: path, method: .get, query: parameters?.asQuery, id: Resource.list.id)
    }

    /// Gets information about a specific Model.
    func get(name: String) -> Request<Model> {
      let modelPath = path.appending("/\(name)")
      return Request(path: modelPath, method: .get, id: Resource.get.id)
    }

    struct Parameters {
      var pageSize: Int?
      var pageToken: String?

      init(pageSize: Int? = nil, pageToken: String? = nil) {
        self.pageSize = pageSize
        self.pageToken = pageToken
      }

      var asQuery: [(String, String?)] {
        let encoder = URLQueryEncoder()
        encoder.encode(pageSize, forKey: "pageSize")
        encoder.encode(pageToken, forKey: "pageToken")
        return encoder.items
      }
    }
  }
}
