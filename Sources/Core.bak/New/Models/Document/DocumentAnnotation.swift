import Foundation

public struct DocumentAnnotation {
    public let id: String
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date
    public let position: Int
    
    public init(id: String, content: String, createdAt: Date, updatedAt: Date, position: Int) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.position = position
    }
} 