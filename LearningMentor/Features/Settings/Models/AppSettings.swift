import Foundation

struct AppSettings: Codable {
    var theme: Theme
    var fontSize: Double
    var lineSpacing: Double
    var defaultModel: String
    var autoSave: Bool
    var showLineNumbers: Bool
    var enableSpellCheck: Bool
    var enableAutoComplete: Bool
    
    enum Theme: String, Codable, CaseIterable {
        case light
        case dark
        case system
        
        var displayName: String {
            switch self {
            case .light: return "浅色"
            case .dark: return "深色"
            case .system: return "跟随系统"
            }
        }
    }
    
    static let `default` = AppSettings(
        theme: .system,
        fontSize: 14,
        lineSpacing: 1.2,
        defaultModel: "gpt-3.5-turbo",
        autoSave: true,
        showLineNumbers: true,
        enableSpellCheck: true,
        enableAutoComplete: true
    )
}

extension AppSettings {
    var validatedFontSize: Double {
        min(max(fontSize, 10), 24)
    }
    
    var validatedLineSpacing: Double {
        min(max(lineSpacing, 1.0), 2.0)
    }
    
    mutating func validate() {
        fontSize = validatedFontSize
        lineSpacing = validatedLineSpacing
    }
} 