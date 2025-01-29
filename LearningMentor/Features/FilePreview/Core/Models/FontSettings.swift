import SwiftUI

struct FontSettings {
    struct Font: Identifiable, Equatable {
        let id: String
        let name: String
        let description: String
        
        init(name: String, description: String) {
            self.id = name
            self.name = name
            self.description = description
        }
    }
    
    static let availableFonts: [Font] = [
        Font(
            name: "Avenir Next",
            description: "现代无衬线，完美支持法语"
        ),
        Font(
            name: "Didot",
            description: "法国传统印刷体"
        ),
        Font(
            name: "Baskerville",
            description: "经典衬线，优雅"
        ),
        Font(
            name: "Optima",
            description: "人文主义无衬线，清晰"
        ),
        Font(
            name: "Cochin",
            description: "法式优雅衬线体"
        ),
        Font(
            name: "Garamond",
            description: "经典法式字体"
        )
    ]
    
    static func font(named name: String) -> Font? {
        availableFonts.first { $0.name == name }
    }
    
    static var defaultFont: Font {
        availableFonts[0]
    }
    
    // 验证字体是否可用
    static func isAvailable(_ fontName: String) -> Bool {
        NSFontManager.shared.availableFontFamilies.contains(fontName)
    }
} 