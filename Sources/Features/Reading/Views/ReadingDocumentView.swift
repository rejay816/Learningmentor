import SwiftUI
import PDFKit
import Core

public struct ReadingDocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var scale: CGFloat = 1.0
    
    public init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if let document = viewModel.document {
                documentContent(for: document)
            } else {
                emptyState
            }
        }
        .navigationTitle(viewModel.title)
    }
    
    @ViewBuilder
    private func documentContent(for document: Document) -> some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbar
            
            // 文档内容
            ScrollView([.horizontal, .vertical]) {
                documentView(for: document)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value.magnitude
                            }
                    )
            }
        }
    }
    
    private var toolbar: some View {
        HStack {
            Button(action: { scale = 1.0 }) {
                Image(systemName: "1.magnifyingglass")
            }
            .help("重置缩放")
            
            Button(action: { scale *= 1.2 }) {
                Image(systemName: "plus.magnifyingglass")
            }
            .help("放大")
            
            Button(action: { scale /= 1.2 }) {
                Image(systemName: "minus.magnifyingglass")
            }
            .help("缩小")
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.windowBackgroundColor))
    }
    
    private var emptyState: some View {
        VStack {
            Image(systemName: "doc.text.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("没有打开的文档")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func documentView(for document: Document) -> some View {
        switch document.content {
        case .pdf(let pdfDocument):
            PDFKitView(document: pdfDocument)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        case .text(let text):
            Text(text)
                .padding()
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
        case .attributedText(let attributedText):
            Text(AttributedString(attributedText))
                .padding()
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

private struct PDFKitView: NSViewRepresentable {
    let document: PDFDocument
    
    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePage
        view.displayDirection = .vertical
        return view
    }
    
    func updateNSView(_ view: PDFView, context: Context) {
        view.document = document
    }
} 