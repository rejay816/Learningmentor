import SwiftUI

@MainActor
class NavigationViewModel: ObservableObject {
    @Published var selectedItem: NavigationItem?
    @Published var sections: [NavigationSection]
    
    init() {
        // 初始化导航分组和项目
        self.sections = [
            NavigationSection(title: "学习工具", items: [
                NavigationItem(type: .reading),
                NavigationItem(type: .listening),
                NavigationItem(type: .vocabulary)
            ]),
            NavigationSection(title: "辅助工具", items: [
                NavigationItem(type: .notes),
                NavigationItem(type: .aiTools)
            ])
        ]
        // 默认选中第一项
        self.selectedItem = sections.first?.items.first
    }
    
    func select(_ item: NavigationItem) {
        selectedItem = item
    }
    
    func updateBadge(for type: NavigationItemType, count: Int?) {
        for sectionIndex in sections.indices {
            if let itemIndex = sections[sectionIndex].items.firstIndex(where: { $0.type == type }) {
                var updatedItem = sections[sectionIndex].items[itemIndex]
                updatedItem.badge = count
                sections[sectionIndex].items[itemIndex] = updatedItem
            }
        }
    }
} 