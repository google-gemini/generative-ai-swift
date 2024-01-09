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

/// A protocol describing any data that could be serialized to model-interpretable input data,
/// where the serialization process might fail with an error.
public protocol PartsRepresentable {
  associatedtype ErrorType where ErrorType: Error
  func toModelContentParts() -> Result<[ModelContent.Part], ErrorType>
}

public extension PartsRepresentable {
  var partsValue: [ModelContent.Part] {
    let content = toModelContentParts()
    switch content {
    case .success(let success):
      return success
    case .failure(let failure):
      Logging.default
          .error("Error converting \(type(of: self)) value to model content parts: \(failure)")
      return []
    }
  }
}

/// Enables a `String` to be passed in as ``PartsRepresentable``.
extension String: PartsRepresentable {
  public typealias ErrorType = Never

  public func toModelContentParts() -> Result<[ModelContent.Part], Never> {
    return .success([.text(self)])
  }
}

/// Enables a ``ModelContent.Part`` to be passed in as ``PartsRepresentable``.
extension ModelContent.Part: PartsRepresentable {
  public typealias ErrorType = Never
  public func toModelContentParts() -> Result<[ModelContent.Part], Never> {
    return .success([self])
  }
}

/// Enable an `Array` of ``PartsRepresentable`` values to be passed in as a single
/// ``PartsRepresentable``.
extension [any PartsRepresentable]: PartsRepresentable {
  public typealias ErrorType = Never
  public func toModelContentParts() -> Result<[ModelContent.Part], Never> {
    return .success(flatMap { $0.partsValue })
  }
}

/// An enum describing failures that can occur when converting image types to model content data.
/// For some image types like `CIImage`, creating valid model content requires creating a JPEG
/// representation of the image that may not yet exist, which may be computationally expensive.
public enum ImageConversionError: Error {

  /// The underlying image was invalid. The error will be accompanied by the actual image object.
  case invalidUnderlyingImage(Any)

  /// A valid image destination could not be constructed.
  case couldNotAllocateDestination

  /// JPEG image data conversion failed, accompanied by the original image.
  case couldNotConvertToJPEG(Any)
}

#if canImport(UIKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension UIImage: PartsRepresentable {

    public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
      guard let data = jpegData(compressionQuality: imageCompressionQuality) else {
        return .failure(.couldNotConvertToJPEG(self))
      }
      return .success([ModelContent.Part.data(mimetype: "image/jpeg", data)])
    }
  }

#elseif canImport(AppKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension NSImage: PartsRepresentable {
    public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
      guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return .failure(.invalidUnderlyingImage(self))
      }
      let bmp = NSBitmapImageRep(cgImage: cgImage)
      guard let data = bmp.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
      else {
        return .failure(.couldNotConvertToJPEG(bmp))
      }
      return .success([ModelContent.Part.data(mimetype: "image/jpeg", data)])
    }
  }
#endif

extension CGImage: PartsRepresentable {
  public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
    let output = NSMutableData()
    guard let imageDestination = CGImageDestinationCreateWithData(
      output, UTType.jpeg.identifier as CFString, 1, nil
    ) else {
      return .failure(.couldNotAllocateDestination)
    }
    CGImageDestinationAddImage(imageDestination, self, nil)
    CGImageDestinationSetProperties(imageDestination, [
      kCGImageDestinationLossyCompressionQuality: imageCompressionQuality,
    ] as CFDictionary)
    if CGImageDestinationFinalize(imageDestination) {
      return .success([.data(mimetype: "image/jpeg", output as Data)])
    }
    return .failure(.couldNotConvertToJPEG(self))
  }
}

extension CIImage: PartsRepresentable {
  public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
    let context = CIContext()
    let jpegData = (colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB))
      .flatMap {
        // The docs specify kCGImageDestinationLossyCompressionQuality as a supported option, but
        // Swift's type system does not allow this.
        // [kCGImageDestinationLossyCompressionQuality: imageCompressionQuality]
        context.jpegRepresentation(of: self, colorSpace: $0, options: [:])
      }
    if let jpegData = jpegData {
      return .success([.data(mimetype: "image/jpeg", jpegData)])
    }
    return .failure(.couldNotConvertToJPEG(self))
  }
}
