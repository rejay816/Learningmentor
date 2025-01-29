import SwiftUI
import AppKit

@MainActor
extension Image {
    static func localizedImage(_ name: String) -> Image {
        let language = LocalizationManager.shared.currentLanguage.code
        // 尝试加载特定语言的图片
        if let _ = NSImage(named: "\(name)_\(language)") {
            return Image("\(name)_\(language)", bundle: .main)
        }
        // 如果找不到特定语言的图片,返回默认图片
        return Image(name, bundle: .main)
    }
}

@MainActor
extension View {
    func localizedBackground(_ name: String) -> some View {
        let language = LocalizationManager.shared.currentLanguage.code
        // 尝试加载特定语言的背景图片
        if let _ = NSImage(named: "\(name)_\(language)") {
            return AnyView(background(Image("\(name)_\(language)")))
        }
        // 如果找不到特定语言的图片,返回默认背景
        return AnyView(background(Image(name)))
    }
} 