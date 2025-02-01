import Foundation
import NaturalLanguage

public protocol LanguageService {
    func detectLanguage(in text: String) async throws -> LanguageAnalysis
    func analyzeText(_ text: String, language: SupportedLanguage) async throws -> [LanguageFeature]
    func translateText(_ text: String, from: SupportedLanguage, to: SupportedLanguage) async throws -> String
    func assessLanguageLevel(for user: User, in language: SupportedLanguage) async throws -> LanguageLevel
}

public protocol TextProcessingService {
    func tokenize(_ text: String, language: SupportedLanguage) async throws -> [String]
    func extractKeywords(from text: String, language: SupportedLanguage) async throws -> [String]
    func findPatterns(in text: String, language: SupportedLanguage) async throws -> [String]
    func calculateReadability(of text: String, language: SupportedLanguage) async throws -> Double
}

// MARK: - Supporting Types

public struct ProcessedText {
    public let text: String
    public let metadata: [String: Any]
    public let confidence: Double
    
    public init(text: String, metadata: [String: Any], confidence: Double) {
        self.text = text
        self.metadata = metadata
        self.confidence = confidence
    }
} 