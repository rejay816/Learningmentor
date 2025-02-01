import Foundation
import NaturalLanguage

public enum SupportedLanguage: String, Equatable {
    case chinese = "zh"
    case english = "en"
    case french = "fr"
    
    /// Initialize from NLLanguage
    public init?(from nlLanguage: NLLanguage?) {
        guard let language = nlLanguage else { return nil }
        switch language {
        case .simplifiedChinese, .traditionalChinese:
            self = .chinese
        case .english:
            self = .english
        case .french:
            self = .french
        default:
            return nil
        }
    }
    
    /// Get the appropriate token unit for the language
    public var tokenUnit: NLTokenUnit {
        switch self {
        case .chinese:
            return .word
        case .english, .french:
            return .word
        }
    }
    
    public var nlLanguage: NLLanguage {
        switch self {
        case .english:
            return .english
        case .chinese:
            return .simplifiedChinese
        case .french:
            return .french
        }
    }
    
    public var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文"
        case .french:
            return "Français"
        }
    }
    
    public var localizedName: String {
        switch self {
        case .english:
            return "英语"
        case .chinese:
            return "中文"
        case .french:
            return "法语"
        }
    }
    
    public static var allCases: [SupportedLanguage] {
        return [.english, .chinese, .french]
    }
} 