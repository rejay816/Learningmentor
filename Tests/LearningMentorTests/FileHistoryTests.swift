import XCTest
@testable import LearningMentor

final class FileHistoryTests: XCTestCase {
    var historyManager: FileHistoryManager!
    
    override func setUp() {
        super.setUp()
        historyManager = FileHistoryManager()
        // 清除之前的测试数据
        UserDefaults.standard.removeObject(forKey: "fileHistoryRecords")
        UserDefaults.standard.removeObject(forKey: "fileHistoryFavorites")
    }
    
    override func tearDown() {
        historyManager = nil
        super.tearDown()
    }
    
    func testAddRecord() async {
        let record = FileRecord(
            path: "/test/path",
            fileName: "test.txt",
            fileSize: 1024,
            fileType: "TXT",
            content: "Test content"
        )
        
        await historyManager.addRecord(record)
        
        XCTAssertEqual(historyManager.records.count, 1)
        XCTAssertEqual(historyManager.records[0].fileName, "test.txt")
    }
    
    func testAddDuplicateRecord() async {
        let record1 = FileRecord(
            path: "/test/path",
            fileName: "test.txt",
            fileSize: 1024,
            fileType: "TXT",
            content: "Test content 1"
        )
        
        let record2 = FileRecord(
            path: "/test/path",
            fileName: "test.txt",
            fileSize: 2048,
            fileType: "TXT",
            content: "Test content 2"
        )
        
        await historyManager.addRecord(record1)
        await historyManager.addRecord(record2)
        
        XCTAssertEqual(historyManager.records.count, 1)
        XCTAssertEqual(historyManager.records[0].content, "Test content 2")
    }
    
    func testToggleFavorite() async {
        let record = FileRecord(
            path: "/test/path",
            fileName: "test.txt",
            fileSize: 1024,
            fileType: "TXT",
            content: "Test content"
        )
        
        await historyManager.addRecord(record)
        await historyManager.toggleFavorite(for: record)
        
        XCTAssertEqual(historyManager.favorites.count, 1)
        
        await historyManager.toggleFavorite(for: record)
        
        XCTAssertEqual(historyManager.favorites.count, 0)
    }
    
    func testRemoveRecord() async {
        let record = FileRecord(
            path: "/test/path",
            fileName: "test.txt",
            fileSize: 1024,
            fileType: "TXT",
            content: "Test content"
        )
        
        await historyManager.addRecord(record)
        await historyManager.toggleFavorite(for: record)
        
        XCTAssertEqual(historyManager.records.count, 1)
        XCTAssertEqual(historyManager.favorites.count, 1)
        
        await historyManager.removeRecord(record)
        
        XCTAssertEqual(historyManager.records.count, 0)
        XCTAssertEqual(historyManager.favorites.count, 0)
    }
    
    func testClearHistory() async {
        let record1 = FileRecord(
            path: "/test/path1",
            fileName: "test1.txt",
            fileSize: 1024,
            fileType: "TXT",
            content: "Test content 1"
        )
        
        let record2 = FileRecord(
            path: "/test/path2",
            fileName: "test2.txt",
            fileSize: 2048,
            fileType: "TXT",
            content: "Test content 2"
        )
        
        await historyManager.addRecord(record1)
        await historyManager.addRecord(record2)
        
        XCTAssertEqual(historyManager.records.count, 2)
        
        await historyManager.clearHistory()
        
        XCTAssertEqual(historyManager.records.count, 0)
    }
    
    func testMaxRecordsLimit() async {
        for i in 0..<150 {
            let record = FileRecord(
                path: "/test/path\(i)",
                fileName: "test\(i).txt",
                fileSize: Int64(1024 * i),
                fileType: "TXT",
                content: "Test content \(i)"
            )
            await historyManager.addRecord(record)
        }
        
        XCTAssertEqual(historyManager.records.count, 100)
        XCTAssertEqual(historyManager.records[0].fileName, "test149.txt")
    }
} 