import SwiftUI
import PDFKit

public struct PDFKitView: NSViewRepresentable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    public func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(url: url)
    }
}

#Preview {
    PDFKitView(url: Bundle.main.url(forResource: "sample", withExtension: "pdf") ?? URL(fileURLWithPath: ""))
        .frame(width: 300, height: 400)
} 