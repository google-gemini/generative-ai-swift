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
import UniformTypeIdentifiers
#if canImport(UIKit)
  import UIKit // For UIImage extensions.
#elseif canImport(AppKit)
  import AppKit // For NSImage extensions.
#endif

private let imageCompressionQuality: CGFloat = 0.8

/// A protocol describing any data that could be interpreted as model input data.
public protocol PartsRepresentable {
  var partsValue: [ModelContent.Part] { get }
}

/// Enables a `String` to be passed in as ``PartsRepresentable``.
extension String: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return [.text(self)]
  }
}

/// Enables a ``ModelContent.Part`` to be passed in as ``PartsRepresentable``.
extension ModelContent.Part: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return [self]
  }
}

/// Enable an `Array` of ``PartsRepresentable`` values to be passed in as a single
/// ``PartsRepresentable``.
extension [any PartsRepresentable]: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return flatMap { $0.partsValue }
  }
}

#if canImport(UIKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension UIImage: PartsRepresentable {
    public var partsValue: [ModelContent.Part] {
      guard let data = jpegData(compressionQuality: imageCompressionQuality) else {
        Logging.default.error("[GoogleGenerativeAI] Couldn't create JPEG from UIImage.")
        return []
      }

      return [ModelContent.Part.data(mimetype: "image/jpeg", data)]
    }
  }

#elseif canImport(AppKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension NSImage: PartsRepresentable {
    public var partsValue: [ModelContent.Part] {
      guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        Logging.default.error("[GoogleGenerativeAI] Couldn't create CGImage from NSImage.")
        return []
      }
      let bmp = NSBitmapImageRep(cgImage: cgImage)
      guard let data = bmp.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
      else {
        Logging.default.error("[GoogleGenerativeAI] Couldn't create BMP from CGImage.")
        return []
      }
      return [ModelContent.Part.data(mimetype: "image/jpeg", data)]
    }
  }
#endif

extension CGImage: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    let output = NSMutableData()
    guard let imageDestination = CGImageDestinationCreateWithData(
      output, UTType.jpeg.identifier as CFString, 1, nil
    ) else {
      Logging.default.error("[GoogleGenerativeAI] Couldn't create JPEG from CGImage.")
      return []
    }
    CGImageDestinationAddImage(imageDestination, self, nil)
    CGImageDestinationSetProperties(imageDestination, [
      kCGImageDestinationLossyCompressionQuality: imageCompressionQuality,
    ] as CFDictionary)
    if CGImageDestinationFinalize(imageDestination) {
      return [.data(mimetype: "image/jpeg", output as Data)]
    }
    Logging.default.error("[GoogleGenerativeAI] Couldn't create JPEG from CGImage.")
    return []
  }
}

extension CIImage: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    let context = CIContext()
    let jpegData = (colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB))
      .flatMap {
        // The docs specify kCGImageDestinationLossyCompressionQuality as a supported option, but
        // Swift's type system does not allow this.
        // [kCGImageDestinationLossyCompressionQuality: imageCompressionQuality]
        context.jpegRepresentation(of: self, colorSpace: $0, options: [:])
      }
    if let jpegData = jpegData {
      return [.data(mimetype: "image/jpeg", jpegData)]
    }
    Logging.default.error("[GoogleGenerativeAI] Couldn't create JPEG from CIImage.")
    return []
  }
}
