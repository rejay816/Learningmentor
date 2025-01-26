import Foundation

struct Config {
    static let openAIKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    static let deepSeekKey: String = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? ""
} 