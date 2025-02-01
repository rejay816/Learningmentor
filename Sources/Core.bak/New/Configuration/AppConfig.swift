import Foundation

public struct AppConfig {
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func load() {
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