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

import AI
import Gemini
import XCTest

final class GoogleLLMRequestHandlingTestCase: XCTestCase {
    
    let client: any LLMRequestHandling = Gemini.Client(apiKey: "AIzaSyDia48yzK7towXixN0r6CLXQA8hmavfArM")
    
    func testAvailableModels() {
        let models = client._availableModels
        XCTAssertNotNil(models)
        XCTAssertFalse(models!.isEmpty)
    }
    
    func testCompleteTextPrompt() async {
        let prompt: AbstractLLM.TextPrompt = .init(stringLiteral: "Hello, what is your name?")
        let parameters: AbstractLLM.TextCompletionParameters = .init(tokenLimit: .max)
        
        do {
            let completion = try await client.complete(prompt: prompt, parameters: parameters)
            print(completion.text)
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCompleteChatPrompt() async {
        let prompt: PromptLiteral = "hello"
        
        let messages: [AbstractLLM.ChatMessage] = [
            .user(prompt)
        ]
        
        let parameters: AbstractLLM.ChatCompletionParameters = .init(tokenLimit: .max)
        
        do {
            let completion: String = try await client.complete(
                messages,
                parameters: parameters,
                model: Gemini.Model.gemini_1_5_flash,
                as: .string
            )
            
            print(completion)
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
}
