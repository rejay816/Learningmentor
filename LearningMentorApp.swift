import SwiftUI

@main
struct LearningMentorApp: App {
    @StateObject private var viewModel: ChatViewModel = {
        let openAIKey = KeychainService.shared.loadAPIKey(service: "OpenAI") ?? ""
        let deepSeekKey = KeychainService.shared.loadAPIKey(service: "DeepSeek") ?? ""
        return ChatViewModel(apiKey: openAIKey, deepSeekApiKey: deepSeekKey)
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
                .background {
                    WindowAccessor { window in
                        guard let window = window else { return }
                        ToolbarManager.shared.configure(for: window, viewModel: viewModel)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar) // 隐藏默认标题栏，使用自定义工具栏
        .windowToolbarStyle(.unified) // 使用统一的工具栏样式
    }
} 