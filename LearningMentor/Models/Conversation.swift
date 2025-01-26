import Foundation

/// 多会话结构，用在侧边栏
class Conversation: Identifiable, ObservableObject, Equatable, Hashable, Encodable {
    let id: UUID
    
    @Published var title: String
    @Published var messages: [LMChatMessage] = []
    @Published var customPrompt: String = ""
    @Published var isArchived: Bool = false  // 添加存档标志
    
    // 分页相关
    private let pageSize = 20
    @Published private(set) var hasMoreMessages = false
    @Published private(set) var isLoadingMore = false
    private var currentPage = 1
    
    // 缓存相关
    private var cachedMessages: [LMChatMessage] = []
    private var loadMoreTask: Task<Void, Never>?
    
    // 新增会话类型
    enum ConversationType: Int, Codable {
        case chat, textAnalysis
    }
    
    var type: ConversationType = .chat
    
    // 计算属性判断模式
    var isAnalysisMode: Bool {
        type == .textAnalysis
    }
    
    // 计算属性，生成简短的聊天名称
    var shortTitle: String {
        let maxLength = 20 // 设置最大长度
        return title.count > maxLength ? String(title.prefix(maxLength)) + "..." : title
    }
    
    init(title: String, messages: [LMChatMessage] = []) {
        self.id = UUID()
        self.title = title
        self.cachedMessages = messages
        self.hasMoreMessages = messages.count > pageSize
        updateVisibleMessages(scrollToBottom: true)
    }
    
    deinit {
        loadMoreTask?.cancel()
    }
    
    // MARK: - 分页和缓存方法
    
    func loadMoreMessages() {
        guard hasMoreMessages && !isLoadingMore else { return }
        
        isLoadingMore = true
        
        // 使用 Task 替代 DispatchQueue，更好的内存管理
        loadMoreTask?.cancel()
        loadMoreTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3秒延迟
            guard !Task.isCancelled else { return }
            
            currentPage += 1
            updateVisibleMessages(scrollToBottom: false)
            isLoadingMore = false
        }
    }
    
    private func updateVisibleMessages(scrollToBottom: Bool = false) {
        let endIndex = min(currentPage * pageSize, cachedMessages.count)
        let startIndex = max(0, endIndex - (currentPage * pageSize))
        
        if scrollToBottom {
            // 显示最新的消息
            messages = Array(cachedMessages.suffix(pageSize))
            currentPage = 1
        } else {
            // 加载更多历史消息
            messages = Array(cachedMessages[startIndex..<endIndex])
        }
        
        hasMoreMessages = endIndex < cachedMessages.count
    }
    
    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case id, type, title, messages, customPrompt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ConversationType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        cachedMessages = try container.decode([LMChatMessage].self, forKey: .messages)
        customPrompt = try container.decode(String.self, forKey: .customPrompt)
        
        hasMoreMessages = cachedMessages.count > pageSize
        updateVisibleMessages(scrollToBottom: true)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(cachedMessages, forKey: .messages)
        try container.encode(customPrompt, forKey: .customPrompt)
    }
    
    // 如果自动合成不成功，就可手写：
    /*
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.messages == rhs.messages
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(messages)
    }
    */
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
    
    // 新增：实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    // 添加消息时触发视图更新
    func appendMessage(_ message: LMChatMessage) {
        cachedMessages.append(message)
        
        // 始终显示新消息，并确保不超过每页显示限制
        if messages.count >= pageSize {
            messages = Array(messages.dropFirst()) + [message]
        } else {
            messages.append(message)
        }
        
        // 重置分页状态
        currentPage = 1
        hasMoreMessages = cachedMessages.count > pageSize
        
        objectWillChange.send()
    }
}
