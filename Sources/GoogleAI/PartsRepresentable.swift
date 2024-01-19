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

/// A protocol describing any data that could be serialized to model-interpretable input data,
/// where the serialization process might fail with an error.
public protocol PartsRepresentable {
  associatedtype ErrorType where ErrorType: Error
  func toModelContentParts() -> Result<[ModelContent.Part], ErrorType>
}

public extension PartsRepresentable {

  func tryPartsValue() throws -> [ModelContent.Part] {
    return try toModelContentParts().get()
  }

}

public extension PartsRepresentable where ErrorType == Never {

  var partsValue: [ModelContent.Part] {
    let content = toModelContentParts()
    switch content {
    case let .success(success):
      return success
    }
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
  public typealias ErrorType = Error

  public func toModelContentParts() -> Result<[ModelContent.Part], Error> {
    let result = { () throws -> [ModelContent.Part] in
      try compactMap { element in
        return try element.tryPartsValue()
      }
      .flatMap({ $0 })
    }
    return Result(catching: result)
  }
}

/// Enables a `String` to be passed in as ``PartsRepresentable``.
extension String: PartsRepresentable {
  public typealias ErrorType = Never

  public func toModelContentParts() -> Result<[ModelContent.Part], Never> {
    return .success([.text(self)])
  }
}
