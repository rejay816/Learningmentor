import Foundation

public class Conversation: Identifiable, ObservableObject, Codable {
    public let id: UUID
    @Published public var messages: [ChatMessage]
    @Published public var title: String
    @Published public var customPrompt: String
    @Published public var isLoadingMore: Bool = false
    @Published public var isArchived: Bool = false
    public var hasMoreMessages: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, messages, title, customPrompt, isArchived
    }
    
    public init(id: UUID = UUID(), title: String = "新对话", customPrompt: String = "", messages: [ChatMessage] = [], isArchived: Bool = false) {
        self.id = id
        self.title = title
        self.customPrompt = customPrompt
        self.messages = messages
        self.isArchived = isArchived
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        title = try container.decode(String.self, forKey: .title)
        customPrompt = try container.decode(String.self, forKey: .customPrompt)
        isArchived = try container.decode(Bool.self, forKey: .isArchived)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(messages, forKey: .messages)
        try container.encode(title, forKey: .title)
        try container.encode(customPrompt, forKey: .customPrompt)
        try container.encode(isArchived, forKey: .isArchived)
    }
    
    public func loadMoreMessages() {
        // 实现加载更多消息的逻辑
        isLoadingMore = true
        // TODO: 实现具体的加载逻辑
        isLoadingMore = false
    }
    
    // 计算属性，生成简短的聊天名称
    public var shortTitle: String {
        let maxLength = 20 // 设置最大长度
        return title.count > maxLength ? String(title.prefix(maxLength)) + "..." : title
    }
}

// MARK: - Equatable
extension Conversation: Equatable {
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.customPrompt == rhs.customPrompt &&
        lhs.messages == rhs.messages &&
        lhs.isArchived == rhs.isArchived
    }
} 