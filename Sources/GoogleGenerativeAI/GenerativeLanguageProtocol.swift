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

public protocol GenerativeLanguageProtocol {

  /// Generates a chat response from the model.
  /// 
  /// - Parameters:
  ///   - message: The user's message.
  ///   - context: Text that should be provided to the model first to ground the response. If not empty,
  ///     this `context` will be given to the model first before the `examples` and `prompt`. When using
  ///     a `context` be sure to provide it with every request to maintain continuity. This parameter can
  ///     be a description of your prompt to the model to help provide context and guide the responses.
  ///     Examples: \"Translate the phrase from English to French.\" or \"Given a statement, classify the
  ///     sentiment as happy, sad or neutral.\"
  ///     Anything included in this field will take precedence over message history if the total input
  ///     size exceeds the model's `input_token_limit` and the input request is truncated.
  ///   - examples: Examples of what the model should generate. This includes both user input and the
  ///     response that the model should emulate. These `examples` are treated identically to conversation
  ///     messages except that they take precedence over the history in `messages`: If the total input
  ///     size exceeds the model's `input_token_limit` the input will be truncated. Items will be
  ///     dropped from `messages` before `examples`.
  ///   - model: The name of the model to use.
  ///   - temperature: Controls the randomness of the output. Values can range over `[0.0,1.0]`, inclusive.
  ///     A value closer to `1.0` will produce responses that are more varied, while a value closer to `0.0`
  ///     will typically result in less surprising responses from the model.
  ///   - candidateCount: The number of generated response messages to return. This value must be
  ///     between `[1, 10]`, inclusive.
  /// - Returns: A response from the model.
  func chat(message: String, context: String?, examples: [Example]?, model: String, temperature: Float, candidateCount: Int) async throws -> GenerateMessageResponse

  /// Generates a chat response from the model.
  ///
  /// - Parameters:
  ///   - message: The user's message.
  ///   - history: A snapshot of the recent conversation history sorted chronologically. Turns
  ///     alternate between two authors. If the total input size exceeds the model's `input_token_limit`
  ///     the input will be truncated: The oldest items will be dropped from `messages`.
  ///   - context: Text that should be provided to the model first to ground the response. If not empty,
  ///     this `context` will be given to the model first before the `examples` and `prompt`. When using
  ///     a `context` be sure to provide it with every request to maintain continuity. This parameter can
  ///     be a description of your prompt to the model to help provide context and guide the responses.
  ///     Examples: \"Translate the phrase from English to French.\" or \"Given a statement, classify the
  ///     sentiment as happy, sad or neutral.\"
  ///     Anything included in this field will take precedence over message history if the total input
  ///     size exceeds the model's `input_token_limit` and the input request is truncated.
  ///   - examples: Examples of what the model should generate. This includes both user input and the
  ///     response that the model should emulate. These `examples` are treated identically to conversation
  ///     messages except that they take precedence over the history in `messages`: If the total input
  ///     size exceeds the model's `input_token_limit` the input will be truncated. Items will be
  ///     dropped from `messages` before `examples`.
  ///   - model: The name of the model to use.
  ///   - temperature: Controls the randomness of the output. Values can range over `[0.0,1.0]`, inclusive.
  ///     A value closer to `1.0` will produce responses that are more varied, while a value closer to `0.0`
  ///     will typically result in less surprising responses from the model.
  ///   - candidateCount: The number of generated response messages to return. This value must be
  ///     between `[1, 10]`, inclusive.
  /// - Returns: A response from the model.
  func chat(message: String, history: [Message], context: String?, examples: [Example]?, model: String, temperature: Float, candidateCount: Int) async throws -> GenerateMessageResponse

  /// Generates a response from the model given an input message.
  /// - Parameters:
  ///   - prompt: The free-form input text given to the model as a prompt. Given a prompt, the model will
  ///     generate a number of `TextCompletion` candidates it predicts as the completion of the input text.
  ///   - model: The name of the model to use.
  ///   - temperature: Controls the randomness of the output. Note: The default value varies by model, see
  ///     the `temperature` attribute of the `Model` returned the `getModel` method. Values can range
  ///     from [0.0,1.0], inclusive. A value closer to 1.0 will produce responses that are more varied
  ///     and creative, while a value closer to 0.0 will typically result in more straightforward responses
  ///     from the model.
  ///   - candidateCount: Number of generated responses to return. This value must be between [1, 8],
  ///   inclusive. If unset, this will default to 1.
  /// - Returns: A response from the model.
  func generateText(with prompt: String, model: String, temperature: Float, candidateCount: Int) async throws -> GenerateTextResponse

  /// Generates an embedding from the model given an input message.
  /// - Parameters:
  ///   - text: The free-form input text that the model will turn into an embedding.
  ///   - model: The name of the model to use.
  /// - Returns: A response from the model.
  func generateEmbeddings(from text: String, model: String) async throws -> EmbedTextResponse

  /// Lists models available through the API.
  /// - Returns: A list of models.
  func listModels() async throws -> ListModelsResponse

  /// Gets information about a specific Model.
  /// - Parameter name: The model to get information about
  /// - Returns: Information about the model.
  func getModel(name: String) async throws -> Model
}
