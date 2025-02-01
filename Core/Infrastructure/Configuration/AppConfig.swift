import Foundation

public final class AppConfig {
    // MARK: - Properties
    
    public static let shared = AppConfig()
    
    private var configurations: [String: Any] = [:]
    private let logger = Logger.shared
    
    // MARK: - Initialization
    
    private init() {
        loadDefaultConfigurations()
    }
    
    // MARK: - Configuration Management
    
    public func set<T>(_ value: T, for key: ConfigKey) {
        configurations[key.rawValue] = value
    }
    
    public func get<T>(_ key: ConfigKey, defaultValue: T) -> T {
        return configurations[key.rawValue] as? T ?? defaultValue
    }
    
    public func getString(_ key: ConfigKey) -> String? {
        return configurations[key.rawValue] as? String
    }
    
    public func getInt(_ key: ConfigKey) -> Int? {
        return configurations[key.rawValue] as? Int
    }
    
    public func getBool(_ key: ConfigKey) -> Bool? {
        return configurations[key.rawValue] as? Bool
    }
    
    // MARK: - Private Methods
    
    private func loadDefaultConfigurations() {
        // App
        set("LearningMentor", for: .appName)
        set("1.0.0", for: .appVersion)
        set("development", for: .environment)
        
        // Features
        set(true, for: .enableLogging)
        set(true, for: .enableCrashReporting)
        
        // Text Analysis
        set(50, for: .shortTextThreshold)
        set(200, for: .longTextThreshold)
        set(2, for: .minimumPatternMatches)
        
        // Language
        set(["en", "zh", "fr"], for: .supportedLanguages)
        
        logger.info("Default configurations loaded", category: .default)
    }
}

// MARK: - Configuration Keys

extension AppConfig {
    public enum ConfigKey: String {
        // App
        case appName
        case appVersion
        case environment
        
        // Features
        case enableLogging
        case enableCrashReporting
        
        // Text Analysis
        case shortTextThreshold
        case longTextThreshold
        case minimumPatternMatches
        
        // Language
        case supportedLanguages
    }
} 