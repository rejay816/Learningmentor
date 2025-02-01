import SwiftUI
import PDFKit
import Core

public struct DocumentRenderer: View {
    let document: Document
    @ObservedObject var viewModel: DocumentViewModel
    
    public init(document: Document, viewModel: DocumentViewModel) {
        self.document = document
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            switch document.content {
            case .pdf(let pdfDocument):
                PDFRendererView(document: pdfDocument)
                    .onAppear {
                        viewModel.pageCount = pdfDocument.pageCount
                    }
            
            case .text(let text):
                TextRendererView(text: text)
            
            case .attributedText(let attributedText):
                AttributedTextRendererView(text: attributedText)
            }
        }
    }
}

private struct PDFRendererView: NSViewRepresentable {
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

private struct TextRendererView: View {
    let text: String
    
    // 加一个 TTS 引擎
    private let tts = NSSpeechSynthesizer()
    
    var body: some View {
        VStack {
            ScrollView {
                // 显示文本，可选中
                Text(text)
                    .padding()
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            // 简单的"朗读"按钮
            Button(action: {
                // 开始朗读整篇文本
                tts.startSpeaking(text)
            }) {
                Label("朗读", systemImage: "speaker.wave.2.fill")
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AttributedTextRendererView: View {
    let text: NSAttributedString
    
    var body: some View {
        ScrollView {
            Text(AttributedString(text))
                .padding()
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - PDF 渲染器
struct PDFRenderer: NSViewRepresentable {
    let document: PDFDocument
    @Binding var currentPage: Int
    
    init(document: PDFDocument, currentPage: Binding<Int>) {
        self.document = document
        self._currentPage = currentPage
    }
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.delegate = context.coordinator
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        if let page = document.page(at: currentPage) {
            pdfView.go(to: page)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        var parent: PDFRenderer
        
        init(_ parent: PDFRenderer) {
            self.parent = parent
        }
        
        func pdfViewPageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let pageIndex = pdfView.document?.index(for: currentPage) else {
                return
            }
            parent.currentPage = pageIndex
        }
    }
}

// MARK: - 文本渲染器
struct TextRenderer: NSViewRepresentable {
    let text: String
    let font: NSFont
    let textColor: NSColor
    
    init(text: String,
         font: NSFont = .systemFont(ofSize: 16),
         textColor: NSColor = .textColor) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // 配置 TextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = font
        textView.textColor = textColor
        textView.drawsBackground = false
        
        // 设置文本容器
        let contentSize = scrollView.contentSize
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        // 配置 ScrollView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        textView.string = text
    }
} 