import Foundation
import os.log

public class OpenAIService {
    private let apiKey: String
    private let baseURL = URL(string: "https://api.openai.com/v1")!
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    public func sendMessage(_ content: String, model: String, systemPrompt: String) async throws -> String {
        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var messages: [[String: Any]] = []
        if !systemPrompt.isEmpty {
            messages.append([
                "role": "system",
                "content": systemPrompt
            ])
        }
        messages.append([
            "role": "user",
            "content": content
        ])
        
        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? decoder.decode(APIError.self, from: data) {
                throw AppError.apiError(error.error.message)
            }
            throw AppError.apiError("API request failed with status code \(httpResponse.statusCode)")
        }
        
        let apiResponse = try decoder.decode(APIResponse.self, from: data)
        guard let content = apiResponse.firstContent else {
            throw AppError.apiError("No content in response")
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 