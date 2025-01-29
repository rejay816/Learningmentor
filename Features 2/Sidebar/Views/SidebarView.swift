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
            SearchBar(text: $searchViewModel.searchText)
            
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
            .onHover { isHovered in
                hoveredConversationId = isHovered ? conversation.id : nil
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

// 自定义按钮样式
struct NewChatButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.accentColor.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 