import SwiftUI
import AppKit

struct FilePreviewView: View {
    @StateObject private var viewModel: FilePreviewViewModel
    @Environment(\.dismiss) private var dismiss
    
    let text: String
    let fileName: String
    let fileSize: String
    let fileType: String
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    init(
        text: String,
        fileName: String,
        fileSize: String,
        fileType: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.text = text
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileType = fileType
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _viewModel = StateObject(wrappedValue: FilePreviewViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextDisplayView(text: text, viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            HStack {
                Text("\(fileSize) · \(fileType)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("取消") {
                    onCancel()
                    NSApplication.shared.keyWindow?.close()
                }
                
                Button("导入") {
                    onConfirm(text)
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(fileName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsPanel(viewModel: viewModel)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    FilePreviewView(
        text: """
        Exemple de texte en français.
        Deuxième ligne de texte.
        
        Un nouveau paragraphe pour tester l'espacement.
        Plus de texte pour tester la lecture.
        """,
        fileName: "示例文档.txt",
        fileSize: "1 KB",
        fileType: "文本文件",
        onConfirm: { _ in },
        onCancel: {}
    )
} 