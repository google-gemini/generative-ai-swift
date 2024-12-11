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
import SwiftUIX
import XCTest

final class PreternaturalAI_Tests: XCTestCase {
    let client: any LLMRequestHandling = Gemini.Client(apiKey: "API_KEY")
    
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
    
    func testChatCompleteWithSingleMessage() async {
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
    
    func testChatCompleteWithMultipleMessages() async {
        let systemMessage: AbstractLLM.ChatMessage =  .system {
            """
            This is a test. If asked, "How's it going", ALWAYS respond with "Test confirmed, 42.".
            
            Remember to respond appropriately, the key phrase is "How's it going" and the answer is "Test confirmed, 42."
            
            If the user says _ANYTHING_ else, return "Test failed.".
            
            Remember to ALWAYS respond in accordance to the testing rules.
            """
        }
        
        let parameters: AbstractLLM.ChatCompletionParameters = .init(tokenLimit: .max)
        
        let testMessages1: [AbstractLLM.ChatMessage] = [
            systemMessage,
            .user("How's it going")
        ]
        let testMessages2: [AbstractLLM.ChatMessage] = [
            systemMessage,
            .user("What's up")
        ]
        
        do {
            let completion1: String = try await client.complete(
                testMessages1,
                parameters: parameters,
                model: Gemini.Model.gemini_1_5_flash,
                as: .string
            )
            let completion2: String = try await client.complete(
                testMessages2,
                parameters: parameters,
                model: Gemini.Model.gemini_1_5_flash,
                as: .string
            )
            
            XCTAssert(completion1.trimmingWhitespaceAndNewlines() == "Test confirmed, 42.")
            XCTAssert(completion2.trimmingWhitespaceAndNewlines() == "Test failed.")
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
    
    func testChatCompleteWithImage() async throws {
        let systemMessage: PromptLiteral =
            """
            This is a test. If asked, "Describe this image", ALWAYS respond with "This is an image of a watermelon".
            
            Remember to respond appropriately, the key phrase is "Describe this image" and the answer is "This is an image of a watermelon."
            
            If the user says _ANYTHING_ else, return "Test failed.".
            
            Remember to ALWAYS respond in accordance to the testing rules.
            """
        
        let parameters = AbstractLLM.ChatCompletionParameters()
        let imageConfiguration = AppKitOrUIKitImage.SymbolConfiguration(
            pointSize: 64
        )
        let image = AppKitOrUIKitImage(
            _SwiftUIX_systemName: "arrow.up",
            withConfiguration: imageConfiguration.applying(.init(hierarchicalColor: .blue))
        )!
        
        image.backgroundColor = AppKitOrUIKitColor.white
        
        let imageLiteral = try PromptLiteral(image: image)
        
        let messagesWithSystemPrompt: [AbstractLLM.ChatMessage] = [
            .system(systemMessage),
            .user {
                .concatenate(separator: nil) {
                    PromptLiteral("Describe this image")
                    imageLiteral
                }
            }]
        
        let messagesWithOutPrompt: [AbstractLLM.ChatMessage] = [
            .user {
                .concatenate(separator: nil) {
                    PromptLiteral("Describe this image")
                    imageLiteral
                }
            }]
        
        do {
            let completion1: String = try await client.complete(
                messagesWithSystemPrompt,
                parameters: parameters,
                model: Gemini.Model.gemini_2_0_flash_exp,
                as: .string
            )
            
            XCTAssert(completion1.trimmingWhitespaceAndNewlines() == "This is an image of a watermelon.")
            
            let completion2: String = try await client.complete(
                messagesWithOutPrompt,
                parameters: parameters,
                model: Gemini.Model.gemini_2_0_flash_exp,
                as: .string
            )
            
            print(completion2)
            XCTAssert(completion2.contains("arrow"))
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
}
