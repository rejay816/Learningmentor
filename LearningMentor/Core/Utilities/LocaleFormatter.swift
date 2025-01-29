import Foundation

@MainActor
class LocaleFormatter {
    static let shared = LocaleFormatter()
    private init() {
        updateLocale()
    }
    
    // 获取当前语言对应的 Locale
    private var currentLocale: Locale {
        Locale(identifier: LocalizationManager.shared.currentLanguage.code)
    }
    
    // MARK: - Formatters
    
    // 日期格式化
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        return formatter
    }()
    
    // 数字格式化
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // 货币格式化
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // 百分比格式化
    private lazy var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = .percent
        return formatter
    }()
    
    // 相对日期格式化
    private lazy var relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = currentLocale
        return formatter
    }()
    
    // MARK: - Date Formatting
    
    // 格式化日期为短格式 (例如: 2024/3/14)
    func formatShortDate(_ date: Date) -> String {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    // 格式化日期为长格式 (例如: 2024年3月14日 星期四)
    func formatLongDate(_ date: Date) -> String {
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    // 格式化日期和时间 (例如: 2024/3/14 15:30)
    func formatDateTime(_ date: Date) -> String {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func formatRelativeDate(_ date: Date) -> String {
        relativeDateFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    func formatCustomDate(_ date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Number Formatting
    
    // 格式化数字 (例如: 1,234.56)
    func formatNumber(_ number: Double) -> String {
        numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    func formatCurrency(_ amount: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    func formatPercent(_ value: Double) -> String {
        percentFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    // 格式化文件大小
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useAll]
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Text Formatting
    
    func formatName(_ firstName: String, _ lastName: String) -> String {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.locale = currentLocale
        
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName
        
        return nameFormatter.string(from: components)
    }
    
    // MARK: - List Formatting
    
    func formatList(_ items: [String]) -> String {
        let formatter = ListFormatter()
        formatter.locale = currentLocale
        return formatter.string(from: items) ?? ""
    }
    
    // MARK: - Update Locale
    
    // 更新 Locale
    @MainActor
    private func updateLocale() {
        let newLocale = Locale(identifier: LocalizationManager.shared.currentLanguage.code)
        dateFormatter.locale = newLocale
        numberFormatter.locale = newLocale
        currencyFormatter.locale = newLocale
        percentFormatter.locale = newLocale
        relativeDateFormatter.locale = newLocale
    }
}

// MARK: - Notification Extension
extension LocaleFormatter {
    @MainActor
    func setupLocaleChangeObserver() {
        NotificationCenter.default.addObserver(
            forName: .languageDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateLocale()
            }
        }
    }
} 