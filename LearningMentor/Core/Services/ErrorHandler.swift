import Foundation
import SwiftUI

public enum AppError: LocalizedError {
    case networkError(String)
    case apiError(String)
    case fileError(String)
    case storageError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误: \(message)"
        case .apiError(let message):
            return "API错误: \(message)"
        case .fileError(let message):
            return "文件错误: \(message)"
        case .storageError(let message):
            return "存储错误: \(message)"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
}

@MainActor
public class ErrorHandler: ObservableObject {
    public static let shared = ErrorHandler()
    
    @Published public var currentError: Error?
    @Published public var showError: Bool = false
    
    private init() {}
    
    public func handle(_ error: Error) {
        currentError = error
        showError = true
        
        #if DEBUG
        print("错误: \(error.localizedDescription)")
        if let appError = error as? AppError {
            print("AppError: \(appError)")
        }
        #endif
    }
    
    public func dismissError() {
        currentError = nil
        showError = false
    }
    
    public func errorAlert<Content: View>(_ content: Content) -> some View {
        content.alert(
            "错误",
            isPresented: Binding(
                get: { self.showError },
                set: { self.showError = $0 }
            ),
            presenting: currentError
        ) { _ in
            Button("确定") {
                self.dismissError()
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
} 