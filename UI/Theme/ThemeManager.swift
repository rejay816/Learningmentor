import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    struct Theme: Identifiable, Equatable {
        let id: String
        let name: String
        let textColor: Color
        let backgroundColor: Color
        let accentColor: Color
        
        static let classic = Theme(
            id: "classic",
            name: "经典纸张",
            textColor: .black,
            backgroundColor: Color(red: 0.98, green: 0.97, blue: 0.95),
            accentColor: .blue
        )
        
        static let parchment = Theme(
            id: "parchment",
            name: "羊皮纸",
            textColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            backgroundColor: Color(red: 0.96, green: 0.94, blue: 0.89),
            accentColor: Color(red: 0.6, green: 0.4, blue: 0.2)
        )
        
        static let modern = Theme(
            id: "modern",
            name: "现代",
            textColor: .black,
            backgroundColor: .white,
            accentColor: .blue
        )
        
        static let eyeCare = Theme(
            id: "eyeCare",
            name: "护眼",
            textColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            backgroundColor: Color(red: 0.94, green: 0.98, blue: 0.94),
            accentColor: .green
        )
        
        static let night = Theme(
            id: "night",
            name: "夜间",
            textColor: Color(red: 0.9, green: 0.9, blue: 0.9),
            backgroundColor: Color(red: 0.15, green: 0.15, blue: 0.15),
            accentColor: Color(red: 0.4, green: 0.4, blue: 0.8)
        )
    }
    
    let availableThemes: [Theme] = [
        .classic,
        .parchment,
        .modern,
        .eyeCare,
        .night
    ]
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
        }
    }
    
    private init() {
        let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? Theme.classic.id
        currentTheme = availableThemes.first { $0.id == savedThemeId } ?? Theme.classic
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    func theme(named name: String) -> Theme? {
        availableThemes.first { $0.name == name }
    }
} 