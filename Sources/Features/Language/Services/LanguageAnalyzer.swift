import Foundation
import NaturalLanguage
import Features

@MainActor
public class LanguageAnalyzer {
    private let patterns: LanguagePatterns
    private let tagger: NLTagger
    private let tokenizer: NLTokenizer
    
    public init() {
        self.patterns = LanguagePatterns.shared
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        self.tokenizer = NLTokenizer(unit: .word)
    }
    
    // MARK: - Pattern Analysis
    
    public func analyzePatterns(_ text: String) async throws -> [LanguagePattern] {
        var patterns: [LanguagePattern] = []
        
        // 分析语法模式
        if let grammarPatterns = try? await analyzeGrammarPatterns(text) {
            patterns.append(contentsOf: grammarPatterns)
        }
        
        // 分析词语搭配
        if let collocations = try? await analyzeCollocations(text) {
            patterns.append(contentsOf: collocations)
        }
        
        // 分析习语和常用短语
        if let idioms = try? await analyzeIdioms(text) {
            patterns.append(contentsOf: idioms)
        }
        
        return patterns
    }
    
    // MARK: - Sentence Analysis
    
    public func analyzeSentenceStructure(_ text: String) async -> [SentenceStructure] {
        var structures: [SentenceStructure] = []
        
        // 分句
        let sentences = text.components(separatedBy: .init(charactersIn: ".!?。！？"))
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        for sentence in sentences {
            if let structure = try? await analyzeSingleSentence(sentence) {
                structures.append(structure)
            }
        }
        
        return structures
    }
    
    // MARK: - Vocabulary Analysis
    
    public func analyzeVocabulary(_ text: String) async -> [VocabularyItem] {
        var items: [VocabularyItem] = []
        let tokens = await tokenizeText(text)
        
        for token in tokens {
            if let item = try? await analyzeVocabularyItem(token) {
                items.append(item)
            }
        }
        
        return items
    }
    
    // MARK: - Difficulty Analysis
    
    public func analyzeDifficulty(_ text: String) async -> LearningDifficulty {
        let vocabularyFactor = await analyzeVocabularyDifficulty(text)
        let grammarFactor = await analyzeGrammarDifficulty(text)
        let structureFactor = await analyzeStructureDifficulty(text)
        let contextFactor = await analyzeContextDifficulty(text)
        
        let factors = [vocabularyFactor, grammarFactor, structureFactor, contextFactor]
        let level = calculateOverallLevel(factors)
        
        return LearningDifficulty(level: level, factors: factors)
    }
    
    // MARK: - Private Helpers
    
    private func analyzeGrammarPatterns(_ text: String) async throws -> [LanguagePattern] {
        var patterns: [LanguagePattern] = []
        
        // 分析句型模式
        let sentencePatterns: [NSTextCheckingResult] = []
        
        if !sentencePatterns.isEmpty {
            patterns.append(LanguagePattern(
                pattern: "基本句型",
                type: .grammar,
                frequency: sentencePatterns.count,
                examples: sentencePatterns.prefix(3).map { String(text[Range($0.range, in: text)!]) }
            ))
        }
        
        return patterns
    }
    
    private func analyzeCollocations(_ text: String) async throws -> [LanguagePattern] {
        var patterns: [LanguagePattern] = []
        
        // 分析动宾搭配
        let verbObjectPatterns: [NSTextCheckingResult] = []
        
        if !verbObjectPatterns.isEmpty {
            patterns.append(LanguagePattern(
                pattern: "动宾搭配",
                type: .collocation,
                frequency: verbObjectPatterns.count,
                examples: verbObjectPatterns.prefix(3).map { String(text[Range($0.range, in: text)!]) }
            ))
        }
        
        return patterns
    }
    
    private func analyzeIdioms(_ text: String) async throws -> [LanguagePattern] {
        var patterns: [LanguagePattern] = []
        
        // 分析成语
        let idiomPatterns: [NSTextCheckingResult] = []
        
        if !idiomPatterns.isEmpty {
            patterns.append(LanguagePattern(
                pattern: "成语",
                type: .idiom,
                frequency: idiomPatterns.count,
                examples: idiomPatterns.prefix(3).map { String(text[Range($0.range, in: text)!]) }
            ))
        }
        
        return patterns
    }
    
    private func analyzeSingleSentence(_ sentence: String) async throws -> SentenceStructure {
        var components: [SentenceComponent] = []
        let tokens = await tokenizeText(sentence)
        
        // 简单的主谓宾分析
        var currentComponent: [Token] = []
        var currentType: SentenceComponent.ComponentType = .subject
        
        for token in tokens {
            if case .verb = token.type, currentType == .subject {
                // 完成主语
                components.append(SentenceComponent(
                    text: currentComponent.map { $0.text }.joined(),
                    type: .subject,
                    tokens: currentComponent
                ))
                currentComponent = []
                currentType = .predicate
            }
            
            currentComponent.append(token)
        }
        
        // 添加最后一个组件
        if !currentComponent.isEmpty {
            components.append(SentenceComponent(
                text: currentComponent.map { $0.text }.joined(),
                type: currentType,
                tokens: currentComponent
            ))
        }
        
        // 确定句子复杂度
        let complexity: SentenceStructure.ComplexityLevel
        if components.count <= 2 {
            complexity = .simple
        } else if components.count <= 4 {
            complexity = .compound
        } else {
            complexity = .complex
        }
        
        return SentenceStructure(
            text: sentence,
            components: components,
            complexity: complexity
        )
    }
    
    public func tokenizeText(_ text: String) async -> [Token] {
        tokenizer.string = text
        var tokens: [Token] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { (range, _) -> Bool in
            let tokenText = String(text[range])
            let nsRange = NSRange(range, in: text)
            
            tagger.string = tokenText
            let tag = tagger.tag(at: tokenText.startIndex, unit: .word, scheme: .lexicalClass).0
            
            let type: TokenType = tag.map { nlTag in
                switch nlTag {
                case .noun: return .noun
                case .verb: return .verb
                case .adjective: return .adjective
                case .adverb: return .adverb
                case .pronoun: return .pronoun
                case .determiner: return .determiner
                case .preposition: return .preposition
                case .number: return .number
                case .conjunction: return .conjunction
                case .interjection: return .interjection
                default: return .word
                }
            } ?? .unknown
            
            let token = Token(
                text: tokenText,
                type: type,
                range: nsRange,
                metadata: [:]
            )
            tokens.append(token)
            return true
        }
        
        return tokens
    }
    
    private func analyzeVocabularyItem(_ token: Token) async throws -> VocabularyItem {
        return VocabularyItem(
            word: token.text,
            type: token.type,
            difficulty: LearningDifficulty(level: .intermediate, factors: []),
            frequency: 1,
            context: nil as String?
        )
    }
    
    private func analyzeVocabularyDifficulty(_ text: String) async -> LearningDifficulty.DifficultyFactor {
        return LearningDifficulty.DifficultyFactor(
            type: .vocabulary,
            score: 0.5,
            description: "中等词汇难度"
        )
    }
    
    private func analyzeGrammarDifficulty(_ text: String) async -> LearningDifficulty.DifficultyFactor {
        return LearningDifficulty.DifficultyFactor(
            type: .grammar,
            score: 0.5,
            description: "中等语法难度"
        )
    }
    
    private func analyzeStructureDifficulty(_ text: String) async -> LearningDifficulty.DifficultyFactor {
        return LearningDifficulty.DifficultyFactor(
            type: .sentenceStructure,
            score: 0.5,
            description: "中等句式难度"
        )
    }
    
    private func analyzeContextDifficulty(_ text: String) async -> LearningDifficulty.DifficultyFactor {
        return LearningDifficulty.DifficultyFactor(
            type: .contextualComplexity,
            score: 0.5,
            description: "中等上下文复杂度"
        )
    }
    
    private func calculateOverallLevel(_ factors: [LearningDifficulty.DifficultyFactor]) -> LearningDifficulty.Level {
        let averageScore = factors.reduce(0.0) { $0 + $1.score } / Double(factors.count)
        
        switch averageScore {
        case 0.0...0.2:
            return .beginner
        case 0.2...0.4:
            return .elementary
        case 0.4...0.6:
            return .intermediate
        case 0.6...0.8:
            return .upperIntermediate
        case 0.8...0.9:
            return .advanced
        default:
            return .mastery
        }
    }
} 