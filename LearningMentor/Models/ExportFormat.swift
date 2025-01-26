import Foundation

enum ExportFormat: String, Codable, CaseIterable {
    case text
    case markdown
    case json
    case html
    case anki
    
    var description: String {
        switch self {
        case .text: return "纯文本"
        case .markdown: return "Markdown"
        case .json: return "JSON"
        case .html: return "HTML"
        case .anki: return "Anki"
        }
    }
    
    var iconName: String {
        switch self {
        case .text: return "doc.text"
        case .markdown: return "doc.plaintext"
        case .json: return "curlybraces"
        case .html: return "chevron.left.forwardslash.chevron.right"
        case .anki: return "rectangle.stack"
        }
    }
    
    var contentType: String {
        switch self {
        case .text: return "text/plain"
        case .markdown: return "text/markdown"
        case .json: return "application/json"
        case .html: return "text/html"
        case .anki: return "application/json"
        }
    }
} 