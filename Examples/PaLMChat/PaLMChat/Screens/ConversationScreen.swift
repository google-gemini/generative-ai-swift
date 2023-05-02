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

import SwiftUI
import GoogleGenerativeAI

struct ConversationScreen: View {
  @StateObject
  private var viewModel = ConversationViewModel()

  @State
  private var userPrompt = ""

  enum FocusedField: Hashable {
    case message
  }

  @FocusState
  var focusedField: FocusedField?

  var body: some View {
    VStack {
      ScrollViewReader { scrollViewProxy in
        List(viewModel.messages) { message in
          MessageView(message: message)
        }
        .listStyle(.plain)
        .onChange(of: viewModel.messages, perform: { newValue in
          guard let lastMessage = viewModel.messages.last else { return }

          // wait for a short moment to make sure we can actually scroll to the bottom
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation {
              scrollViewProxy.scrollTo(lastMessage.id, anchor: .top)
            }
            focusedField = .message
          }
        })
      }
      HStack {
        TextField("Message...", text: $userPrompt)
          .focused($focusedField, equals: .message)
          .textFieldStyle(.roundedBorder)
          .frame(minHeight: CGFloat(30))
          .onSubmit { sendMessage() }
        Button(action: { sendMessage() }) {
          Text("Send")
        }
      }
      .padding(.horizontal)
    }
    .onAppear() {
      focusedField = .message
    }
  }

  private func sendMessage() {
    Task {
      let prompt = userPrompt
      userPrompt = ""
      await viewModel.sendMessage(prompt)
    }
  }
}

struct ConversationScreen_Previews: PreviewProvider {
  static var previews: some View {
    ConversationScreen()
  }
}
