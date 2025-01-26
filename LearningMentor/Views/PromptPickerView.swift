import SwiftUI

/// 保存和读取 Prompt 列表的简单工具
struct PromptStorage {
    static let key = "SavedPrompts"

    // 从 UserDefaults 加载 [String]
    static func loadPrompts() -> [String] {
        let defaults = UserDefaults.standard
        if let array = defaults.array(forKey: key) as? [String] {
            return array
        }
        return []
    }

    // 保存 [String] 到 UserDefaults
    static func savePrompts(_ prompts: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(prompts, forKey: key)
    }
}

struct PromptPickerView: View {
    // 当前的对话已有的 Prompt
    let currentPrompt: String

    // 回调
    var onCancel: () -> Void
    var onSelect: (String) -> Void

    // 本地存储的 Prompt 列表
    @State private var storedPrompts: [String] = []
    // 用户正在编辑的 Prompt
    @State private var newPrompt: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择或编辑 Prompt")
                .font(.headline)

            Text("当前 Prompt: \(currentPrompt.isEmpty ? "(无)" : currentPrompt)")
                .foregroundColor(.gray)

            // 列表显示已保存的 Prompt，可加载、删除
            Text("已保存的 Prompt 列表：")
                .font(.subheadline)

            List {
                ForEach(storedPrompts, id: \.self) { prompt in
                    HStack {
                        Text(prompt)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        // "加载"按钮：将此 prompt 填入编辑框
                        Button("加载") {
                            newPrompt = prompt
                        }
                        .buttonStyle(.link)
                        // "删除"按钮
                        Button("删除", role: .destructive) {
                            deletePrompt(prompt)
                        }
                        .buttonStyle(.link)
                    }
                }
            }
            .frame(height: 150)

            Divider()

            Text("自定义 / 编辑 Prompt：")
            TextEditor(text: $newPrompt)
                .frame(minHeight: 80)
                .border(Color.secondary)

            HStack {
                Spacer()
                Button("取消", action: onCancel)
                Button("确认") {
                    // 去除前后空格
                    let finalPrompt = newPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
                    // 如果该 Prompt 在列表中不存在，则追加保存
                    if !finalPrompt.isEmpty, !storedPrompts.contains(finalPrompt) {
                        storedPrompts.append(finalPrompt)
                        saveToUserDefaults()
                    }
                    // 回调父视图
                    onSelect(finalPrompt)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            // 初始化时读取已有存储
            loadFromUserDefaults()
            // 同时把当前 Prompt 放到编辑区 (可选)
            newPrompt = currentPrompt
        }
    }

    // MARK: - 存储与删除

    private func loadFromUserDefaults() {
        storedPrompts = PromptStorage.loadPrompts()
    }

    private func saveToUserDefaults() {
        // 排重 & 去空行后写入
        var cleaned = storedPrompts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        cleaned = Array(Set(cleaned))  // 去重
        PromptStorage.savePrompts(cleaned.sorted())
        storedPrompts = cleaned.sorted()
    }

    private func deletePrompt(_ prompt: String) {
        storedPrompts.removeAll { $0 == prompt }
        saveToUserDefaults()
    }
} 