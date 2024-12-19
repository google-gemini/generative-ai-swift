//
//  Untitled.swift
//  Gemini
//
//  Created by Jared Davidson on 12/13/24.
//

import AI
import CorePersistence
import Gemini
import Testing

@Suite struct GeminiCodeExecutionTests {
    
    @Test
    func testAbstractLLMCodeExecution() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a helpful coding assistant. When asked to solve problems, you should write and execute code to find the answer."
            },
            .user {
                "What is the sum of the first 50 prime numbers? Write and execute Python code to calculate this."
            }
        ]
        
        let completion = try await client._complete(
            messages,
            codeExecution: true,
            model: .gemini_1_5_pro_latest
        )
        
        let messageContent = try completion.message.content._stripToText()
        
        #expect(!messageContent.isEmpty, "Response should not be empty")
        #expect(messageContent.contains("```python"), "Should contain Python code block")
        #expect(messageContent.contains("```"), "Should have code block formatting")
        #expect(messageContent.contains("5117"), "Should contain correct sum of first 50 primes")
        #expect(messageContent.contains("Output") || messageContent.contains("Result"),
                "Should contain execution output")
    }
    
    @Test
    func testBasicCodeExecution() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a helpful coding assistant. When asked to solve problems, you should write and execute code to find the answer."
            },
            .user {
                "What is the sum of the first 50 prime numbers? Write and execute Python code to calculate this."
            }
        ]
        
        let model = GenerativeModel(
            name: "gemini-1.5-pro-latest",
            apiKey: apiKey,
            tools: [Tool(codeExecution: CodeExecution())],
            systemInstruction: ModelContent(
                role: "system",
                parts: [.text("You are a helpful coding assistant. When asked to solve problems, you should write and execute code to find the answer.")]
            )
        )
        
        let userContent = [ModelContent(
            role: "user",
            parts: [.text("What is the sum of the first 50 prime numbers? Write and execute Python code to calculate this.")]
        )]
        
        let response = try await model.generateContent(userContent)
        
        let hasExecutableCode = response.candidates.first?.content.parts.contains { part in
            if case .executableCode = part { return true }
            return false
        } ?? false
        #expect(hasExecutableCode, "Response should contain executable code")
        
        let hasExecutionResults = response.candidates.first?.content.parts.contains { part in
            if case .codeExecutionResult = part { return true }
            return false
        } ?? false
        #expect(hasExecutionResults, "Response should contain code execution results")
        
        if let executionResult = response.candidates.first?.content.parts.compactMap({ part in
            if case .codeExecutionResult(let result) = part { return result }
            return nil
        }).first {
            #expect(executionResult.outcome == .ok, "Code execution should complete successfully")
            #expect(!executionResult.output.isEmpty, "Execution output should not be empty")
            #expect(executionResult.output.contains("5117"), "Output should contain correct sum of first 50 primes (5117)")
        }
    }
    
    @Test
    func testComplexCodeExecution() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a helpful coding assistant. When asked to solve problems, you should write and execute code to find the answer."
            },
            .user {
                """
                I need a Python function that:
                1. Generates 100 random numbers between 1 and 1000
                2. Sorts them in descending order
                3. Filters out any numbers divisible by 3
                4. Returns the sum of the remaining numbers
                
                Please write and execute this code.
                """
            }
        ]
        
        let model = GenerativeModel(
            name: "gemini-1.5-pro-latest",
            apiKey: apiKey,
            tools: [Tool(codeExecution: CodeExecution())],
            systemInstruction: ModelContent(
                role: "system",
                parts: [.text("You are a helpful coding assistant. When asked to solve problems, you should write and execute code to find the answer.")]
            )
        )
        
        let userContent = try [ModelContent(
            role: "user",
            parts: [.text(messages.last!.content._stripToText())]
        )]
        
        let response = try await model.generateContent(userContent)
        
        dump(response)
        
        // Validate code structure
        if let executableCode = response.candidates.first?.content.parts.compactMap({ part in
            if case .executableCode(let code) = part { return code }
            return nil
        }).first {
            #expect(executableCode.language.lowercased() == "python", "Should use Python")
            #expect(executableCode.code.contains("random.randint"), "Should use random number generation")
            #expect(executableCode.code.contains("sort"), "Should include sorting")
            #expect(executableCode.code.contains("filter"), "Should include filtering")
        }
        
        // Validate execution outcome
        if let executionResult = response.candidates.first?.content.parts.compactMap({ part in
            if case .codeExecutionResult(let result) = part { return result }
            return nil
        }).first {
            #expect(executionResult.outcome == .ok, "Code execution should complete successfully")
            #expect(!executionResult.output.isEmpty, "Execution output should not be empty")
            
            // Parse the output number to verify it's a valid sum
            let numberPattern = #/\d+/#
            if let match = executionResult.output.firstMatch(of: numberPattern) {
                let sum = Int(match.output)
                #expect(sum != nil && sum! > 0, "Output should contain a positive number")
            }
        }
    }
}
