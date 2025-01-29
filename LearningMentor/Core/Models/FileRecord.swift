import Foundation

public struct FileRecord: Identifiable, Codable {
    public let id: UUID
    public let path: String
    public let fileName: String
    public let fileSize: Int64
    public let fileType: String
    public let content: String
    public let timestamp: Date
    
    public init(id: UUID = UUID(), path: String, fileName: String, fileSize: Int64, fileType: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.path = path
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileType = fileType
        self.content = content
        self.timestamp = timestamp
    }
} 