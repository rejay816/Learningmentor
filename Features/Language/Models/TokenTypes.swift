import Foundation

public enum TokenType {
    case noun
    case verb
    case adjective
    case adverb
    case pronoun
    case determiner
    case particle
    case preposition
    case number
    case conjunction
    case interjection
    case word
    case whitespace
    case punctuation
    case email
    case url
    case dateTime
    case emoji
    case unknown
    
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