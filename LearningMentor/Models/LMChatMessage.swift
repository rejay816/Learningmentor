import Foundation

struct LMChatMessage: Identifiable, Codable, @unchecked Sendable, Equatable, Hashable {
    let id: UUID
    var content: String
    let isUser: Bool
    let timestamp: Date
    
    // 明确编码解码规则
    enum CodingKeys: String, CodingKey {
        case id, content, isUser, timestamp
    }
    
    // 修改构造函数，给 `timestamp` 提供默认值
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    // 添加解码初始化器
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        content = try container.decode(String.self, forKey: .content)
        isUser = try container.decode(Bool.self, forKey: .isUser)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    // 实现 Equatable
    static func == (lhs: LMChatMessage, rhs: LMChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
    
    // 实现 Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
