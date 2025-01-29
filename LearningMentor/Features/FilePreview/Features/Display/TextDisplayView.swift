import SwiftUI

struct TextDisplayView: View {
    let text: String
    @ObservedObject var viewModel: FilePreviewViewModel
    
    var body: some View {
        ScrollView {
            Text(text)
                .font(.custom(viewModel.currentFont.name, size: viewModel.settings.fontSize))
                .lineSpacing(viewModel.settings.lineSpacing)
                .tracking(0.3) // 优化法语字母间距
                .textCase(nil) // 保持原始大小写
                .allowsTightening(false) // 防止字符挤压
                .modifier(FrenchTextModifier()) // 自定义修饰符处理法语特殊情况
                .padding(.vertical, viewModel.settings.paragraphSpacing)
                .padding(.horizontal)
                .foregroundColor(viewModel.currentTheme.textColor)
                .background(viewModel.currentTheme.backgroundColor)
                .textSelection(.enabled)
        }
        .background(viewModel.currentTheme.backgroundColor)
    }
}

// 法语文本修饰符
struct FrenchTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, .leftToRight)
            .environment(\.locale, Locale(identifier: "fr_FR"))
    }
}

#Preview {
    TextDisplayView(
        text: """
        Exemple de texte en français.
        Deuxième ligne de texte.
        
        Un nouveau paragraphe pour tester l'espacement.
        Plus de texte pour tester la lecture.
        """,
        viewModel: FilePreviewViewModel()
    )
} 