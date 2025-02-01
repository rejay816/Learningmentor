import AppKit
import Core

@MainActor
public class ReadingHandler {
    private let fileHandler: FileHandler
    
    public init() {
        self.fileHandler = FileHandler.shared
    }
    
    public func canHandle(_ document: NSDocument) -> Bool {
        guard let fileType = document.fileType else { return false }
        
        let supportedTypes = [
            "text",
            "json",
            "xml",
            "md",
            "txt",
            "pdf"  // 添加 PDF 支持
        ]
        
        return supportedTypes.contains(fileType.lowercased())
    }
    
    public func open(_ document: Any) {
        guard let textDocument = document as? NSDocument else { return }
        // NotificationCenter.default.post(
        //     name: .documentOpened,
        //     object: textDocument.fileURL,
        //     userInfo: ["type": "reader"]
        // )
    }
} 