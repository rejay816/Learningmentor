import Foundation

public struct DocumentMetadata {
    public let id: String
    public let title: String
    public let createdAt: Date
    public let updatedAt: Date
    public let tags: [String]
    
    public init(id: String, title: String, createdAt: Date, updatedAt: Date, tags: [String]) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
    }
} 