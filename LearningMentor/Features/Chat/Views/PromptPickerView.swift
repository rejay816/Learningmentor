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
    let currentPrompt: String
    let onCancel: () -> Void
    let onSelect: (String) -> Void
    
    @State private var selectedPrompt: String
    @State private var customPrompt: String = ""
    
    private let predefinedPrompts = [
        "你是一位经验丰富的编程导师，擅长解释复杂的编程概念，并提供实用的编程建议。",
        "你是一位专业的代码审查者，帮助开发者优化代码质量，提供具体的改进建议。",
        "你是一位 AI 助手，专注于帮助用户学习和理解新的编程语言和框架。",
        "你是一位技术文档专家，帮助用户编写清晰、准确的技术文档和注释。"
    ]
    
    init(currentPrompt: String, onCancel: @escaping () -> Void, onSelect: @escaping (String) -> Void) {
        self.currentPrompt = currentPrompt
        self.onCancel = onCancel
        self.onSelect = onSelect
        _selectedPrompt = State(initialValue: currentPrompt)
        _customPrompt = State(initialValue: currentPrompt)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("预设提示词") {
                    ForEach(predefinedPrompts, id: \.self) { prompt in
                        HStack {
                            Text(prompt)
                                .lineLimit(2)
                            Spacer()
                            if selectedPrompt == prompt {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPrompt = prompt
                            customPrompt = prompt
                        }
                    }
                }
                
                Section("自定义提示词") {
                    TextEditor(text: $customPrompt)
                        .frame(height: 100)
                        .onChange(of: customPrompt) { oldValue, newValue in
                            selectedPrompt = newValue
                        }
                }
            }
            .navigationTitle("系统提示词")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消", action: onCancel)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        onSelect(selectedPrompt)
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    PromptPickerView(
        currentPrompt: "",
        onCancel: {},
        onSelect: { _ in }
    )
} 