import Foundation

public struct ChatMessage: Identifiable, Codable, Equatable {
    public let id: UUID
    public var content: String
    public let isUser: Bool
    public let timestamp: Date
    
    public init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    public var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    public var shortContent: String {
        let maxLength = 50
        return content.count > maxLength ? String(content.prefix(maxLength)) + "..." : content
    }
}

// MARK: - Equatable
public extension ChatMessage {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
} 