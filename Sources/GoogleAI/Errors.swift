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

struct ServerError: Error {
  enum ErrorDetails {
    case badRequest(BadRequest)
    case errorInfo(ErrorInfo)
    case unknown(String)

    struct BadRequest {
      static let type = "type.googleapis.com/google.rpc.BadRequest"

      struct FieldViolation: Decodable {
        let field: String?
        let description: String?
      }

      let type: String
      let fieldViolations: [FieldViolation]
    }

    struct ErrorInfo {
      static let type = "type.googleapis.com/google.rpc.ErrorInfo"

      let type: String
      let reason: String?
      let domain: String?
    }
  }

  enum Status: String, Decodable {
    // Not an error; returned on success.
    case ok = "OK"

    // The operation was cancelled, typically by the caller.
    case cancelled = "CANCELLED"

    // Unknown error.
    case unknown = "UNKNOWN"

    // The client specified an invalid argument.
    case invalidArgument = "INVALID_ARGUMENT"

    // The deadline expired before the operation could complete.
    case deadlineExceeded = "DEADLINE_EXCEEDED"

    // Some requested entity (e.g., file or directory) was not found.
    case notFound = "NOT_FOUND"

    // The entity that a client attempted to create (e.g., file or directory) already exists.
    case alreadyExists = "ALREADY_EXISTS"

    // The caller does not have permission to execute the specified operation.
    case permissionDenied = "PERMISSION_DENIED"

    // The request does not have valid authentication credentials for the operation.
    case unauthenticated = "UNAUTHENTICATED"

    // Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system
    // is out of space.
    case resourceExhausted = "RESOURCE_EXHAUSTED"

    // The operation was rejected because the system is not in a state required for the operation's
    // execution.
    case failedPrecondition = "FAILED_PRECONDITION"

    // The operation was aborted, typically due to a concurrency issue such as a sequencer check
    // failure or transaction abort.
    case aborted = "ABORTED"

    // The operation was attempted past the valid range.
    case outOfRange = "OUT_OF_RANGE"

    // The operation is not implemented or is not supported/enabled in this service.
    case unimplemented = "UNIMPLEMENTED"

    // Internal errors.
    case internalError = "INTERNAL"

    // The service is currently unavailable.
    case unavailable = "UNAVAILABLE"

    // Unrecoverable data loss or corruption.
    case dataLoss = "DATA_LOSS"
  }

  let code: Int
  let message: String
  let status: Status
  let details: [ErrorDetails]

  init(httpResponseCode: Int, message: String, status: Status, details: [ErrorDetails]) {
    code = httpResponseCode
    self.message = message
    self.status = status
    self.details = details
  }

  func isInvalidAPIKeyError() -> Bool {
    return details.contains { errorDetails in
      switch errorDetails {
      case let .errorInfo(errorInfo):
        return errorInfo.reason == "API_KEY_INVALID"
      default:
        return false
      }
    }
  }

  func isUnsupportedUserLocationError() -> Bool {
    return message == RPCErrorMessage.unsupportedUserLocation.rawValue
  }
}

enum InvalidCandidateError: Error {
  case emptyContent(underlyingError: Error)
  case malformedContent(underlyingError: Error)
}

// MARK: - Decodable Conformance

extension ServerError: Decodable {
  enum CodingKeys: CodingKey {
    case error
  }

  struct ErrorStatus {
    let code: Int?
    let message: String?
    let status: ServerError.Status?
    let details: [ServerError.ErrorDetails]
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let status = try container.decode(ErrorStatus.self, forKey: .error)

    if let code = status.code {
      self.code = code
    } else {
      code = -1
    }

    if let message = status.message {
      self.message = message
    } else {
      message = "Unknown error."
    }

    if let rpcStatus = status.status {
      self.status = rpcStatus
    } else {
      self.status = .unknown
    }

    details = status.details
  }
}

extension ServerError.ErrorStatus: Decodable {
  enum CodingKeys: CodingKey {
    case code
    case message
    case status
    case details
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(Int.self, forKey: .code)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    do {
      status = try container.decodeIfPresent(ServerError.Status.self, forKey: .status)
    } catch {
      status = .unknown
    }
    if container.contains(.details) {
      details = try container.decode([ServerError.ErrorDetails].self, forKey: .details)
    } else {
      details = []
    }
  }
}

extension ServerError.ErrorDetails: Decodable {
  enum CodingKeys: String, CodingKey {
    case type = "@type"
  }

  init(from decoder: Decoder) throws {
    let errorDetailsContainer = try decoder.container(keyedBy: CodingKeys.self)
    let type = try errorDetailsContainer.decode(String.self, forKey: .type)
    if type == BadRequest.type {
      let badRequestContainer = try decoder.singleValueContainer()
      let badRequest = try badRequestContainer.decode(BadRequest.self)
      self = ServerError.ErrorDetails.badRequest(badRequest)
    } else if type == ErrorInfo.type {
      let errorInfoContainer = try decoder.singleValueContainer()
      let errorInfo = try errorInfoContainer.decode(ErrorInfo.self)
      self = ServerError.ErrorDetails.errorInfo(errorInfo)
    } else {
      self = ServerError.ErrorDetails.unknown(type)
    }
  }
}

extension ServerError.ErrorDetails.BadRequest: Decodable {
  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case fieldViolations
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    fieldViolations = try container.decode([FieldViolation].self, forKey: .fieldViolations)
  }
}

extension ServerError.ErrorDetails.ErrorInfo: Decodable {
  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case reason
    case domain
  }
}

// MARK: - Private

private enum RPCErrorMessage: String {
  case unsupportedUserLocation = "User location is not supported for the API use."
}
