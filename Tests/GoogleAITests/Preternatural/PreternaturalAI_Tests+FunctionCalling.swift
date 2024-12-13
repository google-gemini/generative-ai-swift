//
//  PreternaturalAI_Tests+FunctionCalling.swift
//  Gemini
//
//  Created by Jared Davidson on 12/12/24.
//

import AI
import CorePersistence
import Gemini
import Testing

@Suite struct GeminiLightingSystemTests {
    
    @Test
    func testLightingSystem() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a helpful lighting system bot. You can turn lights on and off, and you can set the color. Do not perform any other tasks."
            },
            .user {
                "Turn on the lights and set them to red."
            }
        ]
        
        // Define functions with correct structure
        let functions = [
            AbstractLLM.ChatFunctionDefinition(
                name: "enable_lights",
                context: "Turn on the lighting system.",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "dummy": JSONSchema(
                            type: .string,
                            description: "Placeholder parameter"
                        )
                    ]
                )
            ),
            AbstractLLM.ChatFunctionDefinition(
                name: "set_light_color",
                context: "Set the light color. Lights must be enabled for this to work.",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "rgb_hex": JSONSchema(
                            type: .string,
                            description: "The light color as a 6-digit hex string, e.g. ff0000 for red."
                        )
                    ],
                    required: ["rgb_hex"]
                )
            ),
            AbstractLLM.ChatFunctionDefinition(
                name: "stop_lights",
                context: "Turn off the lighting system.",
                parameters: JSONSchema(
                    type: .object,
                    properties: [
                        "dummy": JSONSchema(
                            type: .string,
                            description: "Placeholder parameter"
                        )
                    ]
                )
            )
        ]
        
        //FIXME: This should ideally be returning or working with something from AbstractLLM.

        let functionCalls: [FunctionCall] = try await client._complete(
            messages,
            functions: functions,
            model: Gemini.Model.gemini_1_5_pro_latest,
            as: AbstractLLM.ChatFunctionCall.self
        )
                
        guard let lastFunctionCall = functionCalls.last?.args else { return }
        
        let result = try lastFunctionCall.toJSONData().decode(LightingCommandParameters.self)
                
        #expect(result.rgb_hex != nil, "Light color parameter should not be nil")
    }
    
    @Test
    func testDirectFunctionCalling() async throws {

        let functionDeclarations = [
            FunctionDeclaration(
                name: "enable_lights",
                description: "Turn on the lighting system.",
                parameters: [
                    "dummy": Schema(
                        type: .string,
                        description: "Placeholder parameter"
                    )
                ]
            ),
            FunctionDeclaration(
                name: "set_light_color",
                description: "Set the light color. Lights must be enabled for this to work.",
                parameters: [
                    "rgb_hex": Schema(
                        type: .string,
                        description: "The light color as a 6-digit hex string, e.g. ff0000 for red."
                    )
                ],
                requiredParameters: ["rgb_hex"]
            ),
            FunctionDeclaration(
                name: "stop_lights",
                description: "Turn off the lighting system.",
                parameters: [
                    "dummy": Schema(
                        type: .string,
                        description: "Placeholder parameter"
                    )
                ]
            )
        ]
        
        let tools = Tool(functionDeclarations: functionDeclarations)
        let toolConfig = ToolConfig(
            functionCallingConfig: FunctionCallingConfig(mode: .auto)
        )
        
        let systemInstruction = ModelContent(
            role: "system",
            parts: [.text("You are a helpful lighting system bot. You can turn lights on and off, and you can set the color. Do not perform any other tasks.")]
        )
        
        let userContent = [ModelContent(
            role: "user",
            parts: [.text("Turn on the lights and set them to red.")]
        )]
        
        let model = GenerativeModel(
            name: "gemini-1.5-pro-latest",
            apiKey: apiKey,
            tools: [tools],
            toolConfig: toolConfig,
            systemInstruction: systemInstruction
        )
        
        let response = try await model.generateContent(userContent)
        
        dump(response)
        
        #expect(!response.functionCalls.isEmpty, "Should have function calls")
        
        for functionCall in response.functionCalls {
            #expect(
                ["enable_lights", "set_light_color", "stop_lights"].contains(functionCall.name),
                "Function call should be one of the defined functions"
            )
            
            if functionCall.name == "set_light_color",
               let args = functionCall.args["rgb_hex"] as? String {
                #expect(args == "ff0000", "Light color should be red (ff0000)")
            }
        }
    }
    
    
    struct LightingCommandParameters: Codable, Hashable, Sendable {
        let rgb_hex: String?
    }
}
