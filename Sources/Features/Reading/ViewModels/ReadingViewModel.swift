import Foundation
import SwiftUI
import Core
import AppKit
import PDFKit
import UniformTypeIdentifiers

@MainActor
public class ReadingViewModel: ObservableObject {
    @Published public var state: ReadingState = .idle
    @Published public var error: Error?
    
    private let fileHandler = FileHandler.shared
    private let logger = Logger.shared
    
    public func handleFileOpen() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.pdf, .plainText, .rtf]
        
        Task {
            guard panel.runModal() == .OK,
                  let url = panel.url else {
                return
            }
            
            do {
                let document = try await createDocument(from: url)
                state = .reading(document)
            } catch {
                self.error = error
                state = .error(error)
            }
        }
    }
    
    public func handleFileImport() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.pdf, .plainText, .rtf]
        
        Task {
            guard panel.runModal() == .OK,
                  !panel.urls.isEmpty else {
                return
            }
            
            do {
                var documents: [Document] = []
                for url in panel.urls {
                    if let document = try? await createDocument(from: url) {
                        documents.append(document)
                    }
                }
                
                if let document = documents.first {
                    state = .reading(document)
                } else {
                    throw DocumentError.invalidDocument
                }
            } catch {
                self.error = error
                state = .error(error)
            }
        }
    }
    
    private func createDocument(from url: URL) async throws -> Document {
        let fileType = url.pathExtension.lowercased()
        let fileName = url.lastPathComponent
        let documentId = UUID()
        
        switch fileType {
        case "pdf":
            guard let pdfDocument = PDFDocument(url: url) else {
                throw DocumentError.invalidPDF
            }
            return Document(
                id: documentId,
                url: url,
                title: fileName,
                type: .pdf(pdfDocument),
                content: .pdf(pdfDocument)
            )
            
        case "txt", "rtf":
            guard let text = try? String(contentsOf: url, encoding: .utf8) else {
                throw DocumentError.invalidTextEncoding
            }
            let documentType: DocumentType = fileType == "rtf" ? .richText(nil) : .plainText(text)
            return Document(
                id: documentId,
                url: url,
                title: fileName,
                type: documentType,
                content: .text(text)
            )
            
        default:
            throw DocumentError.invalidDocument
        }
    }
}

public enum ReadingState {
    case idle
    case reading(Document)
    case error(Error)
}

enum DocumentError: LocalizedError {
    case invalidPDF
    case invalidTextEncoding
    case invalidDocument
    
    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "无法加载 PDF 文档"
        case .invalidTextEncoding:
            return "无法加载文本文档"
        case .invalidDocument:
            return "无效的文档格式"
        }
    }
} 
