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
import OSLog
import PhotosUI
import SwiftUI

@MainActor
class PhotoReasoningViewModel: ObservableObject {
  // Maximum image dimensions in pixels; reduces image size in bytes.
  private static let maxImageSize = CGSize(width: 768.0, height: 768.0)

  private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "generative-ai")

  @Published
  var userInput: String = ""

  @Published
  var selectedItems = [PhotosPickerItem]()

  @Published
  var outputText: String? = nil

  @Published
  var errorMessage: String?

  @Published
  var inProgress = false

  private var model: GenerativeModel?

  init() {
    model = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.default)
  }

  func reason() async {
    defer {
      inProgress = false
    }
    guard let model else {
      return
    }

    do {
      inProgress = true
      errorMessage = nil
      outputText = ""

      let prompt = "Look at the image(s), and then answer the following question: \(userInput)"

      var images = [PartsRepresentable]()
      for item in selectedItems {
        if let data = try? await item.loadTransferable(type: Data.self) {
          guard let image = UIImage(data: data) else {
            logger.error("Failed to parse data as an image, skipping.")
            continue
          }
          guard let resizedImage = image
            .preparingThumbnail(of: PhotoReasoningViewModel.maxImageSize) else {
            logger.error("Failed to resize image: \(image)")
            continue
          }

          images.append(resizedImage)
        }
      }

      let outputContentStream = model.generateContentStream(prompt, images)

      // stream response
      for try await outputContent in outputContentStream {
        guard let line = outputContent.text else {
          return
        }

        outputText = (outputText ?? "") + line
      }
    } catch {
      logger.error("\(error.localizedDescription)")
      errorMessage = error.localizedDescription
    }
  }
}

private extension CGSize {
  func fitting(maxSize: CGSize) -> CGSize {
    if width <= maxSize.width && height <= maxSize.height {
      return self
    } else {
      let width = min(self.width * maxSize.height / height, maxSize.width)
      return CGSize(width: width, height: height * width / self.width)
    }
  }
}
