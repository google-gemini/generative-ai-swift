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

public struct GenerateContentResponse {
  public let candidates: [CandidateResponse]

  public let promptFeedback: PromptFeedback?

  public var text: String? {
    guard let candidate = candidates.first else {
      Logging.default.error("Could not get text a response that had no candidates.")
      return nil
    }
    guard let text = candidate.content.parts.first?.text else {
      Logging.default.error("Could not get a text part from the first candidate.")
      return nil
    }
    return text
  }

  /// Initializer for SwiftUI previews or tests.
  public init(candidates: [CandidateResponse], promptFeedback: PromptFeedback?) {
    self.candidates = candidates
    self.promptFeedback = promptFeedback
  }
}

extension GenerateContentResponse: Decodable {
  enum CodingKeys: CodingKey {
    case candidates
    case promptFeedback
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    guard container.contains(CodingKeys.candidates) || container
      .contains(CodingKeys.promptFeedback) else {
      let context = DecodingError.Context(
        codingPath: [],
        debugDescription: "Failed to decode GenerateContentResponse;" +
          " missing keys 'candidates' and 'promptFeedback'."
      )
      throw DecodingError.dataCorrupted(context)
    }

    if let candidates = try container.decodeIfPresent(
      [CandidateResponse].self,
      forKey: .candidates
    ) {
      self.candidates = candidates
    } else {
      candidates = []
    }
    promptFeedback = try container.decodeIfPresent(PromptFeedback.self, forKey: .promptFeedback)
  }
}

public struct CandidateResponse {
  public let content: ModelContent
  public let safetyRatings: [SafetyRating]

  public let finishReason: FinishReason?

  public let citationMetadata: CitationMetadata?

  /// Initializer for SwiftUI previews or tests.
  public init(content: ModelContent, safetyRatings: [SafetyRating], finishReason: FinishReason?,
              citationMetadata: CitationMetadata?) {
    self.content = content
    self.safetyRatings = safetyRatings
    self.finishReason = finishReason
    self.citationMetadata = citationMetadata
  }
}

extension CandidateResponse: Decodable {
  enum CodingKeys: CodingKey {
    case content
    case safetyRatings
    case finishReason
    case finishMessage
    case citationMetadata
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    do {
      if let content = try container.decodeIfPresent(ModelContent.self, forKey: .content) {
        self.content = content
      } else {
        content = ModelContent(parts: [])
      }
    } catch {
      // Check if `content` can be decoded as an empty dictionary to detect the `"content": {}` bug.
      if let content = try? container.decode([String: String].self, forKey: .content),
         content.isEmpty {
        throw InvalidCandidateError.emptyContent(underlyingError: error)
      } else {
        throw InvalidCandidateError.malformedContent(underlyingError: error)
      }
    }

    if let safetyRatings = try container.decodeIfPresent(
      [SafetyRating].self,
      forKey: .safetyRatings
    ) {
      self.safetyRatings = safetyRatings
    } else {
      safetyRatings = []
    }

    finishReason = try container.decodeIfPresent(FinishReason.self, forKey: .finishReason)

    citationMetadata = try container.decodeIfPresent(
      CitationMetadata.self,
      forKey: .citationMetadata
    )
  }
}

/// A collection of source attributions for a piece of content.
public struct CitationMetadata: Decodable {
  public let citationSources: [Citation]
}

public struct Citation: Decodable {
  public let startIndex: Int
  public let endIndex: Int
  public let uri: String
  public let license: String
}

public enum FinishReason: String {
  case unknown = "FINISH_REASON_UNKNOWN"

  case unspecified = "FINISH_REASON_UNSPECIFIED"

  /// Natural stop point of the model or provided stop sequence.
  case stop = "STOP"

  /// The maximum number of tokens as specified in the request was reached.
  case maxTokens = "MAX_TOKENS"

  /// The token generation was stopped as the response was flagged for safety reasons.
  /// NOTE: When streaming, the Candidate.content will be empty if content filters blocked the
  /// output.
  case safety = "SAFETY"
  case recitation = "RECITATION"
  case other = "OTHER"
}

extension FinishReason: Decodable {
  /// Do not explicitly use. Initializer required for Decodable conformance.
  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    guard let decodedFinishReason = FinishReason(rawValue: value) else {
      Logging.default
        .error("[GoogleGenerativeAI] Unrecognized FinishReason with value \"\(value)\".")
      self = .unknown
      return
    }

    self = decodedFinishReason
  }
}

public struct PromptFeedback {
  public enum BlockReason: String, Decodable {
    case unknown = "UNKNOWN"
    case unspecified = "BLOCK_REASON_UNSPECIFIED"
    case safety = "SAFETY"
    case other = "OTHER"

    /// Do not explicitly use. Initializer required for Decodable conformance.
    public init(from decoder: Decoder) throws {
      let value = try decoder.singleValueContainer().decode(String.self)
      guard let decodedBlockReason = BlockReason(rawValue: value) else {
        Logging.default
          .error("[GoogleGenerativeAI] Unrecognized BlockReason with value \"\(value)\".")
        self = .unknown
        return
      }

      self = decodedBlockReason
    }
  }

  public let blockReason: BlockReason?
  public let safetyRatings: [SafetyRating]

  /// Initializer for SwiftUI previews or tests.
  public init(blockReason: BlockReason?, safetyRatings: [SafetyRating]) {
    self.blockReason = blockReason
    self.safetyRatings = safetyRatings
  }
}

extension PromptFeedback: Decodable {
  enum CodingKeys: CodingKey {
    case blockReason
    case safetyRatings
  }

  /// Do not explicitly use. Initializer required for Decodable conformance.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    blockReason = try container.decodeIfPresent(
      PromptFeedback.BlockReason.self,
      forKey: .blockReason
    )
    if let safetyRatings = try container.decodeIfPresent(
      [SafetyRating].self,
      forKey: .safetyRatings
    ) {
      self.safetyRatings = safetyRatings
    } else {
      safetyRatings = []
    }
  }
}
