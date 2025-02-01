import Foundation

public struct Document {
    public let content: String
    public let title: String
    public let fileURL: URL
    
    public init(content: String, title: String, fileURL: URL) {
        self.content = content
        self.title = title
        self.fileURL = fileURL
    }
}
