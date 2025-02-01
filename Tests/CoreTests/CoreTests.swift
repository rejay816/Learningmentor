import XCTest
@testable import Core

final class CoreTests: XCTestCase {
    func testDocumentCreation() {
        let document = Document(
            content: "Test content",
            title: "Test Document",
            fileURL: URL(fileURLWithPath: "/test/path/document.txt")
        )
        
        XCTAssertEqual(document.content, "Test content")
        XCTAssertEqual(document.title, "Test Document")
        XCTAssertEqual(document.fileURL.lastPathComponent, "document.txt")
    }
    
    func testReaderState() {
        let document = Document(
            content: "Test content",
            title: "Test Document",
            fileURL: URL(fileURLWithPath: "/test/path/document.txt")
        )
        
        let states: [ReaderState] = [
            .initial,
            .loading,
            .loaded(document: document),
            .error("Test error")
        ]
        
        XCTAssertEqual(states[0], .initial)
        
        if case .loaded(let doc) = states[2] {
            XCTAssertEqual(doc.title, "Test Document")
        } else {
            XCTFail("Expected loaded state")
        }
    }
} 