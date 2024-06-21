//
// Copyright (c) Vatsal Manot
//

import AI
import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

extension Gemini.Client: LLMRequestHandling {
    
    public var _availableModels: [ModelIdentifier]? {
        Gemini.Model.allCases.map({ $0.__conversion() })
    }
    
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        let _completion: Any
        
        switch prompt {
        case let prompt as AbstractLLM.TextPrompt:
            _completion = try await _complete(
                prompt: prompt,
                parameters: try cast(parameters)
            )
        case let prompt as AbstractLLM.ChatPrompt:
            _completion = try await _complete(
                prompt: prompt,
                parameters: try cast(parameters)
            )
        default:
            throw LLMRequestHandlingError.unsupportedPromptType(Prompt.self)
        }
        
        return try cast(_completion)
    }
    
    private func _complete(
        prompt: AbstractLLM.TextPrompt,
        parameters: AbstractLLM.TextCompletionParameters
    ) async throws -> AbstractLLM.TextCompletion {
        
        let model = try await _model(for: prompt)
        let content = try modelContent(from: prompt)
        let config = generationConfig(from: parameters)
        
        let request = GenerateContentRequest(
            model: model.rawValue,
            contents: content,
            generationConfig: config,
            safetySettings: nil,
            tools: nil,
            toolConfig: nil,
            systemInstruction: nil,
            isStreaming: false,
            options: RequestOptions()
        )
        
        let sessionConfiguration = URLSessionConfiguration.default
        let generativeAIService = GenerativeAIService(apiKey: configuration.apiKey, urlSession: URLSession(configuration: sessionConfiguration))
        let response = try await generativeAIService.loadRequest(request: request)
        
        return AbstractLLM.TextCompletion(
            prefix: .init(_lazy: prompt.prefix),
            text: response.text ?? ""
        )
    }
    
    
    private func _complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters
    ) async throws -> AbstractLLM.ChatCompletion {
        
        let model = try await _model(for: prompt)
        let generativeModel = GenerativeModel(name: model.rawValue, apiKey: configuration.apiKey)
        let chat = Chat(model: generativeModel, history: [])
        let input = try prompt._stripToText()
        let response = try await chat.sendMessage(input)
        
        let isAssistantReply: Bool = (prompt.messages.last?.role ?? .user) == .user
        let content: String = response.text ?? ""
        let message = AbstractLLM.ChatMessage(
            id: UUID(),
            role: (isAssistantReply ? .assistant : .user),
            content: content
        )
        
        return AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: message,
            stopReason: AbstractLLM.ChatCompletion.StopReason()
        )
    }
}

// Helpers
extension Gemini.Client {
    private func modelContent(
        from prompt: AbstractLLM.TextPrompt
    ) throws -> [ModelContent] {
        let promptText = try prompt.prefix.promptLiteral._stripToText()
        return [ModelContent(role: "user", parts: promptText)]
    }
    
    private func generationConfig(
        from parameters: AbstractLLM.TextCompletionParameters
    ) -> GenerationConfig {
        let temperature: Float? = parameters.temperatureOrTopP?.temperature.map(Float.init)
        
        let topP: Float? = parameters.temperatureOrTopP?.topProbabilityMass.map(Float.init)
        
        
        let maxOutputTokens: Int? = parameters.tokenLimit == .max ? nil : parameters.tokenLimit.fixedValue
        
        return GenerationConfig(
            temperature: temperature,
            topP: topP,
            maxOutputTokens: maxOutputTokens,
            stopSequences: parameters.stops
        )
    }
    
    private func _model(
        for prompt: any AbstractLLM.Prompt
    ) async throws -> Gemini.Model {
        do {
            guard let modelIdentifierScope: ModelIdentifierScope = prompt.context.get(\.modelIdentifier) else {
                return Gemini.Model.gemini_1_5_pro_latest
            }
            
            let modelIdentifier: ModelIdentifier = try modelIdentifierScope._oneValue
            
            return try Gemini.Model(from: modelIdentifier)
        } catch {
            runtimeIssue("Failed to resolve model identifier.")
            
            throw error
        }
    }
}
