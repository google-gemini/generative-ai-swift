//
//  File.swift
//  
//
//  Created by Natasha Murashev on 6/21/24.
//

import AI

extension Gemini {
    public enum Model: String, CaseIterable, Codable, Hashable, Sendable {
        case gemini_1_5_pro = "gemini-1.5-pro"
        case gemini_1_5_pro_latest = "gemini-1.5-pro-latest"
        case gemini_1_5_flash = "gemini-1.5-flash"
        case gemini_1_5_flash_latest = "gemini-1.5-flash-latest"
        case gemini_1_0_pro = "gemini-1.0-pro"
        
        public var maximumContextLength: Int {
            switch self {
            case .gemini_1_5_pro:
                return 1048576
            case .gemini_1_5_pro_latest:
                return 1048576
            case .gemini_1_5_flash:
                return 1048576
            case .gemini_1_5_flash_latest:
                return 1048576
            case .gemini_1_0_pro:
                return 30720
            }
        }
    }
}

extension Gemini.Model: ModelIdentifierRepresentable {
    private enum _DecodingError: Error {
        case invalidModelProvider
    }
    
    public init(from model: ModelIdentifier) throws {
        guard model.provider == .gemini else {
            throw _DecodingError.invalidModelProvider
        }
        
        self = try Self(rawValue: model.name).unwrap()
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: .gemini,
            name: rawValue,
            revision: nil
        )
    }
}
