import Foundation

public enum ExportFormat: String, CaseIterable, Codable {
    case anki
    case markdown
    case word
    case pdf
    
    public var displayName: String {
        switch self {
        case .anki: return "Anki"
        case .markdown: return "Markdown"
        case .word: return "Word"
        case .pdf: return "PDF"
        }
    }
    
    public var description: String {
        switch self {
        case .anki: return "Anki 卡片"
        case .markdown: return "Markdown 文档"
        case .word: return "Word 文档"
        case .pdf: return "PDF 文档"
        }
    }
    
    var iconName: String {
        switch self {
        case .markdown:
            return "doc.plaintext"
        case .word:
            return "doc.text"
        case .pdf:
            return "doc.pdf"
        case .anki:
            return "rectangle.stack"
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .markdown:
            return "md"
        case .word:
            return "docx"
        case .pdf:
            return "pdf"
        case .anki:
            return "apkg"
        }
    }
    
    public func formatContent(_ messages: [ChatMessage]) -> String {
        switch self {
        case .markdown:
            return formatMarkdown(messages)
        case .word:
            return formatWord(messages)
        case .pdf:
            return formatPDF(messages)
        case .anki:
            return formatAnki(messages)
        }
    }
    
    private func formatMarkdown(_ messages: [ChatMessage]) -> String {
        var content = "# 对话记录\n\n"
        for message in messages {
            content += "## \(message.isUser ? "用户" : "AI")\n\n"
            content += "\(message.content)\n\n"
        }
        return content
    }
    
    private func formatWord(_ messages: [ChatMessage]) -> String {
        var content = "对话记录\n\n"
        for message in messages {
            content += "\(message.isUser ? "用户" : "AI")：\n"
            content += "\(message.content)\n\n"
        }
        return content
    }
    
    private func formatPDF(_ messages: [ChatMessage]) -> String {
        // For PDF, we'll use the same format as Word for now
        return formatWord(messages)
    }
    
    private func formatAnki(_ messages: [ChatMessage]) -> String {
        var content = ""
        for message in messages {
            content += "\(message.isUser ? "Q" : "A"): \(message.content)\n\n"
        }
        return content
    }
} 