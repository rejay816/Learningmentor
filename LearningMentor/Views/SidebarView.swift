import SwiftUI

struct SidebarView: View {
    @Binding var selectedConversation: Conversation?
    @ObservedObject var viewModel: LMMainViewModel
    @State private var isShowingRenameDialog = false
    @State private var conversationToRename: Conversation?
    @State private var newName = ""
    @State private var hoveredConversationId: UUID?
    
    var body: some View {
        List {
            Section(header: Text("Chats")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading, 4)
            ) {
                ForEach(viewModel.conversations.filter { !$0.isArchived }) { conversation in
                    ConversationRow(
                        conversation: conversation,
                        isSelected: selectedConversation?.id == conversation.id,
                        isHovered: hoveredConversationId == conversation.id
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedConversation = conversation
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
                            viewModel.archiveConversation(conversation)
                        }) {
                            Label("存档", systemImage: "archivebox")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.deleteConversation(conversation)
                        }) {
                            Label("删除", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.conversations)
            }
            
            if !viewModel.conversations.filter({ $0.isArchived }).isEmpty {
                Section(header: Text("已存档")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                ) {
                    ForEach(viewModel.conversations.filter { $0.isArchived }) { conversation in
                        ConversationRow(
                            conversation: conversation,
                            isSelected: selectedConversation?.id == conversation.id,
                            isHovered: hoveredConversationId == conversation.id,
                            isArchived: true
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedConversation = conversation
                            }
                        }
                        .onHover { isHovered in
                            hoveredConversationId = isHovered ? conversation.id : nil
                        }
                        .contextMenu {
                            Button(action: {
                                viewModel.unarchiveConversation(conversation)
                            }) {
                                Label("取消存档", systemImage: "archivebox")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                viewModel.deleteConversation(conversation)
                            }) {
                                Label("删除", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.conversations)
                }
            }
        }
        .alert("重命名会话", isPresented: $isShowingRenameDialog) {
            TextField("新名称", text: $newName)
            Button("取消", role: .cancel) {
                isShowingRenameDialog = false
            }
            Button("确定") {
                if let conversation = conversationToRename {
                    viewModel.renameConversation(conversation, to: newName)
                }
                isShowingRenameDialog = false
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.addConversation()
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.gray)
                }
            }
        }
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
            
            Text(conversation.shortTitle)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Spacer()
            
            if isHovered {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isHovered ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(
            selectedConversation: .constant(nil),
            viewModel: LMMainViewModel(apiKey: "test-key")
        )
    } detail: {
        Text("Preview Detail")
    }
}
