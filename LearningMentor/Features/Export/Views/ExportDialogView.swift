import SwiftUI

struct ExportDialogView: View {
    let messages: [ChatMessage]
    
    // 多选
    @Binding var selectedMessages: [ChatMessage]
    
    var onDismiss: () -> Void
    var onExport: ([ChatMessage], ExportFormat) -> Void
    
    // 导出类型
    @State private var selectedFormat: ExportFormat = .anki
    
    // 用于行内编辑
    @State private var editingMessageID: UUID? = nil
    @State private var tempEditedText: String = ""
    
    // ─────────────────────────────────────────────
    // 新增：Anki 导出结果提示 
    // ─────────────────────────────────────────────
    @State private var showAnkiAlert = false
    @State private var ankiResultMessage = ""
    
    // 让本视图能直接调用 ankiService(示例写法)
    private let ankiService = AnkiService()
    
    // 添加导出进度追踪
    @State private var exportProgress: Double = 0
    @State private var isExporting = false
    @State private var currentExportStatus = ""
    
    // Anki 导出相关状态
    @State private var selectedDeckOption: DeckOption = .today
    @State private var selectedDeck: String = ""
    @State private var customDeckName: String = ""
    @State private var selectedTemplate: String = "French Listening"
    @State private var availableDecks: [String] = []
    @State private var availableTemplates: [String] = []
    @State private var isCreatingTemplate = false
    @State private var newTemplateName: String = ""
    @State private var newTemplateFields: [String] = ["正面", "背面"]
    
    // 添加用户偏好设置管理
    private enum UserDefaultsKeys {
        static let lastUsedTemplate = "lastUsedTemplate"
        static let lastUsedDeckOption = "lastUsedDeckOption"
        static let lastUsedCustomDeck = "lastUsedCustomDeck"
    }
    
    // 在 ExportDialogView 的初始化时加载上次的设置
    init(messages: [ChatMessage], selectedMessages: Binding<[ChatMessage]>, onDismiss: @escaping () -> Void, onExport: @escaping ([ChatMessage], ExportFormat) -> Void) {
        self.messages = messages
        self._selectedMessages = selectedMessages
        self.onDismiss = onDismiss
        self.onExport = onExport
        
        // 加载上次使用的设置
        let defaults = UserDefaults.standard
        _selectedTemplate = State(initialValue: defaults.string(forKey: UserDefaultsKeys.lastUsedTemplate) ?? "French Listening")
        _selectedDeckOption = State(initialValue: DeckOption(rawValue: defaults.string(forKey: UserDefaultsKeys.lastUsedDeckOption) ?? "today") ?? .today)
        _customDeckName = State(initialValue: defaults.string(forKey: UserDefaultsKeys.lastUsedCustomDeck) ?? "")
    }
    
    // 在设置改变时保存
    private func saveUserPreferences() {
        let defaults = UserDefaults.standard
        defaults.set(selectedTemplate, forKey: UserDefaultsKeys.lastUsedTemplate)
        defaults.set(selectedDeckOption.rawValue, forKey: UserDefaultsKeys.lastUsedDeckOption)
        defaults.set(customDeckName, forKey: UserDefaultsKeys.lastUsedCustomDeck)
    }
    
    // Deck 选择选项
    enum DeckOption: String, CaseIterable {
        case today = "today"
        case existing = "existing"
        case custom = "custom"
        
        var description: String {
            switch self {
            case .today: return "今日牌组"
            case .existing: return "选择已有牌组"
            case .custom: return "自定义牌组"
            }
        }
    }
    
    // 添加取消导出状态
    @State private var canCancelExport: Bool = false
    
    // 添加拖拽状态
    @State private var draggedMessage: ChatMessage?
    
    // 添加预览状态
    @State private var showPreview = false
    @State private var previewCards: [FrenchListeningCard] = []
    
    // 添加历史记录管理器
    @StateObject private var historyManager = ExportHistoryManager()
    @State private var showHistory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部控制栏
            HStack {
                Button("全选") {
                    selectedMessages = messages
                }
                Button("全不选") {
                    selectedMessages.removeAll()
                }
                
                Spacer()
                
                // 导出格式选择
                Picker("格式：", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.iconName)
                            Text(format.description)
                        }
                        .tag(format)
                    }
                }
            }
            
            // 消息列表
            List {
                ForEach(messages) { message in
                    HStack(spacing: 8) {
                        // 选择框
                        Toggle("", isOn: Binding(
                            get: { selectedMessages.contains(where: { $0.id == message.id }) },
                            set: { isSelected in
                                if isSelected {
                                    selectedMessages.append(message)
                                } else {
                                    selectedMessages.removeAll { $0.id == message.id }
                                }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                        .scaleEffect(0.9)
                        
                        // 消息内容
                        MessageRow(
                            message: message,
                            isEditing: editingMessageID == message.id,
                            tempEditedText: $tempEditedText,
                            onEdit: {
                                editingMessageID = message.id
                                tempEditedText = message.content
                            },
                            onCancelEdit: {
                                editingMessageID = nil
                            },
                            onSaveEdit: {
                                replaceMessageContent(msgID: message.id, newContent: tempEditedText)
                                editingMessageID = nil
                            }
                        )
                    }
                    .listRowBackground(
                        selectedMessages.contains(where: { $0.id == message.id }) ?
                            Color.accentColor.opacity(0.1) :
                            Color.clear
                    )
                }
            }
            .listStyle(InsetListStyle())
            
            // Anki 设置（如果选择了 Anki 格式）
            if selectedFormat == .anki {
                ankiSettingsView
            }
            
            // 进度视图
            progressView
            
            // 底部按钮
            HStack {
                Text("\(selectedMessages.count) 条消息已选择")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("历史记录") {
                    showHistory = true
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                if selectedFormat == .anki {
                    Button("预览") {
                        previewCards = parseMultipleFrenchListeningCards(selectedMessages)
                        showPreview = true
                    }
                    .disabled(selectedMessages.isEmpty)
                }
                
                Button("取消", action: onDismiss)
                
                Button("导出") {
                    if selectedFormat == .anki {
                        exportToAnki()
                    } else {
                        onExport(selectedMessages, selectedFormat)
                        historyManager.addRecord(ExportRecord(
                            format: selectedFormat,
                            cardCount: selectedMessages.count
                        ))
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedMessages.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showPreview) {
            previewSheet
        }
        .sheet(isPresented: $showHistory) {
            ExportHistoryView(historyManager: historyManager)
        }
        .alert(isPresented: $showAnkiAlert) {
            Alert(
                title: Text("Anki导出结果"),
                message: Text(ankiResultMessage),
                dismissButton: .default(Text("确定"), action: { onDismiss() })
            )
        }
    }
    
    // 将编辑后的内容替换到 messages 和 selectedMessages 中
    private func replaceMessageContent(msgID: UUID, newContent: String) {
        if let idx = selectedMessages.firstIndex(where: { $0.id == msgID }) {
            var m = selectedMessages[idx]
            m.content = newContent
            selectedMessages[idx] = m
        }
    }
    
    // STEP 1: 定义一个新的解析函数，适合「French Listening」模板三字段
    private func parseToAnkiCardsForFrenchListening(messages: [ChatMessage]) -> [FrenchListeningCard] {
        // 将多条聊天合并为一段文本，或者逐条解析看是否包含【法语表达】【翻译】【Note】，自行选择
        // 示例：简单拼接
        let combinedContent = messages.map { $0.content }.joined(separator: "\n")
        
        // 正则/或手动搜索三段
        // 为示例，假设它们的顺序固定：「【法语表达】：...」「【翻译】：...」「【Note】：...」
        // 并且只处理第一次出现
        guard let exprRange = combinedContent.range(of: "【法语表达】："),
              let transRange = combinedContent.range(of: "【翻译】：", range: exprRange.upperBound..<combinedContent.endIndex),
              let noteRange = combinedContent.range(of: "【Note】：", range: transRange.upperBound..<combinedContent.endIndex)
        else {
            // 如果没匹配到，返回空
            return []
        }
        
        // 提取 expr文本
        let exprTextStart = exprRange.upperBound
        let exprTextEnd = transRange.lowerBound
        let exprText = combinedContent[exprTextStart..<exprTextEnd]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 提取 翻译文本
        let transTextStart = transRange.upperBound
        let transTextEnd = noteRange.lowerBound
        let transText = combinedContent[transTextStart..<transTextEnd]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 提取 Note 文本
        let noteTextStart = noteRange.upperBound
        let noteText = combinedContent[noteTextStart..<combinedContent.endIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 构造单个卡片
        let card = FrenchListeningCard(
            expression: String(exprText),
            translation: String(transText),
            note: String(noteText)
        )
        return [card]
    }
    
    // 新的结构体
    struct FrenchListeningCard {
        let expression: String  // 【法语表达】
        let translation: String // 【翻译】
        let note: String        // 【Note】
    }
    
    // 当用户选了 "Anki" 时的处理逻辑
    private func exportToAnki() {
        let cards = parseMultipleFrenchListeningCards(selectedMessages)
        guard !cards.isEmpty else {
            ankiResultMessage = "未找到有效的卡片内容，请确保内容包含【法语表达】标记"
            showAnkiAlert = true
            // 记录失败
            historyManager.addRecord(ExportRecord(
                format: .anki,
                deckName: getDeckName(),
                template: selectedTemplate,
                cardCount: 0,
                success: false,
                errorMessage: "未找到有效的卡片内容"
            ))
            return
        }
        
        let deckName = getDeckName()
        guard !deckName.isEmpty else {
            ankiResultMessage = "请选择或输入有效的牌组名称"
            showAnkiAlert = true
            // 记录失败
            historyManager.addRecord(ExportRecord(
                format: .anki,
                template: selectedTemplate,
                cardCount: cards.count,
                success: false,
                errorMessage: "未选择牌组"
            ))
            return
        }
        
        isExporting = true
        exportProgress = 0
        canCancelExport = true
        
        Task {
            do {
                currentExportStatus = "正在创建牌组..."
                try await ankiService.createDeckIfNeeded(deckName: deckName)
                
                let noteDicts = cards.map { makeNoteDict(deckName: deckName, card: $0) }
                
                currentExportStatus = "正在导入卡片..."
                let (created, duplicates, errors) = try await ankiService.addNotesInBatches(
                    deckName: deckName,
                    noteDictArray: noteDicts
                )
                
                exportProgress = 1.0
                currentExportStatus = "导入完成"
                
                var resultMessage = "导入结果：\n"
                resultMessage += "✅ 成功导入：\(created) 张卡片\n"
                if duplicates > 0 {
                    resultMessage += "⚠️ 重复跳过：\(duplicates) 张卡片\n"
                }
                if errors > 0 {
                    resultMessage += "❌ 导入失败：\(errors) 张卡片\n"
                }
                resultMessage += "\n牌组名称：\(deckName)"
                
                ankiResultMessage = resultMessage
                showAnkiAlert = true
                
                // 记录成功
                historyManager.addRecord(ExportRecord(
                    format: .anki,
                    deckName: deckName,
                    template: selectedTemplate,
                    cardCount: created,
                    success: true
                ))
            } catch {
                handleAnkiError(error)
                // 记录失败
                historyManager.addRecord(ExportRecord(
                    format: .anki,
                    deckName: deckName,
                    template: selectedTemplate,
                    cardCount: cards.count,
                    success: false,
                    errorMessage: error.localizedDescription
                ))
            }
            
            isExporting = false
            canCancelExport = false
        }
    }
    
    private func handleAnkiError(_ error: Error) {
        let errorMessage: String
        switch error {
        case let ankiError as AnkiServiceError:
            switch ankiError {
            case .connectionFailed:
                errorMessage = "无法连接到 Anki，请确保 Anki 已启动且 AnkiConnect 插件已安装"
            case .invalidResponse:
                errorMessage = "Anki 返回了无效的响应，请检查 AnkiConnect 插件是否正常"
            case .deckCreationFailed:
                errorMessage = "创建牌组失败，请检查牌组名称是否有效"
            case .noteAdditionFailed:
                errorMessage = "添加卡片失败，请检查卡片格式是否正确"
            }
        default:
            errorMessage = "导入过程出错：\(error.localizedDescription)"
        }
        ankiResultMessage = errorMessage
        showAnkiAlert = true
    }
    
    private func makeNoteDict(deckName: String, card: FrenchListeningCard) -> [String: Any] {
        // 根据选择的模板构造字段
        var fields: [String: String] = [:]
        
        // 根据不同模板设置不同的字段映射
        switch selectedTemplate {
        case "French Listening":
            fields = [
                "法语表达": card.expression.trimmingCharacters(in: .whitespacesAndNewlines),
                "翻译": card.translation.trimmingCharacters(in: .whitespacesAndNewlines),
                "Note": card.note.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
        default:
            // 对于其他模板，使用通用的前后面字段
            fields = [
                "正面": card.expression.trimmingCharacters(in: .whitespacesAndNewlines),
                "背面": "\(card.translation)\n\nNote: \(card.note)".trimmingCharacters(in: .whitespacesAndNewlines)
            ]
        }
        
        return [
            "deckName": deckName,
            "modelName": selectedTemplate,
            "fields": fields,
            "options": [
                "allowDuplicate": false,
                "duplicateScope": "deck",
                "duplicateScopeOptions": [
                    "deckName": deckName,
                    "checkChildren": false
                ]
            ],
            "tags": ["french", "listening", "auto-import"]
        ]
    }
    
    private func parseMultipleFrenchListeningCards(_ messages: [ChatMessage]) -> [FrenchListeningCard] {
        let combinedContent = messages.map { $0.content }.joined(separator: "\n")
        
        // ① 按行或分隔符拆分，然后手动扫描
        //    每遇 "【法语表达】：" 视为新卡片开头，再依序寻找翻译、Note。
        //    如果再次碰到 "【法语表达】：" 则视为下一卡片的开始，结束上一卡片。

        // 为简单，先把文本按 "【法语表达】：" 切割
        // segments[0] 是开头无关内容(可能为空)，segments[1...] 是各卡片
        let segments = combinedContent.components(separatedBy: "【法语表达】：")
        guard segments.count > 1 else {
            return []
        }
        
        var cards = [FrenchListeningCard]()
        
        // 从下标1开始遍历，跳过没用的 segments[0]
        for segment in segments.dropFirst() {
            // 在 segment 内，我们再找 "【翻译】：" 和 "【Note】："
            // 注意可能找不到翻译或找不到Note，则视为空

            // 1) 先拿 expression(本段直到【翻译】、【Note】或结尾)
            //    expression = segment 的开头(去掉前后空白)
            var expression = segment
            var translation = ""
            var note = ""
            
            // 找【翻译】:
            if let transRange = expression.range(of: "【翻译】：") {
                // expression 到 transRange 之前就是法语表达
                let exprPart = expression[..<transRange.lowerBound]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                expression = String(exprPart)
                
                // 余下部分再去解析翻译和Note
                let afterTrans = segment[transRange.upperBound...]
                
                // 找【Note】:
                if let noteRange = afterTrans.range(of: "【Note】：") {
                    // 翻译 部分: from start to noteRange
                    let transPart = afterTrans[..<noteRange.lowerBound]
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    translation = String(transPart)
                    
                    // note 部分: from noteRange to end
                    let notePart = afterTrans[noteRange.upperBound...]
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    note = String(notePart)
                } else {
                    // 没找到 Note，只提取翻译
                    translation = String(afterTrans.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else {
                // 没有【翻译】，expression 全部就是 segment
                expression = segment.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // 去除空行
            expression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
            translation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
            note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 过滤空 expression(没【法语表达】)情况
            if !expression.isEmpty {
                // 生成卡片
                let card = FrenchListeningCard(
                    expression: expression,
                    translation: translation,
                    note: note
                )
                cards.append(card)
            }
        }
        
        return cards
    }
    
    // 在 body 中添加进度指示器
    private var progressView: some View {
        VStack {
            if isExporting {
                VStack(spacing: 8) {
                    ProgressView(currentExportStatus, value: exportProgress, total: 1.0)
                        .progressViewStyle(.linear)
                    
                    if canCancelExport {
                        Button("取消导出") {
                            ankiService.cancelCurrentOperation()
                            isExporting = false
                            currentExportStatus = "导出已取消"
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
        }
    }
    
    // 加载 Anki 数据
    private func loadAnkiData() {
        Task {
            do {
                availableDecks = try await ankiService.getDecks()
                availableTemplates = try await ankiService.getModels()
            } catch {
                print("Failed to load Anki data: \(error)")
            }
        }
    }
    
    // 创建新模板
    private func createNewTemplate() {
        Task {
            do {
                try await ankiService.createModel(
                    name: newTemplateName,
                    fields: ["正面", "背面", "例句", "注释"]
                )
                // 刷新模板列表
                availableTemplates = try await ankiService.getModels()
                // 重置状态
                isCreatingTemplate = false
                newTemplateName = ""
            } catch {
                print("Failed to create template: \(error)")
            }
        }
    }
    
    // 修改 ankiSettingsView
    private var ankiSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anki 导出设置")
                .font(.headline)
            
            // 牌组选择
            VStack(alignment: .leading, spacing: 8) {
                Text("选择牌组：")
                    .font(.subheadline)
                
                Picker("牌组选项", selection: Binding(
                    get: { selectedDeckOption },
                    set: { 
                        selectedDeckOption = $0
                        saveUserPreferences()
                    }
                )) {
                    ForEach(DeckOption.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                
                switch selectedDeckOption {
                case .today:
                    Text("将导入到：French_\(todayString())")
                        .foregroundColor(.secondary)
                        .font(.caption)
                case .existing:
                    Picker("选择牌组", selection: $selectedDeck) {
                        ForEach(availableDecks, id: \.self) { deck in
                            Text(deck).tag(deck)
                        }
                    }
                case .custom:
                    TextField("输入牌组名称", text: Binding(
                        get: { customDeckName },
                        set: { 
                            customDeckName = $0
                            saveUserPreferences()
                        }
                    ))
                }
            }
            
            Divider()
            
            // 模板选择
            VStack(alignment: .leading, spacing: 8) {
                Text("选择模板：")
                    .font(.subheadline)
                
                HStack {
                    Picker("选择模板", selection: Binding(
                        get: { selectedTemplate },
                        set: { 
                            selectedTemplate = $0
                            saveUserPreferences()
                        }
                    )) {
                        ForEach(availableTemplates, id: \.self) { template in
                            Text(template).tag(template)
                        }
                    }
                    
                    Button("新建模板") {
                        isCreatingTemplate = true
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .sheet(isPresented: $isCreatingTemplate) {
            createTemplateView
        }
        .onAppear {
            loadAnkiData()
        }
    }
    
    // 新建模板视图
    private var createTemplateView: some View {
        VStack(spacing: 16) {
            Text("新建 Anki 模板")
                .font(.headline)
            
            TextField("模板名称", text: $newTemplateName)
                .textFieldStyle(.roundedBorder)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("字段：")
                    .font(.subheadline)
                
                ForEach(newTemplateFields.indices, id: \.self) { index in
                    HStack {
                        TextField("字段名称", text: $newTemplateFields[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if newTemplateFields.count > 2 {
                            Button(action: {
                                newTemplateFields.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Button("添加字段") {
                    newTemplateFields.append("")
                }
            }
            
            HStack {
                Button("取消") {
                    isCreatingTemplate = false
                }
                
                Button("创建") {
                    createNewTemplate()
                }
                .disabled(newTemplateName.isEmpty || newTemplateFields.contains(""))
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private func todayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private func getDeckName() -> String {
        switch selectedDeckOption {
        case .today:
            return "French_\(todayString())"
        case .existing:
            return selectedDeck
        case .custom:
            return customDeckName
        }
    }
    
    // 提取 MessageRow 为单独的视图
    struct MessageRow: View {
        let message: ChatMessage
        let isEditing: Bool
        @Binding var tempEditedText: String
        let onEdit: () -> Void
        let onCancelEdit: () -> Void
        let onSaveEdit: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    // 编辑状态
                    VStack(alignment: .leading, spacing: 4) {
                        TextEditor(text: $tempEditedText)
                            .frame(minHeight: 60)
                            .border(Color.secondary)
                        HStack {
                            Spacer()
                            Button("取消", action: onCancelEdit)
                            Button("完成", action: onSaveEdit)
                                .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    // 显示状态
                    HStack {
                        Image(systemName: message.isUser ? "person.circle" : "brain.head.profile")
                            .foregroundColor(message.isUser ? .blue : .green)
                        Text(message.isUser ? "User" : "AI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("编辑", action: onEdit)
                            .buttonStyle(.link)
                    }
                    
                    Text(message.content)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .font(.system(.body))
                        .foregroundColor(.primary)
                        .padding(.vertical, 2)
                        // 添加展开/收起功能
                        .onTapGesture {
                            withAnimation {
                                // 如果需要展开/收起功能，可以在这里添加状态切换
                            }
                        }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())  // 确保整个区域都可以响应点击
        }
    }
    
    // 添加预览视图
    private var previewSheet: some View {
        VStack(spacing: 16) {
            HStack {
                Text("预览导出内容")
                    .font(.headline)
                Spacer()
                Button("关闭") {
                    showPreview = false
                }
            }
            .padding(.bottom)
            
            if previewCards.isEmpty {
                Text("未找到有效的卡片内容")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(previewCards, id: \.expression) { card in
                            CardPreviewView(card: card, template: selectedTemplate)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
    }
    
    // 卡片预览组件
    struct CardPreviewView: View {
        let card: FrenchListeningCard
        let template: String
        @State private var showBack = false
        
        var body: some View {
            VStack(spacing: 12) {
                // 卡片正面
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("正面")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(showBack ? "隐藏答案" : "显示答案") {
                            withAnimation {
                                showBack.toggle()
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Text(card.expression)
                        .font(.system(.body, design: .serif))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                
                // 卡片背面
                if showBack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("背面")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if template == "French Listening" {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("翻译：").foregroundColor(.secondary) +
                                Text(card.translation)
                                
                                if !card.note.isEmpty {
                                    Text("笔记：").foregroundColor(.secondary) +
                                    Text(card.note)
                                }
                            }
                        } else {
                            Text("\(card.translation)\n\nNote: \(card.note)")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
} 
