import SwiftUI

@MainActor
public class ChatViewModel: ObservableObject {
    @Published public var conversations: [Conversation] = []
    @Published public var selectedConversation: Conversation?
    @Published public var inputText: String = ""
    @Published public var isProcessing: Bool = false
    @Published public var selectedModel: String = "gpt-3.5-turbo"
    
    private let openAIService: OpenAIService
    private let deepSeekService: DeepSeekService
    private let storageManager: StorageManager
    private let errorHandler: ErrorHandler
    
    public let availableModels = [
        "gpt-4",
        "gpt-3.5-turbo",
        "deepseek-chat",
        "deepseek-coder"
    ]
    
    public init(apiKey: String = "", deepSeekApiKey: String = "") {
        self.openAIService = OpenAIService(apiKey: apiKey)
        self.deepSeekService = DeepSeekService(apiKey: deepSeekApiKey)
        self.storageManager = StorageManager.shared
        self.errorHandler = ErrorHandler.shared
        
        loadConversations()
        
        // 如果 API Key 为空，尝试从开发环境获取
        #if DEBUG
        if apiKey.isEmpty {
            let defaultOpenAIKey = "YOUR_OPENAI_API_KEY"
            try? KeychainService.shared.saveAPIKey(defaultOpenAIKey, service: "OpenAI")
        }
        if deepSeekApiKey.isEmpty {
            let defaultDeepSeekKey = "YOUR_DEEPSEEK_API_KEY"
            try? KeychainService.shared.saveAPIKey(defaultDeepSeekKey, service: "DeepSeek")
        }
        #endif
    }
    
    public func createNewConversation() {
        let conversation = Conversation()
        conversations.insert(conversation, at: 0)
        selectedConversation = conversation
        saveConversations()
    }
    
    func deleteConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations.remove(at: index)
            if selectedConversation?.id == conversation.id {
                selectedConversation = conversations.first
            }
            saveConversations()
        }
    }
    
    func archiveConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isArchived = true
            objectWillChange.send()
            saveConversations()
        }
    }
    
    func unarchiveConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isArchived = false
            objectWillChange.send()
            saveConversations()
        }
    }
    
    func renameConversation(_ conversation: Conversation, to newName: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].title = newName
            objectWillChange.send()
            saveConversations()
        }
    }
    
    func sendMessage(_ content: String) async {
        guard !content.isEmpty else { return }
        guard let conversation = selectedConversation else {
            createNewConversation()
            return
        }
        
        let userMessage = ChatMessage(content: content, isUser: true)
        conversation.messages.append(userMessage)
        inputText = ""
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let response: String
            if selectedModel.hasPrefix("deepseek") {
                response = try await deepSeekService.sendMessage(
                    content,
                    model: selectedModel,
                    systemPrompt: conversation.customPrompt
                )
            } else {
                response = try await openAIService.sendMessage(
                    content,
                    model: selectedModel,
                    systemPrompt: conversation.customPrompt
                )
            }
            
            let aiMessage = ChatMessage(content: response, isUser: false)
            conversation.messages.append(aiMessage)
            
            // 如果是新对话，根据第一条消息设置标题
            if conversation.messages.count == 2 {
                conversation.title = String(content.prefix(20)) + (content.count > 20 ? "..." : "")
            }
            
            saveConversations()
        } catch {
            errorHandler.handle(AppError.apiError("发送消息失败: \(error.localizedDescription)"))
        }
    }
    
    func loadConversations() {
        do {
            conversations = try storageManager.load(forKey: "conversations")
            selectedConversation = conversations.first
        } catch StorageError.dataNotFound {
            // 如果数据不存在，创建一个新的对话
            createNewConversation()
        } catch {
            errorHandler.handle(AppError.storageError("加载对话失败: \(error.localizedDescription)"))
        }
    }
    
    func saveConversations() {
        do {
            try storageManager.save(conversations, forKey: "conversations")
        } catch {
            errorHandler.handle(AppError.storageError("保存对话失败: \(error.localizedDescription)"))
        }
    }
    
    public func cleanup() {
        saveConversations()
    }
    
    // 获取未存档的对话
    var unarchivedConversations: [Conversation] {
        conversations.filter { !$0.isArchived }
    }
    
    // 获取已存档的对话
    var archivedConversations: [Conversation] {
        conversations.filter { $0.isArchived }
    }
    
    private func handleError(_ error: Error, action: String) {
        errorHandler.handle(AppError.storageError("\(action): \(error.localizedDescription)"))
    }
} 