// Copyright 2024 Google LLC
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

import GoogleGenerativeAI
import XCTest

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
final class TextGeneration: XCTestCase {
  override func setUpWithError() throws {
    try XCTSkipIf(APIKey.default.isEmpty, "`\(APIKey.apiKeyEnvVar)` environment variable not set.")
  }

  func testTextOnlyPrompt() async throws {
    // [START text_gen_text_only_prompt]
    let generativeModel =
      GenerativeModel(
        // Specify a Gemini model appropriate for your use case
        name: "gemini-1.5-flash",
        // Access your API key from your on-demand resource .plist file (see "Set up your API key"
        // above)
        apiKey: APIKey.default
      )

    let prompt = "Write a story about a magic backpack."
    let response = try await generativeModel.generateContent(prompt)
    if let text = response.text {
      print(text)
    }
    // [END text_gen_text_only_prompt]
  }

  func testTextOnlyPromptStreaming() async throws {
    // [START text_gen_text_only_prompt_streaming]
    let generativeModel =
      GenerativeModel(
        // Specify a Gemini model appropriate for your use case
        name: "gemini-1.5-flash",
        // Access your API key from your on-demand resource .plist file (see "Set up your API key"
        // above)
        apiKey: APIKey.default
      )

    let prompt = "Write a story about a magic backpack."
    // Use streaming with text-only input
    for try await response in generativeModel.generateContentStream(prompt) {
      if let text = response.text {
        print(text)
      }
    }
    // [END text_gen_text_only_prompt_streaming]
  }

  func testMultimodalOneImagePrompt() async throws {
    // [START text_gen_multimodal_one_image_prompt]
    let generativeModel =
      GenerativeModel(
        // Specify a Gemini model appropriate for your use case
        name: "gemini-1.5-flash",
        // Access your API key from your on-demand resource .plist file (see "Set up your API key"
        // above)
        apiKey: APIKey.default
      )

    #if canImport(UIKit)
      guard let image = UIImage(systemName: "cloud.sun") else { fatalError() }
    #elseif canImport(AppKit)
      guard let image = NSImage(systemSymbolName: "cloud.sun", accessibilityDescription: nil)
      else { fatalError() }
    #endif

    let prompt = "What's in this picture?"

    let response = try await generativeModel.generateContent(image, prompt)
    if let text = response.text {
      print(text)
    }
    // [END text_gen_multimodal_one_image_prompt]
  }
}
