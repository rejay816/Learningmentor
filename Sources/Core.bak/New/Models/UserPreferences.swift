import Foundation

public struct UserPreferences: Codable {
    public var preferredLanguage: SupportedLanguage
    public var theme: Theme
    public var fontSize: Int
    
    public static let `default` = UserPreferences(
        preferredLanguage: .english,
        theme: .system,
        fontSize: 16
    )
    
    public enum Theme: String, Codable {
        case light, dark, system
    }
} 