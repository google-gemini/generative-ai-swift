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
  func chat(prompt: String, context: String?, examples: [Example]?, model: String, temperature: Float, candidateCount: Int) async throws -> GenerateMessageResponse?
  func chat(messages: [Message], context: String?, examples: [Example]?, model: String, temperature: Float, candidateCount: Int) async throws -> GenerateMessageResponse?
  func listModels() async throws -> ListModelsResponse?
  func getModel(name: String) async throws -> Model?
}
