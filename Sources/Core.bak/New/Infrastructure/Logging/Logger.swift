import Foundation

public enum LogCategory {
    case `default`
    case network
    case database
    case ui
    case error
}

public protocol Logger {
    func debug(_ message: String, category: LogCategory)
    func info(_ message: String, category: LogCategory)
    func warning(_ message: String, category: LogCategory)
    func error(_ message: String, category: LogCategory)
} 