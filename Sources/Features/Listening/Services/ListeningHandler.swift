import AppKit
import Core

@MainActor
public class ListeningHandler {
    private let fileHandler: FileHandler
    
    public init() {
        self.fileHandler = FileHandler.shared
    }
    
    public func canHandle(_ document: Any) -> Bool {
        guard let document = document as? NSDocument,
              let fileType = document.fileType else { return false }
        
        // 支持的音频文件类型
        let supportedTypes = [
            "mp3",
            "wav",
            "m4a",
            "aac"
        ]
        
        return supportedTypes.contains(fileType.lowercased())
    }
    
    public func open(_ document: Any) {
        guard let audioDocument = document as? NSDocument else { return }
        // 实现音频文档打开逻辑
        NotificationCenter.default.post(
            name: .documentOpened,
            object: audioDocument,
            userInfo: ["type": "audio"]
        )
    }
} 