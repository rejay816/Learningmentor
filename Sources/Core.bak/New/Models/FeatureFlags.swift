import Foundation

public struct FeatureFlags: Codable {
    public enum Feature: String, Codable {
        case textToSpeech
        case translation
        case aiAssistant
        case documentScanning
    }
    
    public var enabledFeatures: Set<Feature>
    
    public init(enabledFeatures: Set<Feature> = []) {
        self.enabledFeatures = enabledFeatures
    }
} 