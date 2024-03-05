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

import Foundation

/// A predicted function call returned from the model.
public struct FunctionCall: Equatable {
  /// The name of the function to call.
  let name: String

  /// The function parameters and values.
  let args: JSONObject
}

extension FunctionCall: Decodable {
  enum CodingKeys: CodingKey {
    case name
    case args
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    if let args = try container.decodeIfPresent(JSONObject.self, forKey: .args) {
      self.args = args
    } else {
      args = JSONObject()
    }
  }
}
