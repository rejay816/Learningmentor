import Foundation

struct LMConversation: Identifiable, Equatable, Hashable {
    let id = UUID()
    var title: String = ""
    var messages: [LMChatMessage] = []
    var customPrompt: String = ""
    
    // Equatable conformance, for comparison in deletion etc.
    static func == (lhs: LMConversation, rhs: LMConversation) -> Bool {
        lhs.id == rhs.id
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 