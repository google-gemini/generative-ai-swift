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

extension RPCError {
  func isInvalidAPIKeyError() -> Bool {
    return errorInfo?.reason == "API_KEY_INVALID"
  }

  func isUnsupportedUserLocationError() -> Bool {
    return message == RPCErrorMessage.unsupportedUserLocation.rawValue
  }
}

enum RPCErrorMessage: String {
  case unsupportedUserLocation = "User location is not supported for the API use."
}

enum InvalidCandidateError: Error {
  case emptyContent(underlyingError: Error)
  case malformedContent(underlyingError: Error)
}
