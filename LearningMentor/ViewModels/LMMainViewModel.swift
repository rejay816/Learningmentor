import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class LMMainViewModel: ObservableObject {
    // 状态管理
    enum ViewState {
        case idle
        case loading
        case error(String)
        case success
    }
    
    @Published var viewState: ViewState = .idle
    @Published var conversations: [Conversation] = []
    @Published var selectedConversation: Conversation?
    @Published var inputText: String = ""
    
    // 网络监测
    let networkMonitor = NetworkMonitor()
    
    // 加载状态
    @Published var isProcessing: Bool = false
    @Published var processingMessage: String = ""
    
    // GPT / AI 服务
    let openAIService: OpenAIService
    let ankiService = AnkiService()
    
    // 提取的卡片和弹窗状态
    @Published var showCardCandidateSheet = false
    @Published var extractedCards: [ExtractedCard] = []
    
    // 错误处理
    @Published var errorMessage: String = ""
    @Published var isShowingErrorAlert = false
    
    // 新增：更新 API Key 的方法
    func updateAPIKey(_ newKey: String) {
        // 如果不再使用 deepSeekService，
        // 删去此处或改为 openAIService = OpenAIService(apiKey: trimmedKey)
    }
    
    // 添加模型选择相关状态
    @Published var selectedModel: String = "deepseek-chat"
    let availableModels = [
        // OpenAI Models
        "chatgpt-4o-latest",    // ChatGPT-4 Optimized Latest
        "gpt-4o",                // GPT-4 Optimized
        "gpt-4o-mini",          // GPT-4 Optimized Mini
        "gpt-4-turbo",          // GPT-4 Turbo
        "gpt-3.5-turbo",        // GPT-3.5
        // DeepSeek Models
        "deepseek-chat",        // DeepSeek-V3
        "deepseek-reasoner"     // DeepSeek-R1
    ]
    
    // 添加 DeepSeek 服务
    let deepSeekService: DeepSeekService
    
    // 初始化方法
    init(apiKey: String = "", deepSeekApiKey: String = "") {
        self.openAIService = OpenAIService(apiKey: apiKey)
        self.deepSeekService = DeepSeekService(apiKey: deepSeekApiKey)
        let defaultConversation = Conversation(title: "Default Chat")
        defaultConversation.appendMessage(LMChatMessage(content: "Hi Benson, I'm your Mentor. Let's learn together!", isUser: false))
        conversations.append(defaultConversation)
        selectedConversation = defaultConversation
    }
    
    // 新建会话
    func addConversation() {
        let newConversation = Conversation(title: "New Chat")
        conversations.append(newConversation)
        selectedConversation = newConversation
    }
    
    // 自动更新会话标题
    private func updateConversationTitle(_ conversation: Conversation) {
        if let firstUserMessage = conversation.messages.first(where: { $0.isUser }) {
            let title = firstUserMessage.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(30)  // 限制标题长度
            
            if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                conversations[index].title = String(title)
                objectWillChange.send()
            }
        }
    }
    
    // 清除所有会话
    func clearAllConversations() {
        conversations.removeAll()
        selectedConversation = nil
    }
    
    // 删除指定会话
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        if selectedConversation == conversation {
            selectedConversation = nil
        }
    }
    
    // 发送消息
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        guard !isProcessing else { return }
        guard networkMonitor.isConnected else {
            handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "网络未连接"]), context: "网络错误")
            return
        }
        
        if selectedConversation == nil {
            addConversation()
        }
        
        let userContent = inputText
        inputText = ""
        
        guard let conversation = selectedConversation else { return }
        
        // 添加用户消息
        let userMessage = LMChatMessage(content: userContent, isUser: true)
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].messages.append(userMessage)
            selectedConversation = conversations[index]
            objectWillChange.send()
        }
        
        // 如果是会话的第一条用户消息，更新标题
        if conversation.messages.filter({ $0.isUser }).count == 1 {
            updateConversationTitle(conversation)
        }
        
        // 开始处理
        isProcessing = true
        viewState = .loading
        processingMessage = "正在思考..."
        
        Task {
            do {
                let response = try await processMessage(userContent, for: conversation)
                
                await MainActor.run {
                    let aiMessage = LMChatMessage(content: response, isUser: false)
                    if let index = self.conversations.firstIndex(where: { $0.id == conversation.id }) {
                        self.conversations[index].messages.append(aiMessage)
                        self.selectedConversation = self.conversations[index]
                        self.objectWillChange.send()
                        self.viewState = .success
                    }
                }
            } catch {
                await MainActor.run {
                    self.viewState = .error(error.localizedDescription)
                    handleError(error, context: "AI处理失败")
                }
            }
            
            await MainActor.run {
                self.isProcessing = false
                self.processingMessage = ""
            }
        }
    }
    
    private func processMessage(_ text: String, for conversation: Conversation) async throws -> String {
        if conversation.isAnalysisMode {
            return try await analyzeTextBySentence(text)
        } else {
            // 根据选择的模型决定使用哪个服务
            switch selectedModel {
            case "deepseek-chat", "deepseek-reasoner":
                print("Using DeepSeek model: \(selectedModel)")
                let response = try await deepSeekService.sendMessage(
                    text,
                    model: selectedModel,
                    systemPrompt: conversation.customPrompt
                )
                print("DeepSeek response format:\n\(response)")
                return response
                
            default:
                print("Using OpenAI model: \(selectedModel)")
                let response = try await openAIService.sendMessage(
                    text,
                    model: selectedModel,
                    systemPrompt: conversation.customPrompt
                )
                print("OpenAI response format:\n\(response)")
                return response
            }
        }
    }
    
    // 从 GPT 响应中提取卡片
    private func requestCardExtraction(_ userContent: String) async throws -> [ExtractedCard] {
        // 如果先前调用了 deepSeekService.sendMessage(...)，请注释或改用新的 AI 服务
        // let response = try await deepSeekService.sendMessage(userContent)
        
        guard let jsonStr = extractJsonArray(from: userContent) else {
            return []
        }
        
        do {
            let data = Data(jsonStr.utf8)
            let decoder = JSONDecoder()
            let result = try decoder.decode([ExtractedCard].self, from: data)
            return result
        } catch {
            print("JSON parse error: \(error)")
            return []
        }
    }
    
    // 从文本中提取 JSON 数组
    private func extractJsonArray(from text: String) -> String? {
        guard let start = text.firstIndex(of: "[") else {
            return nil
        }
        
        guard let end = text.lastIndex(of: "]"),
              end > start,
              start < text.endIndex,
              end < text.endIndex else {
            return nil
        }
        
        let subText = text[start...end]
        
        // 验证提取的文本是否是有效的 JSON 数组
        guard let data = String(subText).data(using: .utf8),
              let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            return nil
        }
        
        return String(subText)
    }
    
    // 确认导入卡片
    func confirmImport(cards: [ExtractedCard]) {
        Task {
            do {
                let deckName = makeTodayDeckName()
                try await ankiService.createDeckIfNeeded(deckName: deckName)
                
                guard let conversationIndex = conversations.firstIndex(where: { $0.id == selectedConversation?.id }) else {
                    return
                }
                
                for card in cards {
                    let foundNotes = try await ankiService.findNotes(expression: card.front)
                    if !foundNotes.isEmpty {
                        let duplicateMessage = LMChatMessage(content: "卡片已存在: \(card.front)", isUser: false)
                        let updatedConv = conversations[conversationIndex]
                        updatedConv.messages.append(duplicateMessage)
                        conversations[conversationIndex] = updatedConv
                    } else {
                        let noteDict = makeNoteDict(deckName: deckName, card: card)
                        try await ankiService.addNotes(deckName: deckName, noteDictArray: [noteDict])
                        let successMessage = LMChatMessage(content: "已添加卡片: \(card.front)", isUser: false)
                        let updatedConv = conversations[conversationIndex]
                        updatedConv.messages.append(successMessage)
                        conversations[conversationIndex] = updatedConv
                    }
                }
            } catch {
                handleError(error, context: "导入Anki出错")
            }
        }
    }
    
    // 生成 Anki 卡片字典
    private func makeNoteDict(deckName: String, card: ExtractedCard) -> [String: Any] {
        let modelName: String
        switch card.type.lowercased() {
        case "vocab":   modelName = "French Vocab"
        case "phrase":  modelName = "French Phrase"
        case "grammar": modelName = "French Grammar"
        default:        modelName = "Basic"
        }
        
        let backString = "\(card.back)\n\nExample: \(card.example)\n\nNote: \(card.note)"
        
        return [
            "deckName": deckName,
            "modelName": modelName,
            "fields": [
                "Front": card.front,
                "Back": backString
            ],
            "options": [
                "allowDuplicate": false
            ],
            "tags": card.tags.isEmpty ? ["french"] : card.tags
        ]
    }
    
    // 创建当天的 Deck 名称
    private func makeTodayDeckName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    // 新增：法语文本分句函数
    private func splitFrenchText(_ text: String) -> [String] {
        // 定义法语句子结束的标点符号
        let sentenceDelimiters = [".", "!", "?", "；", ";"]
        var sentences: [String] = []
        var currentSentence = ""
        
        // 按字符遍历
        for char in text {
            currentSentence.append(char)
            
            // 如果遇到句子结束符号，且不是数字后面的点号
            if sentenceDelimiters.contains(String(char)) {
                // 清理句子（去除首尾空格）
                let cleanedSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanedSentence.isEmpty {
                    sentences.append(cleanedSentence)
                }
                currentSentence = ""
            }
        }
        
        // 处理最后一个句子（如果没有结束符号）
        let finalSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalSentence.isEmpty {
            sentences.append(finalSentence)
        }
        
        return sentences
    }
    
    /// 清理资源
    func cleanup() {
        // 在这里添加需要清理的资源
        // 例如：
        // - 取消正在进行的网络请求
        // - 清理临时文件
        // - 重置状态等
    }
    
    // 错误处理
    func handleError(_ error: Error, context: String) {
        let errorMessage: String
        
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "网络连接失败，请检查网络设置"
            case .timedOut:
                errorMessage = "请求超时，请稍后重试"
            case .cancelled:
                errorMessage = "请求已取消"
            default:
                errorMessage = "网络错误：\(urlError.localizedDescription)"
            }
        case let apiError as APIError:
            errorMessage = apiError.errorDescription
        default:
            errorMessage = error.localizedDescription
        }
        
        DispatchQueue.main.async {
            self.errorMessage = "\(context): \(errorMessage)"
            self.isShowingErrorAlert = true
            self.viewState = .error(errorMessage)
            
            if let conversation = self.selectedConversation {
                let errorMsg = LMChatMessage(content: self.errorMessage, isUser: false)
                if let index = self.conversations.firstIndex(where: { $0.id == conversation.id }) {
                    self.conversations[index].messages.append(errorMsg)
                    self.selectedConversation = self.conversations[index]
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func analyzeTextBySentence(_ text: String) async throws -> String {
        let sentences = splitFrenchText(text)
        var analysisResults: [String] = []
        
        for sentence in sentences {
            let response = try await openAIService.sendMessage(
                sentence,
                model: selectedModel,
                systemPrompt: makeSingleLinePrompt(for: sentence)
            )
            analysisResults.append(response)
            
            // 实时更新进度
            updateAnalysisProgress(current: analysisResults.count, total: sentences.count)
        }
        
        return analysisResults.joined(separator: "\n\n")
    }
    
    private func updateAnalysisProgress(current: Int, total: Int) {
        DispatchQueue.main.async {
            self.analysisProgress = Double(current) / Double(total)
        }
    }
    
    private func makeSingleLinePrompt(for sentence: String) -> String {
        return "请分析以下句子：\(sentence)"
    }
    
    // 新增：在 LMMainViewModel 中添加
    @Published var analysisProgress: Double = 0.0
    
    func renameConversation(_ conversation: Conversation, to newName: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].title = newName
        }
    }
    
    func archiveConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isArchived = true
            objectWillChange.send()
        }
    }
    
    func unarchiveConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isArchived = false
            objectWillChange.send()
        }
    }
    
    // 导出相关方法
    private func formatMessagesForExport(_ msgs: [LMChatMessage], format: ExportFormat) -> String {
        switch format {
        case .text:
            return msgs.map { m in
                (m.isUser ? "[USER]" : "[AI]") + " " + m.content
            }.joined(separator: "\n\n")
            
        case .markdown:
            return msgs.map { m in
                "## " + (m.isUser ? "User" : "AI") + "\n\n" + m.content
            }.joined(separator: "\n\n")
            
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let data = try? encoder.encode(msgs)
            return data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
        case .html:
            let messages = msgs.map { m in
                """
                <div class="\(m.isUser ? "user" : "ai")-message">
                    <h3>\(m.isUser ? "User" : "AI")</h3>
                    <p>\(m.content.replacingOccurrences(of: "\n", with: "<br>"))</p>
                </div>
                """
            }.joined(separator: "\n")
            
            return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
                    .user-message { background: #f0f0f0; padding: 15px; margin: 10px 0; border-radius: 8px; }
                    .ai-message { background: #e8f4f8; padding: 15px; margin: 10px 0; border-radius: 8px; }
                    h3 { margin-top: 0; color: #333; }
                </style>
            </head>
            <body>
                <h1>Chat Export</h1>
                <p>Exported on: \(Date().formatted())</p>
                \(messages)
            </body>
            </html>
            """
            
        case .anki:
            return ""  // Anki 导出使用专门的导出逻辑
        }
    }
    
    // 导出功能
    func saveMessages(_ msgs: [LMChatMessage], as format: ExportFormat) {
        guard !msgs.isEmpty else { return }
        
        let content = formatMessagesForExport(msgs, format: format)
        
        let savePanel = NSSavePanel()
        savePanel.title = "选择保存路径"
        savePanel.nameFieldStringValue = "chat_export.\(format.rawValue)"
        
        // 使用正确的 UTType
        let contentType: UTType
        switch format {
        case .text:
            contentType = .plainText
        case .markdown:
            contentType = UTType("net.daringfireball.markdown")!
        case .json:
            contentType = .json
        case .html:
            contentType = .html
        case .anki:
            contentType = .json
        }
        savePanel.allowedContentTypes = [contentType]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                handleError(error, context: "保存文件失败")
            }
        }
    }
}

// 自定义错误类型
enum APIError: LocalizedError {
    case invalidResponse
    case invalidData
    case serverError(String)
    case rateLimitExceeded
    case unauthorized
    
    var errorDescription: String {
        switch self {
        case .invalidResponse:
            return "服务器响应无效"
        case .invalidData:
            return "数据格式错误"
        case .serverError(let message):
            return "服务器错误：\(message)"
        case .rateLimitExceeded:
            return "请求频率超限，请稍后重试"
        case .unauthorized:
            return "认证失败，请检查API密钥"
        }
    }
}
