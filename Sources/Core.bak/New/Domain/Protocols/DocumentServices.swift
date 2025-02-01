import Foundation

public protocol DocumentService {
    func createDocument(_ document: Document) async throws -> Document
    func getDocument(by id: UUID) async throws -> Document
    func updateDocument(_ document: Document) async throws -> Document
    func deleteDocument(by id: UUID) async throws
    func listDocuments(for user: User, filter: DocumentFilter?) async throws -> [Document]
}

public protocol DocumentStorageService {
    func store(_ document: Document) async throws -> URL
    func retrieve(from url: URL) async throws -> Document
    func delete(at url: URL) async throws
    func list(in directory: URL) async throws -> [URL]
}

public protocol DocumentProcessingService {
    func loadDocument(from url: URL) async throws -> Document
    func saveDocument(_ document: Document) async throws
    func processDocument(_ document: Document) async throws -> Document
    func analyzeDocument(_ document: Document) async throws -> DocumentMetadata
}

public protocol DocumentAnnotationService {
    func addAnnotation(_ annotation: DocumentAnnotation, to document: Document) async throws
    func removeAnnotation(_ annotation: DocumentAnnotation, from document: Document) async throws
    func getAnnotations(for document: Document, user: User) async throws -> [DocumentAnnotation]
    func updateAnnotation(_ annotation: DocumentAnnotation) async throws
} 