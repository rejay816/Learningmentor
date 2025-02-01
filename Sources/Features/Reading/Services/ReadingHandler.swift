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
            "pdf"
        ]
        
        return supportedTypes.contains(fileType.lowercased())
    }
    
    public func open(_ document: Any) {
        if document is NSDocument {
            // 实现文档打开逻辑
            // NotificationCenter.default.post(
            //     name: .documentOpened,
            //     object: document,
            //     userInfo: ["type": "reader"]
            // )
        }
    }
} 