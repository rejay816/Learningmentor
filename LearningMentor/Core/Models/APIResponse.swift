import Foundation

public struct APIResponse: Codable {
    public struct Choice: Codable {
        public struct Message: Codable {
            public let role: String
            public let content: String
            
            public init(role: String, content: String) {
                self.role = role
                self.content = content
            }
        }
        
        public let message: Message
        public let finishReason: String?
        public let index: Int
        
        private enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
            case index
        }
        
        public init(message: Message, finishReason: String? = nil, index: Int) {
            self.message = message
            self.finishReason = finishReason
            self.index = index
        }
    }
    
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [Choice]
    public let usage: Usage?
    
    public struct Usage: Codable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
        
        private enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
        
        public init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
            self.promptTokens = promptTokens
            self.completionTokens = completionTokens
            self.totalTokens = totalTokens
        }
    }
    
    public init(id: String, object: String, created: Int, model: String, choices: [Choice], usage: Usage? = nil) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
    }
    
    public var firstContent: String? {
        choices.first?.message.content
    }
}

extension APIResponse {
    public var totalTokensUsed: Int {
        usage?.totalTokens ?? 0
    }
    
    public var isComplete: Bool {
        choices.first?.finishReason == "stop"
    }
} 