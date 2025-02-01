import SwiftUI
import Core

@MainActor
public class ReadingAppEnvironment: ObservableObject {
    @Published public var state: ReaderState = .initial
    
    public init() {
        ReaderStateManager.shared.addObserver(self)
    }
    
    deinit {
        ReaderStateManager.shared.removeObserver(self)
    }
}

extension ReadingAppEnvironment: StateObserver {
    public nonisolated func stateDidChange(_ state: ReaderState) {
        Task { @MainActor [weak self] in
            self?.state = state
        }
    }
}

public struct ReadingContentView: View {
    @StateObject private var environment = ReadingAppEnvironment()
    
    public var body: some View {
        Group {
            switch environment.state {
            case .initial, .loading:
                ProgressView("加载中...")
            case .loaded(let document):
                DocumentRenderer(document: document, viewModel: DocumentViewModel())
            case .error(let message):
                ErrorView(message: message)
            }
        }
        .environmentObject(environment)
    }
}

private struct ErrorView: View {
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