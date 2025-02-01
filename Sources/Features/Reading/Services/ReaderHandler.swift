import AppKit
import Core

// @MainActor
// public class ReadingHandler {
//     private let fileHandler: FileHandler
//     
//     public init() {
//         self.fileHandler = FileHandler.shared
//     }
//     
//     public func canHandle(_ document: NSDocument) -> Bool {
//         // 检查是否是文本文件
//         guard let fileType = document.fileType else { return false }
//         
//         // 支持的文件类型
//         let supportedTypes = [
//             "text",
//             "json",
//             "xml",
//             "md",
//             "txt"
//         ]
//         
//         return supportedTypes.contains(fileType.lowercased())
//     }
//     
//     public func open(_ document: Any) {
//         guard let textDocument = document as? NSDocument else { return }
//         // 实现文档打开逻辑
//         // NotificationCenter.default.post(
//         //     name: .documentOpened,
//         //     object: textDocument,
//         //     userInfo: ["type": "text"]
//         // )
//     }
// } 

public class ReadingProcessor {
    // ...
} 