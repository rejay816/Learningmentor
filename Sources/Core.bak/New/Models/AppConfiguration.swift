import Foundation

public struct AppConfiguration: Codable {
    public let version: String
    public let environment: Environment
    public let featureFlags: FeatureFlags
    public let analytics: AnalyticsConfiguration
    
    public enum Environment: String, Codable {
        case development
        case staging
        case production
    }
    
    public init(
        version: String,
        environment: Environment,
        featureFlags: FeatureFlags,
        analytics: AnalyticsConfiguration
    ) {
        self.version = version
        self.environment = environment
        self.featureFlags = featureFlags
        self.analytics = analytics
    }
} 