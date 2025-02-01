import AppKit
import Core
import App
import Features

final class LearningMentorAppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger.shared
    private var documentController: NSDocumentController!
    private var readerHandler: ReadingHandler!
    private var listeningHandler: ListeningHandler!
    
    override init() {
        super.init()
        logger.debug("AppDelegate initialized")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.debug("Application did finish launching")
        setupDefaults()
        setupHandlers()
        configureAppearance()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        logger.debug("Application will terminate")
        cleanup()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // 当在 Finder 中双击 / 拖拽到图标 / 终端open时触发
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let docURL = URL(string: "file://"+filename),
              let document = try? documentController.openDocument(withContentsOf: docURL, display: false)
        else {
            return false
        }

        // 如果是文本或 PDF，希望走 SwiftUI 逻辑:
        if readerHandler.canHandle(document) {
            NotificationCenter.default.post(
                name: .documentOpened, 
                object: docURL,
                userInfo: ["type": "reader"]
            )
            return true
        }

        // 如果是音频，让 listeningHandler 处理
        if listeningHandler.canHandle(document) {
            listeningHandler.open(document)
            return true
        }

        return false
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            _ = application(sender, openFile: filename)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDefaults() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    private func setupHandlers() {
        documentController = NSDocumentController.shared
        readerHandler = ReadingHandler()
        listeningHandler = ListeningHandler()
    }
    
    private func configureAppearance() {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        if let window = NSApplication.shared.windows.first {
            window.title = "Learning Mentor"
            window.setFrameAutosaveName("MainWindow")
            window.center()
            window.makeKeyAndOrderFront(nil)
            
            if let toolbar = window.toolbar {
                toolbar.displayMode = .iconOnly
                toolbar.allowsUserCustomization = false
                toolbar.showsBaselineSeparator = false
            }
            
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    private func cleanup() {
        // Perform any necessary cleanup
    }
} 