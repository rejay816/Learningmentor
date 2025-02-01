import Foundation

public final class AppConfig {
    public static let shared = AppConfig()
    
    private var configurations: [String: Any] = [:]
    private let logger = Logger.shared
    
    private init() {
        loadDefaultConfigurations()
    }
    
    public func set<T>(_ value: T, for key: ConfigKey) {
        configurations[key.rawValue] = value
    }
    
    public func get<T>(_ key: ConfigKey, defaultValue: T) -> T {
        return configurations[key.rawValue] as? T ?? defaultValue
    }
    
    private func loadDefaultConfigurations() {
        set("LearningMentor", for: .appName)
        set("1.0.0", for: .appVersion)
        set("development", for: .environment)
    }
}

extension AppConfig {
    public enum ConfigKey: String {
        case appName
        case appVersion
        case environment
    }
}
