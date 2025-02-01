import Foundation

public struct Document {
    public let id: String
    public let metadata: DocumentMetadata
    public let content: String
    public let annotations: [DocumentAnnotation]
    
    public init(id: String, metadata: DocumentMetadata, content: String, annotations: [DocumentAnnotation] = []) {
        self.id = id
        self.metadata = metadata
        self.content = content
        self.annotations = annotations
    }
} 