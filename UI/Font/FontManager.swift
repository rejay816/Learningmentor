import SwiftUI

class FontManager: ObservableObject {
    static let shared = FontManager()
    
    struct Font: Identifiable, Equatable {
        let id: String
        let name: String
        let description: String
        
        static let avenirNext = Font(
            id: "avenirNext",
            name: "Avenir Next",
            description: "现代优雅的无衬线字体，适合阅读法语文本"
        )
        
        static let didot = Font(
            id: "didot",
            name: "Didot",
            description: "优雅的衬线字体，体现法式优雅"
        )
        
        static let baskerville = Font(
            id: "baskerville",
            name: "Baskerville",
            description: "经典的衬线字体，适合长文本阅读"
        )
        
        static let optima = Font(
            id: "optima",
            name: "Optima",
            description: "优雅的人文主义无衬线字体，结合了衬线和无衬线字体的特点"
        )
        
        static let cochin = Font(
            id: "cochin",
            name: "Cochin",
            description: "优雅的法式衬线字体，适合阅读"
        )
        
        static let garamond = Font(
            id: "garamond",
            name: "Garamond",
            description: "经典的法式衬线字体，优雅且易读"
        )
    }
    
    let availableFonts: [Font] = [
        .avenirNext,
        .didot,
        .baskerville,
        .optima,
        .cochin,
        .garamond
    ]
    
    @Published var currentFont: Font {
        didSet {
            UserDefaults.standard.set(currentFont.id, forKey: "selectedFontId")
        }
    }
    
    private init() {
        let savedFontId = UserDefaults.standard.string(forKey: "selectedFontId") ?? Font.avenirNext.id
        currentFont = availableFonts.first { $0.id == savedFontId } ?? Font.avenirNext
    }
    
    func setFont(_ font: Font) {
        currentFont = font
    }
    
    func font(named name: String) -> Font? {
        availableFonts.first { $0.name == name }
    }
    
    func isAvailable(_ fontName: String) -> Bool {
        NSFontManager.shared.availableFontFamilies.contains(fontName)
    }
} 