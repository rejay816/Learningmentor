import Foundation

public struct APIError: Codable, Error {
    public struct ErrorDetail: Codable {
        public let message: String
        public let type: String?
        public let param: String?
        public let code: String?
        
        public init(message: String, type: String? = nil, param: String? = nil, code: String? = nil) {
            self.message = message
            self.type = type
            self.param = param
            self.code = code
        }
    }
    
    public let error: ErrorDetail
    
    public init(error: ErrorDetail) {
        self.error = error
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return error.message
    }
    
    public var failureReason: String? {
        return error.type
    }
    
    public var recoverySuggestion: String? {
        switch error.code {
        case "insufficient_quota":
            return "API配额不足，请稍后再试"
        case "invalid_api_key":
            return "API密钥无效，请检查设置"
        case "rate_limit_exceeded":
            return "请求频率过高，请稍后再试"
        case "model_not_found":
            return "所选模型不可用，请选择其他模型"
        case "context_length_exceeded":
            return "输入内容过长，请缩短后重试"
        default:
            return nil
        }
    }
} 