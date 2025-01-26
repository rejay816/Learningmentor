import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import AppKit

struct MainView: View {
    @StateObject private var viewModel = LMMainViewModel(
        apiKey: Config.openAIKey,
        deepSeekApiKey: Config.deepSeekKey
    )
    
    // 文件导入
    @State private var isShowingFileImporter = false
    
    // 独立预览窗口
    @State private var previewWindowController: NSWindowController?
    
    // 导出相关
    @State private var isShowingExportDialog = false
    @State private var selectedMessagesForExport: [LMChatMessage] = []
    
    // Prompt 相关
    @State private var isShowingPromptPicker = false
    
    // 常见错误提示
    @State private var errorMessage: String?
    @State private var isShowingErrorAlert = false
    
    // TextEditor 动态高度
    @State private var dynamicTextHeight: CGFloat = 44
    
    // 在MainView添加状态管理
    @State private var isShowingSystemPromptEditor = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedConversation: $viewModel.selectedConversation,
                viewModel: viewModel
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } detail: {
            chatContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topTrailing) {
                    NetworkStatusView(monitor: viewModel.networkMonitor)
                        .padding(8)
                }
        }
        .navigationTitle("")  // 清除默认标题
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu {
                    Group {
                        Text("OpenAI Models")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(viewModel.availableModels.filter { $0.hasPrefix("gpt") || $0.hasPrefix("chatgpt") }, id: \.self) { model in
                            Button(action: {
                                viewModel.selectedModel = model
                            }) {
                                HStack {
                                    Text(model)
                                    if viewModel.selectedModel == model {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("DeepSeek Models")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(viewModel.availableModels.filter { $0.hasPrefix("deepseek") }, id: \.self) { model in
                            Button(action: {
                                viewModel.selectedModel = model
                            }) {
                                HStack {
                                    Text(model)
                                    if viewModel.selectedModel == model {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Benson's Mentor")
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { isShowingFileImporter = true }) {
                    Label("导入文件", systemImage: "folder.badge.plus")
                }
                
                Button(action: { isShowingPromptPicker = true }) {
                    Label("系统指令", systemImage: "gearshape.2.fill")
                }
                
                Button(action: { isShowingExportDialog = true }) {
                    Label("导出对话", systemImage: "square.and.arrow.up")
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .alert(isPresented: $isShowingErrorAlert) {
            Alert(
                title: Text("错误"),
                message: Text(errorMessage ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
        // macOS 里不再用 .sheet 来显示文件预览
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
            switch result {
            case .success(let urls):
                guard let fileURL = urls.first else { return }
                handleFileImport(fileURL: fileURL)
            case .failure(let error):
                handleError(error, context: "文件选择失败")
            }
        }
        // 导出浮层 (如果想用 popover /sheet 也可)
        .sheet(isPresented: $isShowingExportDialog) {
            ExportDialogView(
                messages: viewModel.selectedConversation?.messages ?? [],
                selectedMessages: $selectedMessagesForExport,
                onDismiss: { isShowingExportDialog = false },
                onExport: { messagesToSave, format in
                    viewModel.saveMessages(messagesToSave, as: format)
                    isShowingExportDialog = false
                }
            )
        }
        // Prompt 选择弹窗
        .sheet(isPresented: $isShowingPromptPicker) {
            PromptPickerView(
                currentPrompt: viewModel.selectedConversation?.customPrompt ?? "",
                onCancel: { isShowingPromptPicker = false },
                onSelect: { newPrompt in
                    // 给当前会话设置prompt
                    if let i = viewModel.conversations.firstIndex(where: { $0.id == viewModel.selectedConversation?.id }) {
                        viewModel.conversations[i].customPrompt = newPrompt
                    }
                    isShowingPromptPicker = false
                }
            )
        }
        .onDisappear {
            // 清理资源，避免视图桥接问题
            viewModel.cleanup()
        }
        .onChange(of: viewModel.conversations) {
            viewModel.objectWillChange.send()
        }
        .navigationSplitViewStyle(.automatic)
    }
    
    // 添加回 chatContentView 计算属性
    private var chatContentView: some View {
        VStack(spacing: 0) {
            if let conversation = viewModel.selectedConversation {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if conversation.hasMoreMessages {
                                Button(action: {
                                    conversation.loadMoreMessages()
                                }) {
                                    if conversation.isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.8)
                                    } else {
                                        Label("加载更多消息", systemImage: "arrow.up.circle")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.05))
                                .disabled(conversation.isLoadingMore)
                            }
                            
                            ForEach(conversation.messages) { msg in
                                MessageView(message: msg)
                                    .padding(.vertical, 4)
                                    .id(msg.id)
                            }
                            
                            if viewModel.isProcessing {
                                HStack(spacing: 8) {
                                    Image(systemName: "brain")
                                        .foregroundColor(.gray)
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    Text(viewModel.processingMessage)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .transition(
                                    .asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                        removal: .opacity
                                    )
                                )
                            }
                            
                            Color.clear.frame(height: 1).id("bottom")
                        }
                    }
                    .onChange(of: conversation.messages.count) { oldValue, newValue in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.selectedConversation?.id) { _, _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                VStack(spacing: 0) {
                    HStack {
                        GrowingTextEditor(
                            text: $viewModel.inputText,
                            maxHeight: 150,
                            measuredHeight: $dynamicTextHeight
                        )
                        .frame(height: dynamicTextHeight)
                        .padding(.vertical, 8)
                        .disabled(viewModel.isProcessing)
                        .onSubmit {
                            viewModel.sendMessage()
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.sendMessage()
                            }
                        }) {
                            Group {
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(viewModel.inputText.isEmpty ? .gray : .blue)
                                        .rotationEffect(.degrees(viewModel.isProcessing ? 360 : 0))
                                }
                            }
                            .animation(.spring(response: 0.3), value: viewModel.isProcessing)
                        }
                        .keyboardShortcut(.return)
                        .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal)
                    .background(Color(NSColor.textBackgroundColor))
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("请在侧边栏选择或者新建一个会话")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(isPresented: $viewModel.isShowingErrorAlert) {
            Alert(
                title: Text("错误"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    // 将原先的 .sheet(...) 替换为可移动窗口
    private func handleFileImport(fileURL: URL) {
        if fileURL.startAccessingSecurityScopedResource() {
            defer { fileURL.stopAccessingSecurityScopedResource() }
            do {
                let fm = FileManager.default
                let attr = try fm.attributesOfItem(atPath: fileURL.path)
                let sizeVal = attr[.size] as? UInt64 ?? 0
                let humanSize = "\(sizeVal) bytes"
                
                let previewFileName = fileURL.lastPathComponent
                let previewFileSize = humanSize
                let previewFileType = fileURL.pathExtension
                
                // 读取文件 (与之前逻辑相同，略)
                let selectedNoteContent: String = try readFileContent(fileURL: fileURL)
                
                // 调用 showPreviewWindow
                showPreviewWindow(
                    text: selectedNoteContent,
                    fileName: previewFileName,
                    fileSize: previewFileSize,
                    fileType: previewFileType
                )
            } catch {
                handleError(error, context: "文件读取失败")
            }
        } else {
            handleError(
                NSError(domain: "无法访问文件权限", code: -1, userInfo: nil),
                context: "文件权限错误"
            )
        }
    }
    
    private func showPreviewWindow(text: String, fileName: String, fileSize: String, fileType: String) {
        // 建立一个HostingController装载 FilePreviewView
        let contentView = FilePreviewView(
            text: text,
            fileName: fileName,
            fileSize: fileSize,
            fileType: fileType,
            onConfirm: { newText in
                // "确定"时，把文本放入输入框
                viewModel.inputText = newText
                previewWindowController?.close()
            },
            onCancel: {
                // "取消"时，关闭窗口
                previewWindowController?.close()
            }
        )
        
        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 600, height: 500),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "File Preview"
        window.contentView = hostingController.view
        window.isReleasedWhenClosed = false  // 保持引用到 close
        
        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        
        // 保存引用到 State
        previewWindowController = controller
    }
    
    private func readFileContent(fileURL: URL) throws -> String {
        let lowerExt = fileURL.pathExtension.lowercased()
        switch lowerExt {
        case "txt", "md":
            return try String(contentsOf: fileURL, encoding: .utf8)
        case "pdf":
            return parsePDF(fileURL: fileURL) ?? ""
        case "doc":
            return try parseWordFile(fileURL: fileURL, fileExtension: "doc")
        case "docx":
            return try parseWordFile(fileURL: fileURL, fileExtension: "docx")
        default:
            return try String(contentsOf: fileURL, encoding: .utf8)
        }
    }
    
    private func parsePDF(fileURL: URL) -> String? {
        guard let pdfDoc = PDFDocument(url: fileURL) else { return nil }
        var result = ""
        for i in 0..<pdfDoc.pageCount {
            if let page = pdfDoc.page(at: i), let text = page.string {
                result += text + "\n"
            }
        }
        return result
    }
    
    private func parseWordFile(fileURL: URL, fileExtension: String) throws -> String {
        let docType: NSAttributedString.DocumentType
        switch fileExtension.lowercased() {
        case "doc":
            docType = .docFormat
        case "docx":
            docType = .officeOpenXML
        default:
            docType = .rtf
        }
        let attString = try NSAttributedString(
            url: fileURL,
            options: [.documentType: docType],
            documentAttributes: nil
        )
        return attString.string
    }
    
    private func handleError(_ error: Error, context: String) {
        let message = "\(context): \(error.localizedDescription)"
        errorMessage = message
        isShowingErrorAlert = true
        
        if let conversationIndex = viewModel.conversations.firstIndex(where: { $0.id == viewModel.selectedConversation?.id }) {
            let updatedConv = viewModel.conversations[conversationIndex]
            updatedConv.messages.append(LMChatMessage(content: message, isUser: false))
            viewModel.conversations[conversationIndex] = updatedConv
        }
    }
} 