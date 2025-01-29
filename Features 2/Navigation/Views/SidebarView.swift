import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel = NavigationViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.items) { item in
                        NavigationItemView(
                            item: item,
                            isSelected: item.id == viewModel.selectedItem?.id
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.select(item)
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, maxWidth: 300)
    }
}

// MARK: - Preview
struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 标准预览
            SidebarView()
                .previewLayout(.fixed(width: 250, height: 500))
                .previewDisplayName("标准视图")
            
            // 深色模式
            SidebarView()
                .previewLayout(.fixed(width: 250, height: 500))
                .preferredColorScheme(.dark)
                .previewDisplayName("深色模式")
            
            // 窄屏预览
            SidebarView()
                .previewLayout(.fixed(width: 200, height: 500))
                .previewDisplayName("窄屏视图")
            
            // 宽屏预览
            SidebarView()
                .previewLayout(.fixed(width: 300, height: 500))
                .previewDisplayName("宽屏视图")
        }
        .padding()
    }
}

// MARK: - 模拟数据预览
struct SidebarView_WithSampleData_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NavigationViewModel()
        // 添加一些模拟数据
        viewModel.updateBadge(for: .reading, count: 3)
        viewModel.updateBadge(for: .listening, count: 5)
        viewModel.updateBadge(for: .notes, count: 10)
        
        return SidebarView()
            .previewLayout(.fixed(width: 250, height: 500))
            .previewDisplayName("带有标记的预览")
    }
} 