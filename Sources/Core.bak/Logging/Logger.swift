import Foundation
import OSLog

public final class Logger {
    // MARK: - Properties
    
    public static let shared = Logger()
    private let osLog: OSLog
    
    // MARK: - Initialization
    
    private init() {
        self.osLog = OSLog(subsystem: "com.learningmentor", category: "app")
    }
    
    // MARK: - Logging Methods
    
    public func debug(_ message: String, category: Category = .default, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: .debug, category: category, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, category: Category = .default, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: .info, category: category, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, category: Category = .default, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: .warning, category: category, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, category: Category = .default, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: .error, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, type: LogType, category: Category, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(category.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        
        switch type {
        case .debug:
            os_log(.debug, log: osLog, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        case .warning:
            os_log(.error, log: osLog, "%{public}@", logMessage)
        case .error:
            os_log(.fault, log: osLog, "%{public}@", logMessage)
        }
    }
}

// MARK: - Supporting Types

extension Logger {
    public enum LogType {
        case debug
        case info
        case warning
        case error
    }
    
    public struct Category {
        public let rawValue: String
        
        public init(_ value: String) {
            self.rawValue = value
        }
        
        public static let `default` = Category("default")
        public static let network = Category("network")
        public static let database = Category("database")
        public static let ui = Category("ui")
        public static let language = Category("language")
    }
} 