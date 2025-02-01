import Foundation

public struct DocumentProgress: Codable {
    public let documentId: UUID
    public let userId: UUID
    public let page: Int
    public let position: Double
    public let timestamp: Date
    
    public init(documentId: UUID, userId: UUID, page: Int, position: Double, timestamp: Date = Date()) {
        self.documentId = documentId
        self.userId = userId
        self.page = page
        self.position = position
        self.timestamp = timestamp
    }
}

// ... 其他类型定义 ...
