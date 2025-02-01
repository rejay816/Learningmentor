import SwiftUI

// 环境对象，用于在 SwiftUI 视图之间共享状态
@MainActor
public class AppEnvironment: ObservableObject {
    @Published public var state: Core.ReaderState = .initial
    
    public init() {
        // 订阅状态变化
        ReaderStateManager.shared.addObserver(self)
    }
    
    deinit {
        ReaderStateManager.shared.removeObserver(self)
    }
}

// 使 AppEnvironment 符合 StateObserver 协议
extension AppEnvironment: StateObserver {
    public nonisolated func stateDidChange(_ state: Core.ReaderState) {
        Task { @MainActor [weak self] in
            self?.state = state
        }
    }
}

// 主视图
struct ContentView: View {
    @StateObject private var environment = AppEnvironment()
    
    var body: some View {
        Group {
            switch environment.state {
            case .initial, .loading:
                ReaderView()
                    .environmentObject(environment)
            case .loaded(let document):
                SimpleDocumentView(document: document)
                    .environmentObject(environment)
            case .error(let message):
                ErrorView(message: message)
            }
        }
    }
}

// 错误视图
struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Text("发生错误")
                .font(.headline)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct ReaderHostingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 
