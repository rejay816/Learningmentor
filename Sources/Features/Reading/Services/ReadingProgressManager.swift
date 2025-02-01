import Foundation
import CoreGraphics
import Core

public class ReadingProgressManager {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public static let shared = ReadingProgressManager()
    
    private let progressKey = "reading_progress"
    private let lastReadKey = "last_read_documents"
    
    private init() {}
    
    // 保存阅读进度
    public func saveProgress(for document: Document, page: Int, scrollPosition: CGPoint) {
        let progress = ReadingProgress(
            documentId: document.id,
            page: page,
            scrollPosition: scrollPosition,
            timestamp: Date()
        )
        
        do {
            let data = try encoder.encode(progress)
            defaults.set(data, forKey: progressKey(for: document))
        } catch {
            print("Error saving reading progress: \(error)")
        }
        
        // 更新最近阅读文档列表
        updateLastReadDocuments(document)
    }
    
    // 获取阅读进度
    public func getProgress(for document: Document) -> ReadingProgress? {
        guard let data = defaults.data(forKey: progressKey(for: document)) else {
            return nil
        }
        
        do {
            return try decoder.decode(ReadingProgress.self, from: data)
        } catch {
            print("Error loading reading progress: \(error)")
            return nil
        }
    }
    
    // 加载所有进度
    private func loadAllProgress() -> [String: ReadingProgress] {
        guard let data = defaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode([String: ReadingProgress].self, from: data) else {
            return [:]
        }
        return progress
    }
    
    // 获取最近阅读的文档
    public func getLastReadDocuments(limit: Int = 10) -> [RecentDocument] {
        guard let data = defaults.data(forKey: lastReadKey),
              let documents = try? JSONDecoder().decode([RecentDocument].self, from: data) else {
            return []
        }
        return Array(documents.prefix(limit))
    }
    
    // 清除阅读进度
    public func clearProgress(for document: Document) {
        defaults.removeObject(forKey: progressKey(for: document))
    }
    
    // 清除所有阅读进度
    public func clearAllProgress() {
        let keys = defaults.dictionaryRepresentation().keys
        keys.filter { $0.hasPrefix("reading_progress_") }.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    // 生成进度存储的键
    private func progressKey(for document: Document) -> String {
        return "reading_progress_\(document.id.uuidString)"
    }
    
    // MARK: - Private Helpers
    
    private func updateLastReadDocuments(_ document: Document) {
        var documents = getLastReadDocuments()
        
        // 创建新的最近文档记录
        let recentDoc = RecentDocument(
            id: document.id,
            title: document.title,
            url: document.url,
            lastReadDate: Date()
        )
        
        // 移除已存在的相同文档
        documents.removeAll { $0.id == document.id }
        
        // 添加到开头
        documents.insert(recentDoc, at: 0)
        
        // 限制数量
        documents = Array(documents.prefix(10))
        
        // 保存
        if let data = try? JSONEncoder().encode(documents) {
            defaults.set(data, forKey: lastReadKey)
        }
    }
}

// MARK: - Models

public struct ReadingProgress: Codable {
    public let documentId: UUID
    public let page: Int
    public let scrollPosition: CGPoint
    public let timestamp: Date
    
    public init(documentId: UUID, page: Int, scrollPosition: CGPoint, timestamp: Date) {
        self.documentId = documentId
        self.page = page
        self.scrollPosition = scrollPosition
        self.timestamp = timestamp
    }
}

public struct RecentDocument: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let url: URL
    public let lastReadDate: Date
} 