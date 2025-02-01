import Foundation

public class Logger {
    public static let shared = Logger()
    
    private init() {}
    
    public func log(_ message: String) {
        print("[LOG] \(message)")
    }
    
    public func debug(_ message: String) {
        print("[DEBUG] \(message)")
    }
    
    public func info(_ message: String) {
        print("[INFO] \(message)")
    }
}
