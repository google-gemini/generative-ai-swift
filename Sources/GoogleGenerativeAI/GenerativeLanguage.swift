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

/// The API client for the PaLM API.
public class GenerativeLanguage {

  private(set) var apiKey: String

  private lazy var apiClient: APIClient = {
    let baseURL = URL(string: "https://generativelanguage.googleapis.com")
    return APIClient(baseURL: baseURL) { configuration in
      configuration.sessionConfiguration.httpAdditionalHeaders = ["x-goog-api-client": "genai-swift/0.1.0"]
      configuration.sessionConfiguration.httpAdditionalHeaders = ["x-goog-api-key": apiKey]
    }
  }()

  private var session = URLSession.shared

  /// Initializes the PalM API client.
  ///
  /// - Parameter apiKey: The API key to use.
  public init(apiKey: String) {
    self.apiKey = apiKey
  }
}

extension GenerativeLanguage: GenerativeLanguageProtocol {
  public func chat(message: String, context: String? = nil, examples: [Example]? = nil, model: String = "models/chat-bison-001", temperature: Float = 1, candidateCount: Int = 1) async throws -> GenerateMessageResponse {
    try await chat(message: message,
                   history: [Message](),
                   context: context,
                   examples: examples,
                   model: model,
                   temperature: temperature,
                   candidateCount: candidateCount)
  }

  public func chat(message: String, history: [Message], context: String? = nil, examples: [Example]? = nil, model: String = "models/chat-bison-001", temperature: Float = 1, candidateCount: Int = 1) async throws -> GenerateMessageResponse {
    var messages = history
    messages.append(Message(content: message, author: "0"))

    let messagePrompt = MessagePrompt(context: context, examples: examples, messages: messages)
    let messageRequest = GenerateMessageRequest(candidateCount: Int32(candidateCount), prompt: messagePrompt, temperature: temperature)

    let request = API.v1beta2.generateMessage(model).post(messageRequest)
    let response = try await apiClient.send(request)
    return response.value
  }

  public func generateText(with prompt: String, model: String = "models/text-bison-001", temperature: Float = 1, candidateCount: Int = 1) async throws -> GenerateTextResponse {
    let textPrompt = TextPrompt(text: prompt)
    let textRequest = GenerateTextRequest(temperature: temperature, candidateCount: Int32(candidateCount), prompt: textPrompt)
    let request = API.v1beta2.generateText(model).post(textRequest)
    let response = try await apiClient.send(request)
    return response.value
  }

  public func generateEmbeddings(from text: String, model: String = "models/embedding-gecko-001") async throws -> EmbedTextResponse {
    let embedTextRequest = EmbedTextRequest(text: text)
    let request = API.v1beta2.embedText(model).post(embedTextRequest)
    let response = try await apiClient.send(request)
    return response.value
  }

  public func listModels() async throws -> ListModelsResponse {
    let request = API.v1beta2.models.get()
    let response = try await apiClient.send(request)
    return response.value
  }

  public func getModel(name: String) async throws -> Model {
    let request = API.v1beta2.models.get(name: name)
    let response = try await apiClient.send(request)
    return response.value
  }

}
