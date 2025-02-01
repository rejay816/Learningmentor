import Foundation

public protocol ErrorHandling: AnyObject {
    func handleError(_ error: Error)
    func clearError()
}

public extension ErrorHandling {
    func handleError(_ error: Error) {
        // 默认实现
        print("Error: \(error.localizedDescription)")
    }
    
    func clearError() {
        // 默认实现
    }
} 