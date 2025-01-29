import SwiftUI

/// 导航项类型枚举
enum NavigationItemType {
    case reading
    case listening
    case vocabulary
    case notes
    case aiTools
    
    var icon: String {
        switch self {
        case .reading: return "book"
        case .listening: return "headphones"
        case .vocabulary: return "textformat"
        case .notes: return "note.text"
        case .aiTools: return "brain"
        }
    }
    
    var title: String {
        switch self {
        case .reading: return "阅读"
        case .listening: return "听力"
        case .vocabulary: return "生词本"
        case .notes: return "笔记"
        case .aiTools: return "AI工具"
        }
    }
}

/// 导航项模型
struct NavigationItem: Identifiable, Hashable {
    let id = UUID()
    let type: NavigationItemType
    var title: String { type.title }
    var icon: String { type.icon }
    var badge: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// 导航分组
struct NavigationSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [NavigationItem]
} 