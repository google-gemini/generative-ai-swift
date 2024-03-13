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

/// The model's response to a generate content request.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct GenerateContentResponse {
  /// A list of candidate response content, ordered from best to worst.
  public let candidates: [CandidateResponse]

  /// A value containing the safety ratings for the response, or, if the request was blocked, a
  /// reason for blocking the request.
  public let promptFeedback: PromptFeedback?

  /// The response's content as text, if it exists.
  public var text: String? {
    guard let candidate = candidates.first else {
      Logging.default.error("Could not get text from a response that had no candidates.")
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

  init(internalResponse: InternalGenerativeAI.GenerateContentResponse) {
    self.init(
      candidates: internalResponse.candidates.map { CandidateResponse(internalResponse: $0) },
      promptFeedback: internalResponse.promptFeedback
        .flatMap { PromptFeedback(internalFeedback: $0) }
    )
  }
}

/// A struct representing a possible reply to a content generation prompt. Each content generation
/// prompt may produce multiple candidate responses.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct CandidateResponse {
  /// The response's content.
  public let content: ModelContent

  /// The safety rating of the response content.
  public let safetyRatings: [SafetyRating]

  /// The reason the model stopped generating content, if it exists; for example, if the model
  /// generated a predefined stop sequence.
  public let finishReason: FinishReason?

  /// Cited works in the model's response content, if it exists.
  public let citationMetadata: CitationMetadata?

  /// Initializer for SwiftUI previews or tests.
  public init(content: ModelContent, safetyRatings: [SafetyRating], finishReason: FinishReason?,
              citationMetadata: CitationMetadata?) {
    self.content = content
    self.safetyRatings = safetyRatings
    self.finishReason = finishReason
    self.citationMetadata = citationMetadata
  }

  init(internalResponse: InternalGenerativeAI.CandidateResponse) {
    content = ModelContent(internalContent: internalResponse.content)
    safetyRatings = internalResponse.safetyRatings.map { SafetyRating(internalSafetyRating: $0) }
    finishReason = internalResponse.finishReason.flatMap { FinishReason(internalReason: $0) }
    citationMetadata = internalResponse.citationMetadata
      .flatMap { CitationMetadata(internalMetadata: $0) }
  }
}

/// A collection of source attributions for a piece of content.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct CitationMetadata {
  /// A list of individual cited sources and the parts of the content to which they apply.
  public let citationSources: [Citation]

  init(internalMetadata: InternalGenerativeAI.CitationMetadata) {
    citationSources = internalMetadata.citationSources.map { Citation(internalCitation: $0) }
  }
}

/// A struct describing a source attribution.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct Citation {
  /// The inclusive beginning of a sequence in a model response that derives from a cited source.
  public let startIndex: Int

  /// The exclusive end of a sequence in a model response that derives from a cited source.
  public let endIndex: Int

  /// A link to the cited source.
  public let uri: String

  /// The license the cited source work is distributed under.
  public let license: String

  init(internalCitation: InternalGenerativeAI.Citation) {
    startIndex = internalCitation.startIndex
    endIndex = internalCitation.endIndex
    uri = internalCitation.uri
    license = internalCitation.license
  }
}

/// A value enumerating possible reasons for a model to terminate a content generation request.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public enum FinishReason {
  case unknown

  case unspecified

  /// Natural stop point of the model or provided stop sequence.
  case stop

  /// The maximum number of tokens as specified in the request was reached.
  case maxTokens

  /// The token generation was stopped because the response was flagged for safety reasons.
  /// NOTE: When streaming, the Candidate.content will be empty if content filters blocked the
  /// output.
  case safety

  /// The token generation was stopped because the response was flagged for unauthorized citations.
  case recitation

  /// All other reasons that stopped token generation.
  case other

  init(internalReason: InternalGenerativeAI.FinishReason) {
    switch internalReason {
    case .unknown:
      self = .unknown
    case .unspecified:
      self = .unspecified
    case .stop:
      self = .stop
    case .maxTokens:
      self = .maxTokens
    case .safety:
      self = .safety
    case .recitation:
      self = .recitation
    case .other:
      self = .other
    }
  }
}

/// A metadata struct containing any feedback the model had on the prompt it was provided.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct PromptFeedback {
  /// A type describing possible reasons to block a prompt.
  public enum BlockReason {
    /// The block reason is unknown.
    case unknown

    /// The block reason was not specified in the server response.
    case unspecified

    /// The prompt was blocked because it was deemed unsafe.
    case safety

    /// All other block reasons.
    case other

    init(internalReason: InternalGenerativeAI.PromptFeedback.BlockReason) {
      switch internalReason {
      case .unknown:
        self = .unknown
      case .unspecified:
        self = .unspecified
      case .safety:
        self = .safety
      case .other:
        self = .other
      }
    }
  }

  /// The reason a prompt was blocked, if it was blocked.
  public let blockReason: BlockReason?

  /// The safety ratings of the prompt.
  public let safetyRatings: [SafetyRating]

  /// Initializer for SwiftUI previews or tests.
  public init(blockReason: BlockReason?, safetyRatings: [SafetyRating]) {
    self.blockReason = blockReason
    self.safetyRatings = safetyRatings
  }

  init(internalFeedback: InternalGenerativeAI.PromptFeedback) {
    self.init(
      blockReason: internalFeedback.blockReason.flatMap { BlockReason(internalReason: $0) },
      safetyRatings: internalFeedback.safetyRatings.map { SafetyRating(internalSafetyRating: $0) }
    )
  }
}
