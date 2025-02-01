import Foundation
import NaturalLanguage
import Features

public protocol LanguageService {
    // 基础语言分析
    func detectLanguage(_ text: String) async -> SupportedLanguage
    func tokenize(_ text: String) async -> [Token]
    func analyze(_ text: String) async -> TextAnalysis
    
    // 词性和语法分析
    func tagPartsOfSpeech(_ text: String) async -> [(String, TokenType)]
    func analyzeSentenceStructure(_ text: String) async -> [SentenceStructure]
    
    // 语言学习相关
    func calculateDifficulty(_ text: String) async -> LearningDifficulty
    func extractVocabulary(_ text: String) async -> [VocabularyItem]
    func findPatterns(_ text: String) async -> [LanguagePattern]
}

public struct Token {
    public let text: String
    public let type: TokenType
    public let range: NSRange
    public let metadata: [String: Any]
}

public struct SentenceStructure {
    public let text: String
    public let components: [SentenceComponent]
    public let complexity: ComplexityLevel
    
    public enum ComplexityLevel {
        case simple
        case compound
        case complex
        case compoundComplex
    }
}

public struct SentenceComponent {
    public let text: String
    public let type: ComponentType
    public let tokens: [Token]
    
    public enum ComponentType {
        case subject
        case predicate
        case object
        case complement
        case modifier
    }
}

public struct VocabularyItem {
    public let word: String
    public let type: TokenType
    public let difficulty: LearningDifficulty
    public let frequency: Int
    public let context: String?
}

public struct LanguagePattern {
    public let pattern: String
    public let type: PatternType
    public let frequency: Int
    public let examples: [String]
    
    public enum PatternType {
        case grammar
        case collocation
        case idiom
        case commonPhrase
    }
}

// 默认实现
public class DefaultLanguageService: LanguageService {
    private let analyzer: LanguageAnalyzer
    private let tagger: NLTagger
    private let tokenizer: NLTokenizer
    private let languageRecognizer: NLLanguageRecognizer
    
    public init() {
        self.analyzer = LanguageAnalyzer()
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        self.tokenizer = NLTokenizer(unit: .word)
        self.languageRecognizer = NLLanguageRecognizer()
    }
    
    public func detectLanguage(_ text: String) async -> SupportedLanguage {
        languageRecognizer.processString(text)
        defer { languageRecognizer.reset() }
        
        if let dominantLanguage = languageRecognizer.dominantLanguage {
            switch dominantLanguage {
            case .english:
                return .english
            case .simplifiedChinese, .traditionalChinese:
                return .chinese
            case .french:
                return .french
            default:
                return .english
            }
        }
        return .english
    }
    
    public func tokenize(_ text: String) async -> [Token] {
        return await analyzer.tokenizeText(text)
    }
    
    public func analyze(_ text: String) async -> TextAnalysis {
        // 使用现有的 TextAnalysis 结构
        return TextAnalysis()
    }
    
    public func tagPartsOfSpeech(_ text: String) async -> [(String, TokenType)] {
        let tokens = await analyzer.tokenizeText(text)
        return tokens.map { ($0.text, $0.type) }
    }
    
    public func analyzeSentenceStructure(_ text: String) async -> [SentenceStructure] {
        return await analyzer.analyzeSentenceStructure(text)
    }
    
    public func calculateDifficulty(_ text: String) async -> LearningDifficulty {
        return await analyzer.analyzeDifficulty(text)
    }
    
    public func extractVocabulary(_ text: String) async -> [VocabularyItem] {
        return await analyzer.analyzeVocabulary(text)
    }
    
    public func findPatterns(_ text: String) async -> [LanguagePattern] {
        return (try? await analyzer.analyzePatterns(text)) ?? []
    }
} 