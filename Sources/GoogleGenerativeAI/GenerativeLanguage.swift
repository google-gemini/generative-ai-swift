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

public class GenerativeLanguage {
  private(set) var apiKey: String

  private lazy var apiClient: APIClient = {
    let baseURL = URL(string: "https://generativelanguage.googleapis.com")!
    return APIClient(baseURL: baseURL) { configuration in
      configuration.delegate = self
    }
  }()

  var session = URLSession.shared

  public init(apiKey: String) {
    self.apiKey = apiKey
  }
}

extension GenerativeLanguage: APIClientDelegate {
  public func client(_ client: APIClient, willSendRequest request: inout URLRequest) async throws {
    request.url?.append(queryItems: [URLQueryItem(name: "key", value: apiKey)])
  }
}

extension GenerativeLanguage: GenerativeLanguageProtocol {
  public func chat(prompt: String, context: String? = nil, examples: [Example]? = nil, model: String = "models/chat-bison-001", temperature: Float = 1, candidateCount: Int = 1) async throws -> GenerateMessageResponse? {
    try await chat(messages: [Message(content: prompt)],
                   context: context,
                   examples: examples,
                   model: model,
                   temperature: temperature,
                   candidateCount: candidateCount)
  }

  public func chat(messages: [Message], context: String? = nil, examples: [Example]? = nil, model: String = "models/chat-bison-001", temperature: Float = 1, candidateCount: Int = 1) async throws -> GenerateMessageResponse? {
    let messagePrompt = MessagePrompt(messages: messages, context: context, examples: examples)
    let messageRequest = GenerateMessageRequest(candidateCount: Int32(candidateCount), prompt: messagePrompt, temperature: temperature)

    let request = API.v1beta1.generateMessage(model).post(messageRequest)
    let response = try await apiClient.send(request)
    return response.value
  }

  public func listModels() async throws -> ListModelsResponse? {
    let request = API.v1beta1.models.get()
    let response = try await apiClient.send(request)
    return response.value
  }

  public func getModel(name: String) async throws -> Model? {
    let request = API.v1beta1.models.get(name: name)
    let response = try await apiClient.send(request)
    return response.value
  }

}
