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

@Suite struct GeminiFunctionCallingTests {
    let llm: any LLMRequestHandling = Gemini.Client(apiKey: "AIzaSyBmz1E3wsIm93XpxSByWVurLiWqNXLZ_hQ")
    
    @Test
    func testFunctionCalling() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a Meteorologist Expert accurately giving weather data in fahrenheit at any given city around the world"
            },
            .user {
                "What is the weather in San Francisco, CA?"
            }
        ]
        
        let functionCall: AbstractLLM.ChatFunctionCall = try await llm.complete(
            messages,
            functions: [makeGetWeatherFunction()],
            model: Gemini.Model.gemini_1_5_pro_latest,
            as: .functionCall
        )
        
        dump(functionCall)
        
        let result = try functionCall.decode(GetWeatherParameters.self)
        
        #expect(result.weather.first?.unit_fahrenheit != nil, "Weather temperature should not be nil")
        print(result)
    }
    
    private func makeGetWeatherFunction() -> AbstractLLM.ChatFunctionDefinition {
        let weatherObjectSchema = JSONSchema(
            type: .object,
            description: "Weather in a certain location",
            properties: [
                "location": JSONSchema(
                    type: .string,
                    description: "The city and state, e.g. San Francisco, CA"
                ),
                "unit_fahrenheit": JSONSchema(
                    type: .number,
                    description: "The unit of temperature in 'fahrenheit'"
                )
            ],
            required: [
                "location",
                "unit_fahrenheit"
            ]
        )
        
        let getWeatherFunction: AbstractLLM.ChatFunctionDefinition = AbstractLLM.ChatFunctionDefinition(
            name: "get_weather",
            context: "Get the current weather in a given location",
            parameters: JSONSchema(
                type: .object,
                properties: [
                    "weather": .array(weatherObjectSchema)
                ],
                required: ["weather"]
            )
        )
        
        return getWeatherFunction
    }
    
    struct GetWeatherParameters: Codable, Hashable, Sendable {
        let weather: [WeatherObject]
    }
    
    struct WeatherObject: Codable, Hashable, Sendable {
        let location: String
        let unit_fahrenheit: Double
    }
}
