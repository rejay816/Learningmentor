import SwiftUI

struct TextSettings: Codable {
    var fontSize: CGFloat
    var lineSpacing: CGFloat
    var paragraphSpacing: CGFloat
    var selectedFont: String
    var selectedTheme: String
    
    init(fontSize: CGFloat, lineSpacing: CGFloat, paragraphSpacing: CGFloat, selectedFont: String, selectedTheme: String) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.selectedFont = selectedFont
        self.selectedTheme = selectedTheme
    }
    
    static let `default` = TextSettings(
        fontSize: 16,
        lineSpacing: 8,
        paragraphSpacing: 12,
        selectedFont: "Avenir Next",
        selectedTheme: "经典纸张"
    )
    
    // 值范围验证
    mutating func validateAndUpdate() {
        fontSize = fontSize.clamped(min: 12, max: 32)
        lineSpacing = lineSpacing.clamped(min: 4, max: 20)
        paragraphSpacing = paragraphSpacing.clamped(min: 8, max: 24)
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case fontSize, lineSpacing, paragraphSpacing, selectedFont, selectedTheme
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontSize = try container.decode(Double.self, forKey: .fontSize)
        lineSpacing = try container.decode(Double.self, forKey: .lineSpacing)
        paragraphSpacing = try container.decode(Double.self, forKey: .paragraphSpacing)
        selectedFont = try container.decode(String.self, forKey: .selectedFont)
        selectedTheme = try container.decode(String.self, forKey: .selectedTheme)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Double(fontSize), forKey: .fontSize)
        try container.encode(Double(lineSpacing), forKey: .lineSpacing)
        try container.encode(Double(paragraphSpacing), forKey: .paragraphSpacing)
        try container.encode(selectedFont, forKey: .selectedFont)
        try container.encode(selectedTheme, forKey: .selectedTheme)
    }
}

// 扩展 CGFloat 添加范围限制方法
extension CGFloat {
    func clamped(min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.max(Swift.min(self, upper), lower)
    }
} 