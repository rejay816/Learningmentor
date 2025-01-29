import SwiftUI
import Foundation

// Import Language type from LocalizationManager
typealias Language = LocalizationManager.Language

struct LanguageSettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showingChangeAlert = false
    @State private var selectedLanguage: Language?
    
    var body: some View {
        List {
            ForEach(LocalizationManager.shared.availableLanguages) { language in
                LanguageRow(language: language, 
                           isSelected: language.code == localizationManager.currentLanguage.code)
                    .onTapGesture {
                        if language.code != localizationManager.currentLanguage.code {
                            selectedLanguage = language
                            showingChangeAlert = true
                        }
                    }
            }
        }
        .localizedNavigationTitle("language")
        .alert(isPresented: $showingChangeAlert) {
            Alert(
                title: Text.localized("change_language"),
                message: Text.localizedFormat("change_language_message", selectedLanguage?.name ?? ""),
                primaryButton: .default(Text.localized("ok")) {
                    withAnimation(.easeInOut) {
                        if let language = selectedLanguage {
                            localizationManager.currentLanguage = language
                            NotificationCenter.default.post(
                                name: .languageDidChange,
                                object: nil,
                                userInfo: ["language": language]
                            )
                        }
                    }
                },
                secondaryButton: .cancel(Text.localized("cancel"))
            )
        }
    }
}

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(language.name)
                    .font(.headline)
                Text(language.flag)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .animation(.easeInOut, value: isSelected)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

#Preview {
    NavigationView {
        LanguageSettingsView()
    }
} 