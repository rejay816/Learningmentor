import SwiftUI

@MainActor
extension Text {
    static func localized(_ key: String) -> Text {
        Text(LocalizationManager.shared.localizedString(key))
    }
    
    static func localizedFormat(_ key: String, _ args: CVarArg...) -> Text {
        let format = LocalizationManager.shared.localizedString(key)
        return Text(String(format: format, arguments: args))
    }
}

@MainActor
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
    
    func localizedFormat(_ args: CVarArg...) -> String {
        let format = LocalizationManager.shared.localizedString(self)
        return String(format: format, arguments: args)
    }
}

extension View {
    func localizedNavigationTitle(_ key: String) -> some View {
        navigationTitle(LocalizationManager.shared.localizedString(key))
    }
    
    func localizedToolbarTitle(_ key: String) -> some View {
        toolbar {
            ToolbarItem(placement: .principal) {
                Text.localized(key)
            }
        }
    }
} 