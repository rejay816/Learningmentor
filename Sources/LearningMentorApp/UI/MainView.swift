import SwiftUI
import AppKit
import Core
import Features

struct MainView: View {
    @EnvironmentObject var readingVM: ReadingViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("功能") {
                    NavigationLink(destination: ReadingHomeView()) {
                        Text("阅读")
                    }
                    // 可继续添加"听力"、"练习"等入口
                }
            }
            .listStyle(SidebarListStyle())
            
            Text("请选择左侧功能")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Learning Mentor")
    }
}

// 示例的阅读界面
struct ReadingHomeView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("阅读区")
                .font(.largeTitle)
            Text("这里可展示已导入的文档列表或网格；点击后弹出阅读器。")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 可视化预览（可选）
#Preview {
    MainView().environmentObject(ReadingViewModel())
} 