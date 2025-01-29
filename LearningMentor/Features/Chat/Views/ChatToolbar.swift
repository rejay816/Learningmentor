import SwiftUI

struct ChatToolbar: ToolbarContent {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isShowingFileImporter: Bool
    @Binding var isShowingExportDialog: Bool
    @Binding var isShowingPromptPicker: Bool
    @Binding var showFileHistory: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            modelPicker
        }
        
        ToolbarItemGroup(placement: .primaryAction) {
            toolbarButtons
        }
    }
    
    private var modelPicker: some View {
        Picker("Model", selection: $viewModel.selectedModel) {
            ForEach(viewModel.availableModels, id: \.self) { model in
                Text(model).tag(model)
            }
        }
        .pickerStyle(.menu)
        .fixedSize()
    }
    
    private var toolbarButtons: some View {
        Group {
            Button(action: { isShowingFileImporter = true }) {
                Image(systemName: "doc.text.magnifyingglass")
                    .help("导入文件")
            }
            
            Button(action: { isShowingExportDialog = true }) {
                Image(systemName: "square.and.arrow.up")
                    .help("导出对话")
            }
            
            Button(action: { isShowingPromptPicker = true }) {
                Image(systemName: "text.book.closed")
                    .help("选择提示词")
            }
            
            Button(action: { showFileHistory = true }) {
                Image(systemName: "clock.arrow.circlepath")
                    .help("文件历史")
            }
        }
    }
} 