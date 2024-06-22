//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import LargeLanguageModels
import Swallow
import SwiftUIX

extension ModelContent {
    public init(
        _from message: AbstractLLM.ChatMessage
    ) async throws {
        let role = try _Role(from: message.role)
        var parts: [Part] = []
        
        let messageContent: PromptLiteral._Degenerate = try message.content._degenerate()
        
        for component in messageContent.components {
            switch component.payload {
            case .string(let string):
                parts.append(.text(string))
            case .image(let image):
                if case .url(let url) = image {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    let mimeType = response.mimeType ?? "image/png"
                    parts.append(.data(mimetype: mimeType, data))
                }
            case .functionCall:
                TODO.unimplemented
            case .functionInvocation:
                TODO.unimplemented
            }
        }
        
        self.init(role: role.rawValue, parts: parts)
    }
}

extension ModelContent {
    public var _role: _Role? {
        get throws {
            try self.role.map({ try _Role(rawValue: $0).unwrap() })
        }
    }
    
    public enum _Role: String {
        case systemInstruction
        case model
        case user
        
        public init(from role: AbstractLLM.ChatRole) throws {
            switch role {
                case .assistant:
                    self = .model
                case .user:
                    self = .user
                case .system:
                    self = .systemInstruction
                case .other(_):
                    throw Never.Reason.unsupported
            }
        }
    }
}
