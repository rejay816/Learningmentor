import Foundation

enum DeepSeekError: Error {
    case invalidURL
    case requestFailed(String)
    case invalidResponse
    case apiError(String)
}

class DeepSeekService {
    private let apiKey: String
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
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
    
    func sendMessage(_ message: String, model: String, systemPrompt: String) async throws -> String {
        print("\n=== DeepSeek API Request ===")
        print("Model: \(model)")
        print("System Prompt: \(systemPrompt)")
        print("Message: \(message)")
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": message]
        ]
        
        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "response_format": ["type": "text"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("\n=== DeepSeek API Response ===")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonStr = String(data: data, encoding: .utf8) {
            print("Raw Response: \(jsonStr)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DeepSeekError.requestFailed("请求失败")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let error = json?["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw DeepSeekError.apiError(message)
        }
        
        if let choices = json?["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            print("\n=== Parsed Content ===")
            print(content)
            return removeMarkdown(content)
        }
        
        throw DeepSeekError.invalidResponse
    }
} 