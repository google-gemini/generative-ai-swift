//
// Copyright (c) Vatsal Manot
//

import AI
import Merge

public enum Gemini {
    
}

extension Gemini {
    public final class Client: ObservableObject {
        public struct Configuration: Codable, Hashable, Sendable {
            public var apiKey: String?
        }
        
        private let configuration: Configuration
        
        public init(configuration: Configuration) {
            self.configuration = configuration
        }
    }
}
