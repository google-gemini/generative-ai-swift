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
import InternalGenerativeAI

/// A type describing data in media formats interpretable by an AI model. Each generative AI
/// request or response contains an `Array` of ``ModelContent``s, and each ``ModelContent`` value
/// may comprise multiple heterogeneous ``ModelContent/Part``s.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct ModelContent: Equatable {
  /// A discrete piece of data in a media format intepretable by an AI model. Within a single value
  /// of ``Part``, different data types may not mix.
  public enum Part: Equatable {
    /// Text value.
    case text(String)

    /// Data with a specified media type. Not all media types may be supported by the AI model.
    case data(mimetype: String, Data)

    // MARK: Convenience Initializers

    /// Convenience function for populating a Part with JPEG data.
    public static func jpeg(_ data: Data) -> Self {
      return .data(mimetype: "image/jpeg", data)
    }

    /// Convenience function for populating a Part with PNG data.
    public static func png(_ data: Data) -> Self {
      return .data(mimetype: "image/png", data)
    }

    /// Returns the text contents of this ``Part``, if it contains text.
    public var text: String? {
      switch self {
      case let .text(contents): return contents
      default: return nil
      }
    }

    init(internalPart: InternalGenerativeAI.ModelContent.Part) {
      switch internalPart {
      case let .text(text):
        self = .text(text)
      case let .data(mimetype: mimetype, data):
        self = .data(mimetype: mimetype, data)
      }
    }

    func toInternal() -> InternalGenerativeAI.ModelContent.Part {
      switch self {
      case let .text(text):
        return InternalGenerativeAI.ModelContent.Part.text(text)
      case let .data(mimetype: mimetype, data):
        return InternalGenerativeAI.ModelContent.Part.data(mimetype: mimetype, data)
      }
    }
  }

  /// The role of the entity creating the ``ModelContent``. For user-generated client requests,
  /// for example, the role is `user`.
  public let role: String?

  /// The data parts comprising this ``ModelContent`` value.
  public let parts: [Part]

  /// Creates a new value from any data or `Array` of data interpretable as a
  /// ``Part``. See ``ThrowingPartsRepresentable`` for types that can be interpreted as `Part`s.
  public init(role: String? = "user", parts: some ThrowingPartsRepresentable) throws {
    self.role = role
    try self.parts = parts.tryPartsValue()
  }

  /// Creates a new value from any data or `Array` of data interpretable as a
  /// ``Part``. See ``ThrowingPartsRepresentable`` for types that can be interpreted as `Part`s.
  public init(role: String? = "user", parts: some PartsRepresentable) {
    self.role = role
    self.parts = parts.partsValue
  }

  /// Creates a new value from a list of ``Part``s.
  public init(role: String? = "user", parts: [Part]) {
    self.role = role
    self.parts = parts
  }

  /// Creates a new value from any data interpretable as a ``Part``. See
  /// ``ThrowingPartsRepresentable``
  /// for types that can be interpreted as `Part`s.
  public init(role: String? = "user", _ parts: any ThrowingPartsRepresentable...) throws {
    let content = try parts.flatMap { try $0.tryPartsValue() }
    self.init(role: role, parts: content)
  }

  /// Creates a new value from any data interpretable as a ``Part``. See
  /// ``ThrowingPartsRepresentable``
  /// for types that can be interpreted as `Part`s.
  public init(role: String? = "user", _ parts: [PartsRepresentable]) {
    let content = parts.flatMap { $0.partsValue }
    self.init(role: role, parts: content)
  }

  init(internalContent: InternalGenerativeAI.ModelContent) {
    let parts: [Part] = internalContent.parts.map { ModelContent.Part(internalPart: $0) }
    self.init(role: internalContent.role, parts: parts)
  }

  func toInternal() -> InternalGenerativeAI.ModelContent {
    let parts = self.parts.map { $0.toInternal() }
    return InternalGenerativeAI.ModelContent(role: role, parts: parts)
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension [ModelContent] {
  func toInternal() -> [InternalGenerativeAI.ModelContent] {
    return self.map { $0.toInternal() }
  }
}
