import SwiftUI

struct SidebarView: View {
    @Binding var selectedConversation: Conversation?
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var searchViewModel: ConversationSearchViewModel
    @State private var isShowingRenameDialog = false
    @State private var conversationToRename: Conversation?
    @State private var newName = ""
    @State private var hoveredConversationId: UUID?
    
    init(selectedConversation: Binding<Conversation?>, viewModel: ChatViewModel) {
        self._selectedConversation = selectedConversation
        self.viewModel = viewModel
        self._searchViewModel = StateObject(wrappedValue: ConversationSearchViewModel(chatViewModel: viewModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            SearchBar(text: $searchViewModel.searchText)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            
            List {
                activeConversationsSection
                archivedConversationsSection
            }
            .listStyle(.sidebar)
        }
        .alert("重命名对话", isPresented: $isShowingRenameDialog) {
            TextField("对话名称", text: $newName)
            Button("取消", role: .cancel) {}
            Button("确定") {
                if let conversation = conversationToRename {
                    viewModel.renameConversation(conversation, to: newName)
                }
            }
        }
    }
    
    private var activeConversationsSection: some View {
        Section(header: sectionHeader("对话")) {
            ForEach(searchViewModel.filteredUnarchivedConversations) { conversation in
                conversationRow(for: conversation)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.conversations)
        }
    }
    
    private var archivedConversationsSection: some View {
        Group {
            if !searchViewModel.filteredArchivedConversations.isEmpty {
                Section(header: sectionHeader("已存档")) {
                    ForEach(searchViewModel.filteredArchivedConversations) { conversation in
                        conversationRow(for: conversation)
                    }
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.leading, 4)
    }
    
    private func conversationRow(for conversation: Conversation) -> some View {
        Text(conversation.title)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .background(selectedConversation?.id == conversation.id ? Color.accentColor.opacity(0.1) : Color.clear)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedConversation = conversation
                }
            }
            .contextMenu {
                Button(action: {
                    conversationToRename = conversation
                    newName = conversation.title
                    isShowingRenameDialog = true
                }) {
                    Label("重命名", systemImage: "pencil")
                }
                
                Button(action: {
                    if conversation.isArchived {
                        viewModel.unarchiveConversation(conversation)
                    } else {
                        viewModel.archiveConversation(conversation)
                    }
                }) {
                    Label(conversation.isArchived ? "取消存档" : "存档", 
                          systemImage: conversation.isArchived ? "archivebox.fill" : "archivebox")
                }
                
                Button(role: .destructive, action: {
                    viewModel.deleteConversation(conversation)
                }) {
                    Label("删除", systemImage: "trash")
                }
            }
    }
}

struct RenameDialog: View {
    let title: String
    @Binding var newName: String
    let onCancel: () -> Void
    let onRename: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("重命名对话")
                .font(.headline)
            
            TextField("输入新名称", text: $newName)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("取消", action: onCancel)
                Button("确定") {
                    onRename(newName)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newName.isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    let isSelected: Bool
    let isHovered: Bool
    var isArchived: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: isArchived ? "archivebox" : "message")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.shortTitle)
                    .lineLimit(1)
                if let lastMessage = conversation.messages.last {
                    Text(lastMessage.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if isHovered {
                Menu {
                    if isArchived {
                        Button(action: {}) {
                            Label("取消存档", systemImage: "archivebox")
                        }
                    } else {
                        Button(action: {}) {
                            Label("重命名", systemImage: "pencil")
                        }
                        Button(action: {}) {
                            Label("存档", systemImage: "archivebox")
                        }
                    }
                    Button(role: .destructive, action: {}) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(
            selectedConversation: .constant(nil),
            viewModel: ChatViewModel(apiKey: "test-key", deepSeekApiKey: "test-key")
        )
    } detail: {
        Text("Preview Detail")
    }
}
