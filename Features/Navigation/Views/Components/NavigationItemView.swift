import SwiftUI

struct NavigationItemView: View {
    let item: NavigationItem
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(isSelected ? .accentColor : .primary)
                .frame(width: 24)
            
            Text(item.title)
                .foregroundColor(isSelected ? .accentColor : .primary)
            
            Spacer()
            
            if let badge = item.badge {
                Text("\(badge)")
                    .font(.caption2)
                    .padding(4)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

// MARK: - Preview
struct NavigationItemView_Previews: PreviewProvider {
    static var samples: [(NavigationItem, Bool, String)] = [
        (NavigationItem(type: .reading), false, "普通状态"),
        (NavigationItem(type: .listening), true, "选中状态"),
        (NavigationItem(type: .vocabulary, badge: 5), false, "带标记"),
        (NavigationItem(type: .notes, badge: 10), true, "选中且带标记"),
        (NavigationItem(type: .aiTools), false, "AI工具")
    ]
    
    static var previews: some View {
        Group {
            ForEach(samples, id: \.1) { item, isSelected, name in
                NavigationItemView(item: item, isSelected: isSelected)
                    .previewLayout(.fixed(width: 250, height: 44))
                    .previewDisplayName(name)
            }
            // 深色模式预览
            NavigationItemView(
                item: NavigationItem(type: .reading, badge: 3),
                isSelected: true
            )
            .previewLayout(.fixed(width: 250, height: 44))
            .preferredColorScheme(.dark)
            .previewDisplayName("深色模式")
        }
        .padding()
    }
} 