import Foundation
import NaturalLanguage
import OSLog
import Features

/// Logger for language patterns
private struct Logger {
    static let shared = Logger()
    private let logger = OSLog(subsystem: "com.learningmentor", category: "languagePatterns")
    
    func error(_ message: String, category: Logger.Category) {
        os_log(.error, log: logger, "%{public}@", message)
    }
}

extension Logger {
    struct Category {
        let rawValue: String
        
        init(_ value: String) {
            self.rawValue = value
        }
        
        static let languageProcessing = Category("language_processing")
    }
}

/// Constants used throughout the language patterns system
private enum Constants {
    static let shortTextThreshold = 50
    static let longTextThreshold = 200
    static let minimumPatternMatches = 2
    static let maxLanguageHypotheses = 3
    
    enum Scores {
        static let baseWeight = 1.0
        static let highConfidence = 0.8
        static let mediumConfidence = 0.5
        static let lowConfidence = 0.3
    }
    
    enum Levels {
        static let beginner = "A1"
        static let elementary = "A2"
        static let intermediate = "B1"
        static let upperIntermediate = "B2"
        static let advanced = "C1"
        static let mastery = "C2"
    }
}

/// Represents the type of service for text processing
public enum ServiceType: Sendable {
    case translation
    case analysis
    case synthesis
}

/// Main class for language pattern analysis
@MainActor public final class LanguagePatterns {
    
    // MARK: - Singleton
    
    public static let shared = LanguagePatterns()
    
    // MARK: - Properties
    
    private let tagger: NLTagger
    private let queue = DispatchQueue(label: "com.learningmentor.languagepatterns", attributes: .concurrent)
    
    // MARK: - Initialization
    
    private init() {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma, .language])
    }
    
    // MARK: - Public Methods
    
    /// Analyze text for language features
    /// - Parameter text: The text to analyze
    /// - Returns: Analysis results including language and confidence
    public func analyzeText(_ text: String) async -> TextAnalysis {
        var analysis = TextAnalysis()
        
        // Configure tagger
        tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        // Basic analysis
        if let tag = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lexicalClass).0 {
            analysis.partOfSpeech = tag
        }
        
        // Text structure analysis
        tagger.enumerateTags(in: range, unit: .sentence, scheme: .lexicalClass) { _, tokenRange in
            let nsRange = NSRange(tokenRange, in: text)
            analysis.sentences.append((tagger.tag(at: tokenRange.lowerBound, unit: .sentence, scheme: .lexicalClass).0 ?? .other, nsRange))
            return true
        }
        
        // Pattern analysis
        do {
            // Analyze general patterns
            let patterns = try await analyzePatterns(text)
            if !patterns.isEmpty {
                analysis.isSymbol = patterns.contains("numbers") || patterns.contains("currency")
            }
            
            // Analyze special patterns
            let specialPatterns = try await analyzeSpecialPatterns(text)
            if !specialPatterns.isEmpty {
                analysis.isSymbol = analysis.isSymbol || specialPatterns.contains("urls")
            }
        } catch {
            print("Pattern analysis failed: \(error.localizedDescription)")
        }
        
        return analysis
    }
    
    /// Process text for specific service integration
    /// - Parameters:
    ///   - text: The text to process
    ///   - service: Target service identifier
    /// - Returns: Processed text and metadata
    public func processForService(_ text: String, service: ServiceType) async throws -> ProcessedText {
        return try await withCheckedThrowingContinuation { continuation in
            let localService = service // Capture the value type
            queue.async {
                do {
                    let processor = TextProcessor(text: text, service: localService)
                    let result = try processor.process()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func analyzePatterns(_ text: String) async throws -> [String] {
        var patterns: [String] = []
        
        // Numbers pattern
        if try await threadSafeMatch("\\d+", in: text).count > 0 {
            patterns.append("numbers")
        }
        
        // Currency pattern
        if try await threadSafeMatch("[¥$€£]\\d+(\\.\\d{2})?", in: text).count > 0 {
            patterns.append("currency")
        }
        
        return patterns
    }
    
    private func analyzeSpecialPatterns(_ text: String) async throws -> [String] {
        var patterns: [String] = []
        
        // URL pattern
        if try await threadSafeMatch("https?://[\\w\\d.-]+\\.[\\w]{2,}", in: text).count > 0 {
            patterns.append("urls")
        }
        
        // File path pattern
        if try await threadSafeMatch("/[\\w\\d./]+", in: text).count > 0 {
            patterns.append("paths")
        }
        
        return patterns
    }
}

// MARK: - Supporting Types

/// Represents a component of language analysis
public enum AnalysisComponent {
    case language(SupportedLanguage, confidence: Double)
    case vocabulary(level: String, count: Int)
    case grammar(level: String, structures: [String])
}

/// Represents the result of language analysis
public struct LanguageAnalysisResult {
    public let language: SupportedLanguage?
    public let confidence: Double
    public let vocabularyLevel: String
    public let grammarLevel: String
    
    init(components: [AnalysisComponent]) {
        // Process components to build final result
        var lang: SupportedLanguage?
        var conf = 0.0
        var vocabLevel = ""
        var gramLevel = ""
        
        for component in components {
            switch component {
            case .language(let language, confidence: let confidence):
                lang = language
                conf = confidence
            case .vocabulary(level: let level, count: _):
                vocabLevel = level
            case .grammar(level: let level, structures: _):
                gramLevel = level
            }
        }
        
        self.language = lang
        self.confidence = conf
        self.vocabularyLevel = vocabLevel
        self.grammarLevel = gramLevel
    }
}

/// Represents processed text with metadata
public struct ProcessedText {
    public let text: String
    public let metadata: [String: Any]
    public let confidence: Double
}

// MARK: - Error Handling

public enum LanguagePatternError: LocalizedError {
    case invalidPattern(String)
    case processingFailed(String)
    case unsupportedLanguage(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidPattern(let pattern):
            return "Invalid pattern: \(pattern)"
        case .processingFailed(let reason):
            return "Processing failed: \(reason)"
        case .unsupportedLanguage(let language):
            return "Unsupported language: \(language)"
        }
    }
}

// MARK: - Common Patterns

private enum CommonPatterns: String, CaseIterable {
    case numbers = #"[-+]?\d*\.?\d+([eE][-+]?\d+)?"#
    case email = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
    case url = #"https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)"#
    case dateTime = #"\d{4}[-/年]\d{1,2}[-/月]\d{1,2}日?"#
    case punctuation = #"[!?！？]{2,}"#
    case emoji = #"[\u{1F300}-\u{1F9FF}]"#
}

// MARK: - Text Processor

private final class TextProcessor {
    private let text: String
    private let service: ServiceType
    private let tagger: NLTagger
    
    init(text: String, service: ServiceType) {
        self.text = text
        self.service = service
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        self.tagger.string = text
    }
    
    func process() throws -> ProcessedText {
        var metadata: [String: Any] = [:]
        var processedText = text
        
        // Process based on service type
        switch service {
        case .translation:
            processedText = try processForTranslation()
        case .analysis:
            processedText = try processForAnalysis()
        case .synthesis:
            processedText = try processForSynthesis()
        }
        
        // Add common metadata
        metadata["length"] = processedText.count
        metadata["processed_at"] = Date()
        
        return ProcessedText(
            text: processedText,
            metadata: metadata,
            confidence: calculateConfidence()
        )
    }
    
    private func processForTranslation() throws -> String {
        var processedText = text
        
        // 1. Clean and normalize text
        processedText = normalizeText(processedText)
        
        // 2. Preserve special elements
        let preservedElements = try preserveSpecialElements(in: processedText)
        
        // 3. Apply translation-specific processing
        processedText = try applyTranslationProcessing(processedText)
        
        // 4. Restore preserved elements
        processedText = restorePreservedElements(processedText, elements: preservedElements)
        
        return processedText
    }
    
    private func processForAnalysis() throws -> String {
        var processedText = text
        
        // 1. Remove irrelevant elements
        processedText = removeIrrelevantElements(from: processedText)
        
        // 2. Tokenize and analyze
        let tokens = tokenizeText(processedText)
        
        // 3. Apply analysis-specific processing
        processedText = try applyAnalysisProcessing(processedText, tokens: tokens)
        
        return processedText
    }
    
    private func processForSynthesis() throws -> String {
        var processedText = text
        
        // 1. Clean and normalize
        processedText = normalizeText(processedText)
        
        // 2. Apply synthesis-specific processing
        processedText = try applySynthesisProcessing(processedText)
        
        return processedText
    }
    
    private func calculateConfidence() -> Double {
        // Implementation for confidence calculation
        return Constants.Scores.baseWeight
    }
    
    // MARK: - Helper Methods
    
    private func normalizeText(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
    
    private func preserveSpecialElements(in text: String) throws -> [String: String] {
        var preserved: [String: String] = [:]
        
        // Preserve URLs
        try preservePattern(CommonPatterns.url.rawValue, in: text, preservedDict: &preserved)
        
        // Preserve email addresses
        try preservePattern(CommonPatterns.email.rawValue, in: text, preservedDict: &preserved)
        
        // Preserve dates
        try preservePattern(CommonPatterns.dateTime.rawValue, in: text, preservedDict: &preserved)
        
        return preserved
    }
    
    private func preservePattern(_ pattern: String, in text: String, preservedDict: inout [String: String]) throws {
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                let element = String(text[range])
                let placeholder = "[[PRESERVED_\(preservedDict.count)]]"
                preservedDict[placeholder] = element
            }
        }
    }
    
    private func restorePreservedElements(_ text: String, elements: [String: String]) -> String {
        var result = text
        for (placeholder, element) in elements {
            result = result.replacingOccurrences(of: placeholder, with: element)
        }
        return result
    }
    
    private func removeIrrelevantElements(from text: String) -> String {
        return text
            .replacingOccurrences(of: #"[\u{1F300}-\u{1F9FF}]"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^\p{L}\p{N}\p{P}\s]"#, with: "", options: .regularExpression)
    }
    
    private func tokenizeText(_ text: String) -> [(String, String)] {
        var tokens: [(String, String)] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            if tag != nil {
                let token = String(text[range])
                tokens.append((token, tag?.rawValue ?? "unknown"))
            }
            return true
        }
        
        return tokens
    }
    
    private func applyTranslationProcessing(_ text: String) throws -> String {
        // Implementation for translation-specific processing
        return text
    }
    
    private func applyAnalysisProcessing(_ text: String, tokens: [(String, String)]) throws -> String {
        // Implementation for analysis-specific processing
        return text
    }
    
    private func applySynthesisProcessing(_ text: String) throws -> String {
        // Implementation for synthesis-specific processing
        return text
    }
}

// MARK: - Analysis Support Types

/// Represents text analysis metrics
public struct TextAnalysisMetrics {
    public let wordCount: Int
    public let sentenceCount: Int
    public let averageWordLength: Double
    public let averageSentenceLength: Double
    public let uniqueWordCount: Int
    public let lexicalDensity: Double
    
    init(text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let sentences = text.components(separatedBy: [".","!","?"])
            .filter { !$0.isEmpty }
        
        let uniqueWords = Set(words.map { $0.lowercased() })
        
        self.wordCount = words.count
        self.sentenceCount = sentences.count
        self.averageWordLength = Double(words.joined().count) / Double(words.count)
        self.averageSentenceLength = Double(wordCount) / Double(sentenceCount)
        self.uniqueWordCount = uniqueWords.count
        self.lexicalDensity = Double(uniqueWordCount) / Double(wordCount)
    }
}

/// Represents language detection confidence
public struct LanguageConfidence {
    public let language: SupportedLanguage
    public let confidence: Double
    public let alternativeLanguages: [(language: SupportedLanguage, confidence: Double)]
    
    init(tagger: NLTagger) {
        let dominantLanguage = tagger.dominantLanguage
        let range = tagger.string!.startIndex..<tagger.string!.endIndex
        let hypotheses = tagger.tagHypotheses(
            at: range.lowerBound,
            unit: .paragraph,
            scheme: .language,
            maximumCount: Constants.maxLanguageHypotheses
        )
        
        self.language = SupportedLanguage(from: dominantLanguage) ?? .english
        self.confidence = hypotheses.0[dominantLanguage?.rawValue ?? "und"] ?? Constants.Scores.lowConfidence
        
        self.alternativeLanguages = hypotheses.0
            .filter { $0.key != dominantLanguage?.rawValue }
            .compactMap { key, conf in
                if let supported = SupportedLanguage(from: NLLanguage(rawValue: key)) {
                    return (supported, conf)
                }
                return nil
            }
    }
}

// MARK: - Language Analysis Extensions

extension LanguagePatterns {
    /// Detect language of the given text
    /// - Parameter text: Text to analyze
    /// - Returns: Language analysis component
    private func detectLanguage(_ text: String) async -> AnalysisComponent {
        let tagger = NLTagger(tagSchemes: [.language])
            tagger.string = text
            
        let range = text.startIndex..<text.endIndex
        let dominantLanguage = tagger.dominantLanguage
        let hypotheses = tagger.tagHypotheses(
            at: range.lowerBound,
            unit: .paragraph,
            scheme: .language,
            maximumCount: Constants.maxLanguageHypotheses
        )
        
        let confidence = hypotheses.0[dominantLanguage?.rawValue ?? "und"] ?? Constants.Scores.lowConfidence
        if let lang = dominantLanguage {
            return .language(SupportedLanguage(from: lang) ?? .english, confidence: confidence)
        }
        return .language(.english, confidence: Constants.Scores.lowConfidence)
    }
    
    /// Analyze vocabulary in the text
    /// - Parameter text: Text to analyze
    /// - Returns: Vocabulary analysis component
    private func analyzeVocabulary(_ text: String) async -> AnalysisComponent {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            
        var wordCount = 0
        var uniqueWords = Set<String>()
        
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
                if let tag = tag {
                let word = String(text[range]).lowercased()
                uniqueWords.insert(word)
                wordCount += 1
                }
                return true
            }
            
        let level = determineVocabularyLevel(
            uniqueWords: uniqueWords.count,
            totalWords: wordCount
        )
        
        return .vocabulary(level: level, count: uniqueWords.count)
    }
    
    /// Analyze grammar in the text
    /// - Parameter text: Text to analyze
    /// - Returns: Grammar analysis component
    private func analyzeGrammar(_ text: String) async -> AnalysisComponent {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            
        var structures = Set<String>()
        var currentStructure = [String]()
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
                if let tag = tag {
                currentStructure.append(tag.rawValue)
                if currentStructure.count >= 3 {
                    structures.insert(currentStructure.joined(separator: "-"))
                    currentStructure.removeFirst()
                }
            }
                return true
            }
            
        let level = determineGrammarLevel(structures: structures)
        return .grammar(level: level, structures: Array(structures))
    }
    
    /// Determine vocabulary level based on word counts
    private func determineVocabularyLevel(uniqueWords: Int, totalWords: Int) -> String {
        let diversity = Double(uniqueWords) / Double(totalWords)
        
        switch diversity {
        case 0..<Constants.Scores.lowConfidence:
            return Constants.Levels.beginner
        case Constants.Scores.lowConfidence..<Constants.Scores.mediumConfidence:
            return Constants.Levels.elementary
        case Constants.Scores.mediumConfidence..<Constants.Scores.highConfidence:
            return Constants.Levels.intermediate
        default:
            return Constants.Levels.advanced
        }
    }
    
    /// Determine grammar level based on structures
    private func determineGrammarLevel(structures: Set<String>) -> String {
        let complexity = Double(structures.count) / 10.0 // Normalize to 0-1 scale
        
        switch complexity {
        case 0..<Constants.Scores.lowConfidence:
            return Constants.Levels.beginner
        case Constants.Scores.lowConfidence..<Constants.Scores.mediumConfidence:
            return Constants.Levels.elementary
        case Constants.Scores.mediumConfidence..<Constants.Scores.highConfidence:
            return Constants.Levels.intermediate
        default:
            return Constants.Levels.advanced
        }
    }
}

// MARK: - Pattern Matching Extensions

extension LanguagePatterns {
    /// Find matches for a pattern in text
    /// - Parameters:
    ///   - pattern: Regular expression pattern
    ///   - text: Text to search in
    /// - Returns: Array of matched strings
    @MainActor
    public func findMatches(for pattern: String, in text: String) async throws -> [String] {
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            return String(text[range])
        }
    }
    
    /// Check if text contains a pattern
    /// - Parameters:
    ///   - pattern: Regular expression pattern
    ///   - text: Text to check
    /// - Returns: True if pattern is found
    @MainActor
    public func containsPattern(_ pattern: String, in text: String) async throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range) != nil
    }
}

// MARK: - Thread Safety Extensions

extension LanguagePatterns {
    /// Thread-safe pattern matching
    /// - Parameters:
    ///   - pattern: Pattern to match
    ///   - text: Text to search in
    /// - Returns: Match results
    public func threadSafeMatch(_ pattern: String, in text: String) async throws -> [NSTextCheckingResult] {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let regex = try NSRegularExpression(pattern: pattern)
                    let range = NSRange(text.startIndex..., in: text)
                    let matches = regex.matches(in: text, range: range)
                    continuation.resume(returning: matches)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Thread-safe pattern checking
    /// - Parameters:
    ///   - pattern: Pattern to check
    ///   - text: Text to search in
    /// - Returns: True if pattern is found
    public func threadSafeContains(_ pattern: String, in text: String) async throws -> Bool {
        return try await containsPattern(pattern, in: text)
    }
} 