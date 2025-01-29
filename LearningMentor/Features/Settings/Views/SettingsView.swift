import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("通用") {
                NavigationLink("语言设置") {
                    LanguageSettingsView()
                }
                
                NavigationLink("备份管理") {
                    BackupTestView()
                }
            }
        }
        .navigationTitle("设置")
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
} 