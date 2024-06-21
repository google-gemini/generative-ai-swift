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
            public var apiKey: String
        }
        
        internal let configuration: Configuration
        
        public init(configuration: Configuration) {
            self.configuration = configuration
        }
        
        public convenience init(apiKey: String) {
            let configuration = Configuration(apiKey: apiKey)
            self.init(configuration: configuration)
        }
    }
}
