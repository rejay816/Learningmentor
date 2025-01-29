import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import AppKit

struct MainView: View {
    @StateObject private var viewModel: ChatViewModel = {
        let openAIKey = KeychainService.shared.loadAPIKey(service: "OpenAI") ?? ""
        let deepSeekKey = KeychainService.shared.loadAPIKey(service: "DeepSeek") ?? ""
        return ChatViewModel(apiKey: openAIKey, deepSeekApiKey: deepSeekKey)
    }()
    @StateObject private var fileHistoryManager: FileHistoryManager = .shared
    @StateObject private var errorHandler: ErrorHandler = .shared
    @StateObject private var networkMonitor: NetworkMonitor = .shared
    
    // 状态管理
    @State private var isShowingFileImporter = false
    @State private var isShowingExportDialog = false
    @State private var isShowingPromptPicker = false
    @State private var showFileHistory = false
    @State private var selectedMessages = Set<ChatMessage.ID>()
    
    // Add this computed property before the body
    private var selectedMessagesBinding: Binding<[ChatMessage]> {
        Binding<[ChatMessage]>(
            get: {
                guard let conversation = self.viewModel.selectedConversation else { return [] }
                return conversation.messages.filter { selectedMessages.contains($0.id) }
            },
            set: { messages in
                selectedMessages = Set(messages.map { $0.id })
            }
        )
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedConversation: Binding(
                    get: { self.viewModel.selectedConversation },
                    set: { self.viewModel.selectedConversation = $0 }
                ),
                viewModel: viewModel
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } detail: {
            if let conversation = viewModel.selectedConversation {
                ChatDetailView(conversation: conversation, viewModel: viewModel)
            } else {
                Text("选择或创建一个对话")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("")
        .toolbar {
            ChatToolbar(
                viewModel: viewModel,
                isShowingFileImporter: $isShowingFileImporter,
                isShowingExportDialog: $isShowingExportDialog,
                isShowingPromptPicker: $isShowingPromptPicker,
                showFileHistory: $showFileHistory
            )
        }
        .frame(minWidth: 900, minHeight: 600)
        .alert(isPresented: $errorHandler.showError) {
            Alert(
                title: Text("错误"),
                message: Text(errorHandler.currentError?.localizedDescription ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [
                .plainText,
                UTType(filenameExtension: "md")!,
                UTType(filenameExtension: "doc")!,
                UTType(filenameExtension: "docx")!,
                .pdf
            ],
            allowsMultipleSelection: false
        ) { result in
            handleFileImportResult(result)
        }
        .sheet(isPresented: $isShowingExportDialog) {
            if let conversation = self.viewModel.selectedConversation {
                ExportDialogView(
                    messages: conversation.messages,
                    selectedMessages: selectedMessagesBinding,
                    onDismiss: { isShowingExportDialog = false },
                    onExport: handleExport
                )
            }
        }
        .sheet(isPresented: $isShowingPromptPicker) {
            if let conversation = self.viewModel.selectedConversation {
                PromptPickerView(
                    currentPrompt: conversation.customPrompt,
                    onCancel: { isShowingPromptPicker = false },
                    onSelect: handlePromptSelection
                )
            }
        }
        .sheet(isPresented: $showFileHistory) {
            FileHistoryView()
        }
    }
    
    private func handleFileImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            do {
                let content = try FileService.shared.readFileContent(fileURL: fileURL)
                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                
                // Add to history
                let record = FileRecord(
                    path: fileURL.path,
                    fileName: fileURL.lastPathComponent,
                    fileSize: Int64(fileSize),
                    fileType: fileURL.pathExtension.uppercased(),
                    content: content
                )
                fileHistoryManager.addRecord(record)
                
                // 显示文件预览窗口
                FilePreviewWindowController.showPreview(
                    text: content,
                    fileName: fileURL.lastPathComponent,
                    fileSize: ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file),
                    fileType: fileURL.pathExtension.uppercased(),
                    onConfirm: { text in
                        // 用户点击确认后才创建新对话
                        let conversation = Conversation()
                        let message = ChatMessage(content: text, isUser: true)
                        conversation.messages.append(message)
                        conversation.title = fileURL.lastPathComponent
                        
                        viewModel.conversations.insert(conversation, at: 0)
                        viewModel.selectedConversation = conversation
                        viewModel.saveConversations()
                    },
                    onCancel: {}
                )
            } catch {
                errorHandler.handle(AppError.fileError("文件读取失败: \(error.localizedDescription)"))
            }
        case .failure(let error):
            errorHandler.handle(AppError.fileError("文件选择失败: \(error.localizedDescription)"))
        }
    }
    
    private func handleExport(messages: [ChatMessage], format: ExportFormat) {
        do {
            _ = try FileService.shared.exportConversation(messages, format: format)
            // 文件已经在 Finder 中显示，不需要额外处理
        } catch {
            errorHandler.handle(AppError.fileError("导出对话失败: \(error.localizedDescription)"))
        }
        isShowingExportDialog = false
    }
    
    private func handlePromptSelection(_ prompt: String) {
        if let conversation = self.viewModel.selectedConversation {
            conversation.customPrompt = prompt
            self.viewModel.saveConversations()
        }
        isShowingPromptPicker = false
    }
}

#Preview {
    MainView()
} 