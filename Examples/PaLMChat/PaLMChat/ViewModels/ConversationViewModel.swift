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
import GoogleGenerativeAI

@MainActor
class ConversationViewModel: ObservableObject {
  @Published
  var messages = [ChatMessage]()

  var history = [Message]()

  private var apiKey: String {
    get {
      guard let filePath = Bundle.main.path(forResource: "PaLM-Info", ofType: "plist") else {
        fatalError("Couldn't find file 'PaLM-Info.plist'.")
      }
      let plist = NSDictionary(contentsOfFile: filePath)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'PaLM-Info.plist'.")
      }
      if (value.starts(with: "_")) {
        fatalError("Follow the instructions at https://docs.google.com/document/d/1jSxGYIe_8gR0FQwML3dVx1t5pZSouUy2RtUFl4-KzrY to get a PaLM API key.")
      }
      return value
    }
  }

  private var palmClient: GenerativeLanguage?

  init() {
    palmClient = GenerativeLanguage(apiKey: apiKey)
  }

  func sendMessage(_ text: String) async {
    let userMessage = ChatMessage(message: text, participant: .user)
    messages.append(userMessage)

    var systemMessage = ChatMessage(message: "", participant: .system, pending: true)
    messages.append(systemMessage)

    do {
      var response: GenerateMessageResponse?
      if history.isEmpty {
        response = try await palmClient?.chat(prompt: userMessage.message)
      }
      else {
        history.append(Message(content: userMessage.message, author: "0"))
        response = try await palmClient?.chat(messages: history)
      }

      if let candidate = response?.candidates?.first, let text = candidate.content {
        systemMessage.message = text
        systemMessage.pending = false
        messages.removeLast()
        messages.append(systemMessage)

        if let historicMessages = response?.messages {
          history = historicMessages
          history.append(candidate)
        }
      }
    }
    catch {
      let errorMessage = ChatMessage(message: error.localizedDescription, participant: .system)
      messages.removeLast()
      messages.append(errorMessage)
    }
  }
}
