//
//  AnkiService.swift
//  LearningMentor
//
//  与 AnkiConnect 通信
//

import Foundation

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) { self.value = value }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let i as Int:
            try container.encode(i)
        case let d as Double:
            try container.encode(d)
        case let s as String:
            try container.encode(s)
        case let b as Bool:
            try container.encode(b)
        case let arr as [Any]:
            try container.encode(arr.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        self.value = ""
    }
}

struct AnkiRequest: Encodable {
    let action: String
    let version: Int = 6
    let params: [String: AnyCodable]
    
    init(action: String, params: [String: Any]) {
        self.action = action
        self.params = params.mapValues { AnyCodable($0) }
    }
}

struct AnkiResponse<T: Decodable>: Decodable {
    let result: T
    let error: String?
}

enum AnkiServiceError: Error {
    case connectionFailed
    case invalidResponse
    case deckCreationFailed
    case noteAdditionFailed
}

class AnkiService {
    let endpoint = URL(string: "http://127.0.0.1:8765")!
    let ankiVersion = 6
    
    func findNotes(expression: String) async throws -> [Int] {
        let query = "front:\"\(expression)\""
        let reqDict: [String: Any] = [
            "action": "findNotes",
            "version": ankiVersion,
            "params": [
                "query": query
            ]
        ]
        let data = try await postJson(reqDict)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let result = json?["result"] as? [Int] ?? []
        return result
    }
    
    func createDeckIfNeeded(deckName: String) async throws {
        let reqDict: [String: Any] = [
            "action": "createDeck",
            "version": ankiVersion,
            "params": [
                "deck": deckName
            ]
        ]
        _ = try await postJson(reqDict)
    }
    
    func addNotes(deckName: String, noteDictArray: [[String: Any]]) async throws {
        let reqDict: [String: Any] = [
            "action": "addNotes",
            "version": ankiVersion,
            "params": [
                "notes": noteDictArray
            ]
        ]
        _ = try await postJson(reqDict)
    }
    
    @discardableResult
    func postJson(_ dict: [String: Any]) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        let (respData, _) = try await URLSession.shared.upload(for: request, from: data)
        return respData
    }
    
    // 获取所有牌组
    func getDecks() async throws -> [String] {
        let request = AnkiRequest(action: "deckNames", params: [:])
        let response: AnkiResponse<[String]> = try await sendRequest(request)
        return response.result
    }
    
    // 获取所有模板
    func getModels() async throws -> [String] {
        let request = AnkiRequest(action: "modelNames", params: [:])
        let response: AnkiResponse<[String]> = try await sendRequest(request)
        return response.result
    }
    
    // 创建新模板
    func createModel(name: String, fields: [String]) async throws {
        let params: [String: Any] = [
            "modelName": name,
            "inOrderFields": fields,
            "css": """
                .card {
                    font-family: arial;
                    font-size: 20px;
                    text-align: center;
                    color: black;
                    background-color: white;
                }
                """,
            "cardTemplates": [
                [
                    "Front": "{{正面}}",
                    "Back": """
                        {{FrontSide}}
                        <hr id="answer">
                        {{背面}}
                        """
                ]
            ]
        ]
        
        let request = AnkiRequest(action: "createModel", params: params)
        let _: AnkiResponse<Bool> = try await sendRequest(request)
    }
    
    // 添加通用请求方法
    func sendRequest<T: Decodable>(_ request: AnkiRequest) async throws -> AnkiResponse<T> {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        let (responseData, _) = try await URLSession.shared.upload(for: urlRequest, from: data)
        
        let decoder = JSONDecoder()
        return try decoder.decode(AnkiResponse<T>.self, from: responseData)
    }
    
    // 添加批量处理方法
    func addNotesInBatches(deckName: String, noteDictArray: [[String: Any]], batchSize: Int = 50) async throws -> (created: Int, duplicates: Int, errors: Int) {
        var created = 0
        var duplicates = 0
        var errors = 0
        
        // 分批处理
        for batch in stride(from: 0, to: noteDictArray.count, by: batchSize) {
            let endIndex = min(batch + batchSize, noteDictArray.count)
            let currentBatch = Array(noteDictArray[batch..<endIndex])
            
            do {
                // 检查重复
                let expressions = currentBatch.compactMap { dict -> String? in
                    guard let fields = dict["fields"] as? [String: String] else { return nil }
                    return fields["Front"] ?? fields["正面"] ?? fields["法语表达"]
                }
                
                var duplicateIndices = Set<Int>()
                for (index, expression) in expressions.enumerated() {
                    let foundNotes = try await findNotes(expression: expression)
                    if !foundNotes.isEmpty {
                        duplicateIndices.insert(index)
                    }
                }
                
                // 过滤掉重复的笔记
                let newNotes = currentBatch.enumerated().filter { !duplicateIndices.contains($0.offset) }.map { $0.element }
                
                if !newNotes.isEmpty {
                    try await addNotes(deckName: deckName, noteDictArray: newNotes)
                    created += newNotes.count
                }
                duplicates += duplicateIndices.count
                
            } catch {
                errors += currentBatch.count
                print("Batch processing error: \(error)")
            }
            
            // 添加小延迟避免请求过快
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        }
        
        return (created, duplicates, errors)
    }
    
    // 添加取消支持
    private var currentTask: Task<Void, Error>?
    
    func cancelCurrentOperation() {
        currentTask?.cancel()
    }
    
    // 添加重试机制
    private func retryOperation<T>(maxAttempts: Int = 3, operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    // 指数退避
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                    continue
                }
            }
        }
        
        throw lastError!
    }
}
