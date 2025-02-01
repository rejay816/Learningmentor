import Foundation
import NaturalLanguage
import OSLog

/// Logger for text interaction
private struct Logger {
    static let shared = Logger()
    private let logger = OSLog(subsystem: "com.learningmentor", category: "textInteraction")
    
    func error(_ message: String) {
        os_log(.error, log: logger, "%{public}@", message)
    }
}

extension Logger {
    enum Category {
        case languageProcessing
        
        var description: String {
            switch self {
            case .languageProcessing:
                return "Language Processing"
            }
        }
    }
}

public class TextInteractionHandler {
    // MARK: - Properties
    
    private let languageRecognizer = NLLanguageRecognizer()
    private var tokenizer: NLTokenizer
    private var tagger: NLTagger
    
    private(set) var currentLanguage: NLLanguage?
    private(set) var currentText: String?
    
    private var currentSupportedLanguage: SupportedLanguage?
    
    // 语言变化回调
    public var onLanguageChanged: ((NLLanguage) -> Void)?
    
    // MARK: - Initialization
    
    public init() {
        self.tokenizer = NLTokenizer(unit: .word)
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma, .language])
    }
    
    // MARK: - Text Processing
    
    public func processText(_ text: String) {
        currentText = text
        
        // 语言识别
        detectLanguage(text)
        
        // 配置分词器和标注器
        configureProcessors(for: text)
        
        // 预处理文本结构
        analyzeTextStructure(text)
    }
    
    // MARK: - Language Detection
    
    private func detectLanguage(_ text: String) {
        // 使用 NLLanguageRecognizer
        languageRecognizer.processString(text)
        let newLanguage = languageRecognizer.dominantLanguage
        languageRecognizer.reset()
        
        // 使用特征模式增强检测
        Task {
            do {
                let analysis = await LanguagePatterns.shared.analyzeText(text)
        
        // 更新当前语言
                if let detectedLanguage = analysis.language {
                    if detectedLanguage != currentSupportedLanguage {
                        currentSupportedLanguage = detectedLanguage
                        if let nlLanguage = newLanguage {
                            currentLanguage = nlLanguage
                            onLanguageChanged?(nlLanguage)
                        }
                    }
                }
                
                // 分析文本模式
                _ = try await analyzePatterns(text)
                _ = try await analyzeSpecialPatterns(text)
            } catch {
                Logger.shared.error("Language detection failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Text Analysis
    
    private func configureProcessors(for text: String) {
        // 配置分词器
        tokenizer.string = text
        if let language = currentLanguage {
            tokenizer.setLanguage(language)
        }
        
        // 配置标注器
        tagger.string = text
        if let language = currentLanguage {
            tagger.setLanguage(language, range: text.startIndex..<text.endIndex)
        }
    }
    
    private func analyzeTextStructure(_ text: String) {
        // 分析段落结构
        _ = text.components(separatedBy: .newlines)
        // TODO: 处理段落结构
    }
    
    // MARK: - Word Selection
    
    public func handleTap(at location: CGPoint, in bounds: CGRect) async throws -> TextSelection? {
        guard let text = currentText else { return nil }
        if let (word, range) = wordAt(location: location, in: text, bounds: bounds) {
            let nsRange = NSRange(range, in: text)
            return TextSelection(
                text: word,
                range: nsRange,
                type: .word,
                details: try await analyzeWord(word, at: range)
            )
        }
        return nil
    }
    
    public func handleDoubleTap(at location: CGPoint, in bounds: CGRect) async throws -> TextSelection? {
        guard let text = currentText else { return nil }
        if let (_, range) = wordAt(location: location, in: text, bounds: bounds) {
            // 扩展选择到整个词组或短语
            let nsRange = NSRange(range, in: text)
            return expandToPhrase(from: nsRange, in: text)
        }
        return nil
    }
    
    public func handleLongPress(at location: CGPoint, in bounds: CGRect) async throws -> TextSelection? {
        guard let text = currentText else { return nil }
        if let (_, range) = wordAt(location: location, in: text, bounds: bounds) {
            // 扩展选择到整个句子
            let nsRange = NSRange(range, in: text)
            return expandToSentence(from: nsRange, in: text)
        }
        return nil
    }
    
    // MARK: - Range Selection
    
    public func handleRangeSelection(_ range: NSRange) async throws -> TextSelection? {
        guard let text = currentText else { return nil }
        let words = getSelectedRange(range, in: text)
        
        // 分析选中文本
        let selectedText = words.map { $0.0 }.joined(separator: " ")
        if let textRange = Range(range, in: text) {
            return TextSelection(
                text: selectedText,
                range: range,
                type: .range,
                details: analyzeText(selectedText, range: textRange)
            )
        }
        return nil
    }
    
    // MARK: - Text Analysis
    
    private func analyzeWord(_ word: String, at range: Range<String.Index>) async throws -> TextAnalysis {
        var analysis = TextAnalysis()
        
        // 基础分析
        _ = NSRange(range, in: word)
        if let tag = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lexicalClass).0 {
            analysis.partOfSpeech = tag
        }
        
        // 根据语言进行特定分析
        if let language = currentSupportedLanguage {
            switch language {
            case .chinese:
                try await analyzeChinese(word, &analysis)
            case .english:
                try await analyzeEnglish(word, &analysis)
            case .french:
                try await analyzeFrench(word, &analysis)
            }
        }
        
        return analysis
    }
    
    private func analyzeText(_ text: String, range: Range<String.Index>) -> TextAnalysis {
        var analysis = TextAnalysis()
        
        // 基础分析
        if let tag = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lexicalClass).0 {
            analysis.partOfSpeech = tag
        }
        
        // 分析文本结构
        tagger.enumerateTags(in: range, unit: .sentence, scheme: .lexicalClass) { _, tokenRange in
                // 收集句子级别的分析信息
                let nsRange = NSRange(tokenRange, in: text)
            analysis.sentences.append((tagger.tag(at: tokenRange.lowerBound, unit: .sentence, scheme: .lexicalClass).0 ?? .other, nsRange))
            return true
        }
        
        // 异步分析模式
        Task {
            do {
                // 分析通用模式
                let patterns = try await analyzePatterns(text)
                if !patterns.isEmpty {
                    analysis.isSymbol = patterns.contains("numbers") || patterns.contains("currency")
                }
                
                // 分析特殊模式
                let specialPatterns = try await analyzeSpecialPatterns(text)
                if !specialPatterns.isEmpty {
                    analysis.isSymbol = analysis.isSymbol || specialPatterns.contains("urls")
                }
            } catch {
                Logger.shared.error("Pattern analysis failed: \(error.localizedDescription)")
            }
        }
        
        return analysis
    }
    
    // MARK: - Helper Methods
    
    private func expandToPhrase(from range: NSRange, in text: String) -> TextSelection? {
        // TODO: 实现短语扩展逻辑
        return nil
    }
    
    private func expandToSentence(from range: NSRange, in text: String) -> TextSelection? {
        // TODO: 实现句子扩展逻辑
        return nil
    }
    
    // MARK: - 点击处理
    
    public func wordAt(location: CGPoint, in text: String, bounds: CGRect) -> (String, Range<String.Index>)? {
        // 将点击位置转换为文本索引
        let index = text.startIndex // TODO: 实现点击位置到文本索引的转换
        
        var wordRange: Range<String.Index>?
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            if range.contains(index) {
                wordRange = range
                return false
            }
            return true
        }
        
        if let range = wordRange {
            return (String(text[range]), range)
        }
        
        return nil
    }
    
    // MARK: - 选择处理
    
    public func getSelectedRange(_ range: NSRange, in text: String) -> [(String, NSRange)] {
        var words: [(String, NSRange)] = []
        
        if let textRange = Range(range, in: text) {
            tokenizer.enumerateTokens(in: textRange) { tokenRange, _ in
                let word = String(text[tokenRange])
                let nsRange = NSRange(tokenRange, in: text)
                words.append((word, nsRange))
                return true
            }
        }
        
        return words
    }
    
    // MARK: - 辅助方法
    
    private func getWords(in text: String, range: Range<String.Index>) -> [(String, Range<String.Index>)] {
        var words: [(String, Range<String.Index>)] = []
        
        tokenizer.enumerateTokens(in: range) { tokenRange, _ in
            let word = String(text[tokenRange])
            words.append((word, tokenRange))
            return true
        }
        
        return words
    }
    
    // MARK: - Language-Specific Analysis
    
    private func analyzeChinese(_ word: String, _ analysis: inout TextAnalysis) async throws {
        // Convert pattern matching results to counts
        let numberCount = try await LanguagePatterns.shared.threadSafeMatch("^[一二三四五六七八九十百千万亿]+$", in: word).count
        if numberCount > 0 {
            analysis.type = .number
        }
        
        let measureCount = try await LanguagePatterns.shared.threadSafeMatch("^[个只张本条件台份双对]$", in: word).count
        if measureCount > 0 {
            analysis.type = .measure
        }
        
        let timeCount = try await LanguagePatterns.shared.threadSafeMatch("^[年月日时分秒]$", in: word).count
        if timeCount > 0 {
            analysis.type = .time
        }
    }
    
    private func analyzeEnglish(_ word: String, _ analysis: inout TextAnalysis) async throws {
        let numberCount = try await LanguagePatterns.shared.threadSafeMatch("^\\d+$", in: word).count
        if numberCount > 0 {
            analysis.type = .number
        }
        
        let timeCount = try await LanguagePatterns.shared.threadSafeMatch("^(year|month|day|hour|minute|second)s?$", in: word).count
        if timeCount > 0 {
            analysis.type = .time
        }
        
        let measureCount = try await LanguagePatterns.shared.threadSafeMatch("^(piece|unit|pair|dozen)s?$", in: word).count
        if measureCount > 0 {
            analysis.type = .measure
        }
    }
    
    private func analyzeFrench(_ word: String, _ analysis: inout TextAnalysis) async throws {
        let numberCount = try await LanguagePatterns.shared.threadSafeMatch("^\\d+$", in: word).count
        if numberCount > 0 {
            analysis.type = .number
        }
        
        let timeCount = try await LanguagePatterns.shared.threadSafeMatch("^(année|mois|jour|heure|minute|seconde)s?$", in: word).count
        if timeCount > 0 {
            analysis.type = .time
        }
        
        let measureCount = try await LanguagePatterns.shared.threadSafeMatch("^(pièce|unité|paire|douzaine)s?$", in: word).count
        if measureCount > 0 {
            analysis.type = .measure
        }
        
        let articleCount = try await LanguagePatterns.shared.threadSafeMatch("^(le|la|les|un|une|des)$", in: word).count
        if articleCount > 0 {
            analysis.type = .article
        }
        
        let pronounCount = try await LanguagePatterns.shared.threadSafeMatch("^(je|tu|il|elle|nous|vous|ils|elles)$", in: word).count
        if pronounCount > 0 {
            analysis.type = .pronoun
        }
    }
    
    // MARK: - Pattern Analysis
    
    private func analyzePatterns(_ text: String) async throws -> [String] {
        var patterns: [String] = []
        
        // Numbers pattern
        let numberCount = try await LanguagePatterns.shared.threadSafeMatch("\\d+", in: text).count
        if numberCount > 0 {
            patterns.append("numbers")
        }
        
        // Date pattern
        let dateCount = try await LanguagePatterns.shared.threadSafeMatch("\\d{4}[-/年]\\d{1,2}[-/月]\\d{1,2}日?", in: text).count
        if dateCount > 0 {
            patterns.append("dates")
        }
        
        // Time pattern
        let timeCount = try await LanguagePatterns.shared.threadSafeMatch("\\d{1,2}:\\d{2}(:\\d{2})?", in: text).count
        if timeCount > 0 {
            patterns.append("times")
        }
        
        // Currency pattern
        let currencyCount = try await LanguagePatterns.shared.threadSafeMatch("[¥$€£]\\d+(\\.\\d{2})?", in: text).count
        if currencyCount > 0 {
            patterns.append("currency")
        }
        
        // Percentage pattern
        let percentageCount = try await LanguagePatterns.shared.threadSafeMatch("\\d+(\\.\\d+)?%", in: text).count
        if percentageCount > 0 {
            patterns.append("percentages")
        }
        
        // Email pattern
        let emailCount = try await LanguagePatterns.shared.threadSafeMatch("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", in: text).count
        if emailCount > 0 {
            patterns.append("emails")
        }
        
        return patterns
    }
    
    // MARK: - Special Pattern Analysis
    
    private func analyzeSpecialPatterns(_ text: String) async throws -> [String] {
        var patterns: [String] = []
        
        // URL pattern
        let urlCount = try await LanguagePatterns.shared.threadSafeMatch("https?://[\\w\\d.-]+\\.[\\w]{2,}", in: text).count
        if urlCount > 0 {
            patterns.append("urls")
        }
        
        // File path pattern
        let pathCount = try await LanguagePatterns.shared.threadSafeMatch("/[\\w\\d./]+", in: text).count
        if pathCount > 0 {
            patterns.append("paths")
        }
        
        return patterns
    }
}

// MARK: - Models

public struct TextSelection {
    public let text: String
    public let range: NSRange
    public let type: SelectionType
    public let details: TextAnalysis
    
    public enum SelectionType {
        case word
        case phrase
        case sentence
        case range
    }
}

public struct TextAnalysis {
    public enum WordType {
        case number
        case measure
        case time
        case article
        case pronoun
        case unknown
    }
    
    public var type: WordType = .unknown
    public var partOfSpeech: NLTag?
    public var nameType: NLTag?
    public var lemma: String?
    public var sentences: [(NLTag, NSRange)] = []
    public var detectedLanguage: SupportedLanguage?  // Added language property
    
    // 中文特定属性
    public var isIdiom: Bool = false
    public var isMeasureWord: Bool = false
    
    // 英文特定属性
    public var isAbbreviation: Bool = false
    public var isCompound: Bool = false
    public var isVerbForm: Bool = false
    
    // 法语特定属性
    public var isArticle: Bool = false
    public var isPronoun: Bool = false
    public var isConjugated: Bool = false
    public var isContraction: Bool = false
    public var isPreposition: Bool = false
    public var isAdjective: Bool = false
    public var isAdverb: Bool = false
    public var isTimeExpression: Bool = false
    public var isCommonPhrase: Bool = false
    
    // 通用属性
    public var isProperNoun: Bool = false
    public var isNumber: Bool = false
    public var isPunctuation: Bool = false
    public var isSymbol: Bool = false
    public var isLetter: Bool = false
    public var originalText: String?
    
    // 法语发音相关属性
    public var frenchPronunciation: String?
    public var isSharedVocabulary: Bool = false
    
    // 法语语法分析
    public var verbTense: String?
    public var verbConjugation: String?
    public var morphologyType: String?
    public var genderNumber: String?
    
    // 法语语音分析
    public var phonemes: [String]?
    public var hasLiaison: Bool = false
    public var liaisonPattern: String?
    
    // 法语语义分析
    public var semanticRelation: String?
    public var contextCategory: String?
    public var registerLevel: String?
    
    // 法语数字分析
    public var numberType: String?
    public var numberValue: Int?
    public var ordinalForm: String?
    
    // 语言学习难度分析
    public struct LearningDifficulty {
        public var vocabularyLevel: VocabularyLevel = .unknown
        public var grammarComplexity: GrammarComplexity = .unknown
        public var readingLevel: ReadingLevel = .unknown
        public var overallDifficulty: DifficultyLevel = .unknown
        
        public enum VocabularyLevel {
            case unknown
            case a1_beginner
            case a2_elementary
            case b1_intermediate
            case b2_upperIntermediate
            case c1_advanced
            case c2_mastery
        }
        
        public enum GrammarComplexity {
            case unknown
            case basic
            case intermediate
            case advanced
            case complex
        }
        
        public enum ReadingLevel {
            case unknown
            case beginner
            case intermediate
            case advanced
            case native
        }
        
        public enum DifficultyLevel {
            case unknown
            case easy
            case moderate
            case challenging
            case difficult
            case veryDifficult
        }
    }
    
    public var learningDifficulty: LearningDifficulty = LearningDifficulty()
}

// MARK: - Error Handling

public enum TextAnalysisError: LocalizedError {
    case patternMatchingFailed(Error)
    case invalidTextRange
    case unsupportedLanguage
    
    public var errorDescription: String? {
        switch self {
        case .patternMatchingFailed(let error):
            return "Pattern matching failed: \(error.localizedDescription)"
        case .invalidTextRange:
            return "Invalid text range provided"
        case .unsupportedLanguage:
            return "Unsupported language for analysis"
        }
    }
}

// MARK: - Extensions

extension NSRange {
    func contains(_ index: Int) -> Bool {
        return index >= location && index < location + length
    }
} 
