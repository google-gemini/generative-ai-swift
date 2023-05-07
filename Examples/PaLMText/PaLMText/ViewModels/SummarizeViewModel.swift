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
class SummarizeViewModel: ObservableObject {
  @Published
  var inputText = ""

  @Published
  var outputText = ""

  @Published
  var inProgress = false

  /// Fetch the API key from `PaLM-Info.plist`
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
        fatalError("Follow the instructions at https://developers.generativeai.google/tutorials/setup to get a PaLM API key.")
      }
      return value
    }
  }

  private var palmClient: GenerativeLanguage?

  init() {
    palmClient = GenerativeLanguage(apiKey: apiKey)
  }

  private var prompt: String {
    "Summarize the following text for me: \(inputText)"
  }

  func summarize() async {
      do {
        inProgress = true
        let response = try await palmClient?.generateText(with: prompt)
        inProgress = false

        if let candidate = response?.candidates?.first, let text = candidate.output {
          outputText = text
        }
      }
      catch {
        print(error.localizedDescription)
      }
  }
}
