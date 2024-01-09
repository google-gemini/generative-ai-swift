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

import CoreGraphics
import CoreImage
import XCTest
#if canImport(UIKit)
  import UIKit
#else
  import AppKit
#endif

final class PartsRepresentableTests: XCTestCase {
  func testModelContentFromCGImageIsNotEmpty() throws {
    // adapted from https://forums.swift.org/t/creating-a-cgimage-from-color-array/18634/2
    var srgbArray = [UInt32](repeating: 0xFFFF_FFFF, count: 8 * 8)
    let image = srgbArray.withUnsafeMutableBytes { ptr -> CGImage in
      let ctx = CGContext(
        data: ptr.baseAddress,
        width: 8,
        height: 8,
        bitsPerComponent: 8,
        bytesPerRow: 4 * 8,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
          CGImageAlphaInfo.premultipliedFirst.rawValue
      )!
      return ctx.makeImage()!
    }
    let modelContent = image.partsValue
    XCTAssert(modelContent.count > 0, "Expected non-empty model content for CGImage: \(image)")
  }

  func testModelContentFromCIImageIsNotEmpty() throws {
    let image = CIImage(color: CIColor.red)
      .cropped(to: CGRect(origin: CGPointZero, size: CGSize(width: 16, height: 16)))
    let modelContent = image.partsValue
    XCTAssert(modelContent.count > 0, "Expected non-empty model content for CGImage: \(image)")
  }

  #if canImport(UIKit)
    func testModelContentFromUIImageIsNotEmpty() throws {
      let coreImage = CIImage(color: CIColor.red)
        .cropped(to: CGRect(origin: CGPointZero, size: CGSize(width: 16, height: 16)))
      let image = UIImage(ciImage: coreImage)
      let modelContent = image.partsValue
      XCTAssert(modelContent.count > 0, "Expected non-empty model content for UIImage: \(image)")
    }
  #else
    func testModelContentFromNSImageIsNotEmpty() throws {
      let coreImage = CIImage(color: CIColor.red)
        .cropped(to: CGRect(origin: CGPointZero, size: CGSize(width: 16, height: 16)))
      let rep = NSCIImageRep(ciImage: coreImage)
      let image = NSImage(size: rep.size)
      image.addRepresentation(rep)
      let modelContent = image.partsValue
      XCTAssert(modelContent.count > 0, "Expected non-empty model content for NSImage: \(image)")
    }
  #endif
}
