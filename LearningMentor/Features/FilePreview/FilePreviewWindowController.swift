import SwiftUI
import AppKit

class FilePreviewWindowController: NSWindowController {
    convenience init(
        text: String,
        fileName: String,
        fileSize: String,
        fileType: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let contentView = FilePreviewView(
            text: text,
            fileName: fileName,
            fileSize: fileSize,
            fileType: fileType,
            onConfirm: onConfirm,
            onCancel: onCancel
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.contentView = NSHostingView(rootView: contentView)
        window.center()
        window.title = fileName
        window.setFrameAutosaveName("FilePreviewWindow")
        
        self.init(window: window)
    }
}

extension FilePreviewWindowController {
    static func showPreview(
        text: String,
        fileName: String,
        fileSize: String,
        fileType: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let windowController = FilePreviewWindowController(
            text: text,
            fileName: fileName,
            fileSize: fileSize,
            fileType: fileType,
            onConfirm: onConfirm,
            onCancel: onCancel
        )
        windowController.showWindow(nil)
        // 保持窗口控制器的引用
        NSApp.windows.first { $0.title == fileName }?.windowController = windowController
    }
} 