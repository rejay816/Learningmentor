import SwiftUI
import Core

public struct ReadingContentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    @State private var showSidebar = false
    
    public init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HSplitView {
            if let document = viewModel.document {
                DocumentRenderer(document: document, viewModel: viewModel)
                    .frame(minWidth: 400)
                
                if showSidebar {
                    SidebarView(viewModel: viewModel)
                        .frame(minWidth: 250, maxWidth: 400)
                }
            } else {
                EmptyStateView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showSidebar.toggle() }) {
                    Label("Toggle Sidebar", systemImage: "sidebar.right")
                }
            }
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Document Selected")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SidebarView: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack {
            Text("Document Info")
                .font(.headline)
                .padding()
            
            List {
                Section("Statistics") {
                    LabeledContent("Current Page", value: "\(viewModel.currentPage + 1) of \(viewModel.pageCount)")
                }
            }
        }
    }
} 