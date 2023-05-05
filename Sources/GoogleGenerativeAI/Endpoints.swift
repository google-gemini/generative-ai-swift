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
  }
}

extension API.V1beta2 {
  func generateMessage(_ model: String) -> GenerateMessageResource {
    GenerateMessageResource(path: "\(path)/\(model):generateMessage")
  }

  struct GenerateMessageResource {
    /// Path: `/v1beta2/{+model}:generateMessage`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: GenerateMessageRequest? = nil) -> Request<GenerateMessageResponse> {
      Request(path: path, method: .post, body: body, id: "generativelanguage.models.generateMessage")
    }
  }
}

extension API.V1beta2 {
  func generateText(_ model: String) -> GenerateTextResource {
    GenerateTextResource(path: "\(path)/\(model):generateText")
  }

  struct GenerateTextResource {
    /// Path: `/v1beta2/{+model}:generateText`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: GenerateTextRequest? = nil) -> Request<GenerateTextResponse> {
      Request(path: path, method: .post, body: body, id: "generativelanguage.models.generateText")
    }
  }
}

extension API.V1beta2 {
  func embedText(_ model: String) -> EmbedTextResource {
    EmbedTextResource(path: "\(path)/\(model):embedText")
  }

  struct EmbedTextResource {
    /// Path: `/v1beta2/{+model}:generateText`
    let path: String

    /// Generates a response from the model given an input `MessagePrompt`.
    func post(_ body: EmbedTextRequest? = nil) -> Request<EmbedTextResponse> {
      Request(path: path, method: .post, body: body, id: "generativelanguage.models.embedText")
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
      Request(path: path, method: .get, query: parameters?.asQuery, id: "generativelanguage.models.list")
    }

    /// Gets information about a specific Model.
    func get(name: String) -> Request<Model> {
      let modelPath = path.appending("/\(name)")
      return Request(path: modelPath, method: .get, id: "generativelanguage.models.get")
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
