import Foundation
import NaturalLanguage
import Features

public class EnhancedLanguageProcessor {
    // 语言标注器
    private var tokens: [EnhancedToken] = []
    private let tagger: NLTagger
    
    public init() {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
    }
    
    // 自定义边界模式
    private let patterns: [WordBoundaryPattern] = [
        // 数字模式（包括整数、小数、科学计数法）
        .init(pattern: #"[-+]?\d*\.?\d+([eE][-+]?\d+)?"#, type: .number),
        
        // 邮箱地址
        .init(pattern: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#, type: .email),
        
        // URL
        .init(pattern: #"https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)"#, type: .url),
        
        // 日期时间
        .init(pattern: #"\d{4}[-/年]\d{1,2}[-/月]\d{1,2}日?"#, type: .dateTime),
        
        // 特殊标点符号组合
        .init(pattern: #"[!?！？]{2,}"#, type: .punctuation),
        
        // 表情符号
        .init(pattern: #"[\u{1F300}-\u{1F9FF}]"#, type: .emoji)
    ]
    
    public func processText(_ text: String) -> [EnhancedToken] {
        tokens.removeAll()
        tagger.string = text
        
        let range = text.startIndex..<text.endIndex
        processTokens(in: text, range: range)
        
        return tokens.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
    
    private func determineTokenType(_ tag: NLTag?, text: String) -> TokenType {
        guard let tag = tag else { return .unknown }
        
        switch tag {
        case .noun, .personalName, .placeName, .organizationName:
            return .noun
        case .verb:
            return .verb
        case .adjective:
            return .adjective
        case .adverb:
            return .adverb
        case .pronoun:
            return .pronoun
        case .determiner:
            return .determiner
        case .particle:
            return .particle
        case .preposition:
            return .preposition
        case .number:
            return .number
        case .conjunction:
            return .conjunction
        case .interjection:
            return .interjection
        case .word:
            if text.rangeOfCharacter(from: .decimalDigits) != nil {
                return .number
            }
            return .word
        case .whitespace:
            return .whitespace
        case .punctuation:
            return .punctuation
        default:
            return .unknown
        }
    }
    
    private func processToken(_ token: String, type: NLTag, range: Range<String.Index>) {
        let enhancedToken = EnhancedToken(
            text: token,
            range: range,
            type: determineTokenType(type, text: token)
        )
        tokens.append(enhancedToken)
    }
    
    private func processTokens(in text: String, range: Range<String.Index>) {
        var processedRanges = Set<Range<String.Index>>()
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            guard !processedRanges.contains(tokenRange) else { return true }
            
            processedRanges.insert(tokenRange)
            let token = String(text[tokenRange])
            
            if let tag = tag {
                processToken(token, type: tag, range: tokenRange)
            }
            
            return true
        }
    }
}

// 自定义边界模式
private struct WordBoundaryPattern {
    let pattern: String
    let type: TokenType
}

// 增强的词元模型
public struct EnhancedToken: Identifiable {
    public let id = UUID()
    public let text: String
    public let range: Range<String.Index>
    public let type: TokenType
    
    public var length: Int {
        text.count
    }
}

// 获取类型的本地化描述
// public var localizedDescription: String {
//     switch self {
//     case .noun: return "名词"
//     case .verb: return "动词"
//     case .adjective: return "形容词"
//     case .adverb: return "副词"
//     case .pronoun: return "代词"
//     case .determiner: return "限定词"
//     case .particle: return "助词"
//     case .preposition: return "介词"
//     case .number: return "数字"
//     case .conjunction: return "连词"
//     case .interjection: return "感叹词"
//     case .word: return "词语"
//     case .whitespace: return "空白"
//     case .punctuation: return "标点"
//     case .email: return "邮箱"
//     case .url: return "网址"
//     case .dateTime: return "日期时间"
//     case .emoji: return "表情"
//     case .unknown: return "未知"
//     }
// } 