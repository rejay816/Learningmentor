import SwiftUI

@MainActor
class ConversationSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    private let chatViewModel: ChatViewModel
    
    init(chatViewModel: ChatViewModel) {
        self.chatViewModel = chatViewModel
    }
    
    var filteredUnarchivedConversations: [Conversation] {
        chatViewModel.unarchivedConversations.filter { conversation in
            searchText.isEmpty || 
            conversation.title.localizedCaseInsensitiveContains(searchText) ||
            conversation.messages.contains { message in
                message.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredArchivedConversations: [Conversation] {
        chatViewModel.archivedConversations.filter { conversation in
            searchText.isEmpty || 
            conversation.title.localizedCaseInsensitiveContains(searchText) ||
            conversation.messages.contains { message in
                message.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
} 