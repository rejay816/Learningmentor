import Foundation

public struct TextAnalysis: Codable {
    public let language: SupportedLanguage
    public let complexity: Double
    public let sentiment: Double
    public let keywords: [String]
    public let readingTime: TimeInterval
} 