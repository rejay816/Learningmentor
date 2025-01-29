import Foundation
import SwiftUI

@MainActor
public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    public struct Language: Identifiable, Equatable {
        public let id = UUID()
        public let code: String
        public let name: String
        public let flag: String
        
        public init(code: String, name: String, flag: String) {
            self.code = code
            self.name = name
            self.flag = flag
        }
        
        public static let english = Language(
            code: "en",
            name: "English",
            flag: "🇬🇧"
        )
        
        public static let chinese = Language(
            code: "zh-Hans",
            name: "Chinese (Simplified)",
            flag: "🇨🇳"
        )
        
        public static let french = Language(
            code: "fr",
            name: "French",
            flag: "🇫🇷"
        )
    }
    
    public let availableLanguages: [Language] = [
        .english,
        .chinese,
        .french
    ]
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.code, forKey: "selectedLanguageCode")
            updateLocale()
        }
    }
    
    private init() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguageCode")
        if let code = savedLanguageCode,
           let language = availableLanguages.first(where: { $0.code == code }) {
            self.currentLanguage = language
        } else {
            // 获取系统语言
            let locale = Locale.current
            let systemLanguageCode = locale.language.languageCode?.identifier ?? "en"
            
            // 检查是否支持该语言
            if let language = availableLanguages.first(where: { $0.code.starts(with: systemLanguageCode) }) {
                self.currentLanguage = language
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    private func updateLocale() {
        UserDefaults.standard.set([currentLanguage.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func localizedString(_ key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
} 