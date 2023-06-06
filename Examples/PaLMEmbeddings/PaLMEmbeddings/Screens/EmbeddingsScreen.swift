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

struct EmbeddingsScreen: View {
  @StateObject var viewModel = EmbeddingsViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        TextField("Text", text: $viewModel.inputText, axis: .vertical)
          .lineLimit(10, reservesSpace: true)
          .textFieldStyle(.roundedBorder)

        Button(action: onSummarizeTapped) {
          if viewModel.inProgress {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .frame(maxWidth: .infinity, maxHeight: 8)
              .padding(6)
          }
          else {
            Text("Generate Embeddings")
              .frame(maxWidth: .infinity, maxHeight: 50)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.vertical)

        TextField("Result", text: $viewModel.outputText, axis: .vertical)
          .lineLimit(10, reservesSpace: true)
          .textFieldStyle(.roundedBorder)
        Spacer()
      }
      .navigationTitle("Text")
      .padding()
    }
  }

  private func onSummarizeTapped() {
    Task {
      await viewModel.generateEmbeddings()
    }
  }
}

struct EmbeddingsScreen_Previews: PreviewProvider {
  static var previews: some View {
    EmbeddingsScreen()
  }
}
