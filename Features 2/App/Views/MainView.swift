import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var fileHistoryManager: FileHistoryManager = .shared
    @StateObject private var errorHandler: ErrorHandler = .shared
    @StateObject private var networkMonitor: NetworkMonitor = .shared
    
    // 状态管理
    @State private var isShowingFileImporter = false
    @State private var isShowingExportDialog = false
    @State private var isShowingPromptPicker = false
    @State private var showFileHistory = false
    
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
    }
}

// 自定义按钮样式
struct NewChatButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 标题栏按钮样式
struct TitleBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 