import AppKit
import Core
import Features

open class LegacyAppDelegate: NSObject /* , NSApplicationDelegate */ {
    public static let shared = LegacyAppDelegate()
    
    private let logger = Logger.shared
    private var documentController: NSDocumentController!
    private var readerHandler: ReadingHandler!
    private var listeningHandler: ListeningHandler!
    
    public override init() {
        super.init()
        logger.debug("AppDelegate initialized")
    }
    
    // MARK: - Private Methods
    
    private func setupDefaults() {
        // Configure default settings
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    private func setupHandlers() {
        documentController = NSDocumentController.shared
        readerHandler = ReadingHandler()
        listeningHandler = ListeningHandler()
    }
    
    private func configureAppearance() {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        // 配置主窗口
        if let window = NSApplication.shared.windows.first {
            window.title = "Learning Mentor"
            window.setFrameAutosaveName("MainWindow")
            window.center()
            window.makeKeyAndOrderFront(nil)
            
            // 配置工具栏
            if let toolbar = window.toolbar {
                toolbar.displayMode = .iconOnly
                toolbar.allowsUserCustomization = false
                toolbar.showsBaselineSeparator = false
            }
            
            // 激活应用程序
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    private func cleanup() {
        // Perform any necessary cleanup
    }
} 