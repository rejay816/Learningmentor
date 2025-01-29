import SwiftUI

@MainActor
class FilePreviewViewModel: ObservableObject {
    @Published private(set) var settings: TextSettings
    @Published var showSettings: Bool = false
    
    private var originalSettings: TextSettings
    private let storageManager = StorageManager.shared
    private let settingsKey = "filePreviewSettings"
    
    init(settings: TextSettings = .default) {
        let loadedSettings: TextSettings
        // 尝试从存储中加载设置
        if let savedSettings: TextSettings = try? StorageManager.shared.load(forKey: "filePreviewSettings") {
            loadedSettings = savedSettings
        } else {
            loadedSettings = settings
        }
        
        self.settings = loadedSettings
        self.originalSettings = loadedSettings
    }
    
    // MARK: - Font Management
    func updateFont(_ fontName: String) {
        guard FontSettings.isAvailable(fontName) else { return }
        settings.selectedFont = fontName
        objectWillChange.send()
        saveSettings()
    }
    
    func updateFontSize(_ size: CGFloat) {
        settings.fontSize = size.clamped(min: 12, max: 32)
        objectWillChange.send()
        saveSettings()
    }
    
    // MARK: - Spacing Management
    func updateLineSpacing(_ spacing: CGFloat) {
        settings.lineSpacing = spacing.clamped(min: 4, max: 20)
        objectWillChange.send()
        saveSettings()
    }
    
    func updateParagraphSpacing(_ spacing: CGFloat) {
        settings.paragraphSpacing = spacing.clamped(min: 8, max: 24)
        objectWillChange.send()
        saveSettings()
    }
    
    // MARK: - Theme Management
    func updateTheme(_ themeName: String) {
        guard ThemeSettings.theme(named: themeName) != nil else { return }
        settings.selectedTheme = themeName
        objectWillChange.send()
        saveSettings()
    }
    
    // MARK: - Settings Management
    func resetSettings() {
        settings = .default
        objectWillChange.send()
        saveSettings()
    }
    
    func saveSettings() {
        originalSettings = settings
        showSettings = false
        // 保存设置到存储
        try? storageManager.save(settings, forKey: settingsKey)
    }
    
    func cancelSettings() {
        settings = originalSettings
        showSettings = false
    }
    
    // MARK: - Computed Properties
    var currentTheme: ThemeSettings.Theme {
        ThemeSettings.theme(named: settings.selectedTheme) ?? ThemeSettings.defaultTheme
    }
    
    var currentFont: FontSettings.Font {
        FontSettings.font(named: settings.selectedFont) ?? FontSettings.defaultFont
    }
} 