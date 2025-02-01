import XCTest
@testable import Features

final class FeaturesTests: XCTestCase {
    func testReadingHandler() async {
        let handler = ReadingHandler()
        
        // 创建测试文档
        let testURL = URL(fileURLWithPath: "/test/document.txt")
        let document = NSDocument()
        
        // 测试文件类型支持
        XCTAssertTrue(handler.canHandle(document))
    }
    
    func testListeningHandler() async {
        let handler = ListeningHandler()
        
        // 创建测试音频文档
        let testURL = URL(fileURLWithPath: "/test/audio.mp3")
        let document = NSDocument()
        
        // 测试文件类型支持
        XCTAssertTrue(handler.canHandle(document))
    }
}
