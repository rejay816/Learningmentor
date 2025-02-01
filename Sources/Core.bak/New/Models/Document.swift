import Foundation
import PDFKit
import AppKit

public struct Document: Identifiable {
    public let id: UUID
    public let url: URL
    public let title: String
    public let type: DocumentType
    public let content: DocumentContent
    
    public init(id: UUID, url: URL, title: String, type: DocumentType, content: DocumentContent) {
        self.id = id
        self.url = url
        self.title = title
        self.type = type
        self.content = content
    }
}

public enum DocumentType {
    case pdf(PDFDocument)
    case plainText(String)
    case richText(NSAttributedString?)
}

public enum DocumentContent {
    case pdf(PDFDocument)
    case text(String)
    case attributedText(NSAttributedString)
} 