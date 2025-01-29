import Foundation
import os.log

class AppLogger {
    static let shared = AppLogger()
    private init() {}
    
    // 日志类别
    private let networkLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "Network")
    private let storageLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "Storage")
    private let uiLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "UI")
    private let chatLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "Chat")
    private let fileLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LearningMentor", category: "File")
    
    // 日志级别
    enum Level: String {
        case debug = "🔍"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
        case critical = "🚨"
    }
    
    // 日志类型
    enum Category {
        case network
        case storage
        case ui
        case chat
        case file
        
        var logger: Logger {
            switch self {
            case .network: return AppLogger.shared.networkLogger
            case .storage: return AppLogger.shared.storageLogger
            case .ui: return AppLogger.shared.uiLogger
            case .chat: return AppLogger.shared.chatLogger
            case .file: return AppLogger.shared.fileLogger
            }
        }
    }
    
    // MARK: - Logging Methods
    
    func log(_ message: String, level: Level = .info, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        let logger = category.logger
        let sourceInfo = "[\(URL(fileURLWithPath: file).lastPathComponent):\(line)] \(function)"
        let formattedMessage = "\(level.rawValue) \(message)\n\(sourceInfo)"
        
        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error:
            logger.error("\(formattedMessage)")
        case .critical:
            logger.critical("\(formattedMessage)")
        }
        
        #if DEBUG
        // 在调试模式下同时打印到控制台
        print(formattedMessage)
        #endif
    }
    
    // 便捷方法
    func debug(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
} 