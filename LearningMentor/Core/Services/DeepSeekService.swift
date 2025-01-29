import Foundation

public enum DeepSeekError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case invalidResponse
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 API URL"
        case .requestFailed(let message):
            return "请求失败: \(message)"
        case .invalidResponse:
            return "无效的响应格式"
        case .apiError(let message):
            return "API 错误: \(message)"
        }
    }
}

public class DeepSeekService {
    private let apiKey: String
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(apiKey: String, baseURL: String = "https://api.deepseek.com/v1/chat/completions", session: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    public func sendMessage(_ content: String, model: String, systemPrompt: String = "") async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw DeepSeekError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var messages: [[String: String]] = []
        if !systemPrompt.isEmpty {
            messages.append(["role": "system", "content": systemPrompt])
        }
        messages.append(["role": "user", "content": content])
        
        let parameters: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeepSeekError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? decoder.decode(APIError.self, from: data) {
                throw DeepSeekError.apiError(error.error.message)
            }
            throw DeepSeekError.apiError("API request failed with status code \(httpResponse.statusCode)")
        }
        
        let apiResponse = try decoder.decode(APIResponse.self, from: data)
        guard let content = apiResponse.firstContent else {
            throw DeepSeekError.apiError("No content in response")
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func removeMarkdown(_ text: String) -> String {
        // 移除加粗和斜体
        var result = text.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\*(.+?)\\*", with: "$1", options: .regularExpression)
        
        // 移除标题标记
        result = result.replacingOccurrences(of: "^#+\\s+", with: "", options: .regularExpression)
        
        // 移除列表标记
        result = result.replacingOccurrences(of: "^[\\-\\*]\\s+", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "^\\d+\\.\\s+", with: "", options: .regularExpression)
        
        // 移除代码块
        result = result.replacingOccurrences(of: "```[\\s\\S]*?```", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "`([^`]+)`", with: "$1", options: .regularExpression)
        
        // 移除链接
        result = result.replacingOccurrences(of: "\\[([^\\]]+)\\]\\([^\\)]+\\)", with: "$1", options: .regularExpression)
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 
