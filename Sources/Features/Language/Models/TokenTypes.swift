import Foundation

public enum TokenType: String {
    case noun = "noun"
    case verb = "verb"
    case adjective = "adjective"
    case adverb = "adverb"
    case pronoun = "pronoun"
    case determiner = "determiner"
    case particle = "particle"
    case preposition = "preposition"
    case number = "number"
    case conjunction = "conjunction"
    case interjection = "interjection"
    case word = "word"
    case whitespace = "whitespace"
    case punctuation = "punctuation"
    case unknown = "unknown"
    case email = "email"
    case url = "url"
    case dateTime = "dateTime"
    case emoji = "emoji"
    
    // 获取类型的本地化描述
    public var localizedDescription: String {
        switch self {
        case .noun: return "名词"
        case .verb: return "动词"
        case .adjective: return "形容词"
        case .adverb: return "副词"
        case .pronoun: return "代词"
        case .determiner: return "限定词"
        case .particle: return "助词"
        case .preposition: return "介词"
        case .number: return "数字"
        case .conjunction: return "连词"
        case .interjection: return "感叹词"
        case .word: return "词语"
        case .whitespace: return "空白"
        case .punctuation: return "标点"
        case .email: return "邮箱"
        case .url: return "网址"
        case .dateTime: return "日期时间"
        case .emoji: return "表情"
        case .unknown: return "未知"
        }
    }
} 