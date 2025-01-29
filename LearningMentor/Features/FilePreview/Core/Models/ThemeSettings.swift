import SwiftUI

struct ThemeSettings {
    struct Theme: Equatable, Identifiable {
        let id: String
        let name: String
        let textColor: Color
        let backgroundColor: Color
        
        init(name: String, textColor: Color, backgroundColor: Color) {
            self.id = name
            self.name = name
            self.textColor = textColor
            self.backgroundColor = backgroundColor
        }
    }
    
    static let availableThemes: [Theme] = [
        Theme(
            name: "经典纸张",
            textColor: Color(red: 0.1, green: 0.1, blue: 0.1),
            backgroundColor: Color(red: 0.98, green: 0.96, blue: 0.94)
        ),
        Theme(
            name: "羊皮纸",
            textColor: Color(red: 0.2, green: 0.15, blue: 0.1),
            backgroundColor: Color(red: 0.96, green: 0.94, blue: 0.89)
        ),
        Theme(
            name: "现代",
            textColor: .primary,
            backgroundColor: Color(.textBackgroundColor)
        ),
        Theme(
            name: "护眼",
            textColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.85)
        ),
        Theme(
            name: "夜间",
            textColor: Color(red: 0.85, green: 0.85, blue: 0.8),
            backgroundColor: Color(red: 0.15, green: 0.15, blue: 0.15)
        )
    ]
    
    static func theme(named name: String) -> Theme? {
        availableThemes.first { $0.name == name }
    }
    
    static var defaultTheme: Theme {
        availableThemes[0]
    }
} 