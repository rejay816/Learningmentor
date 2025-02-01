import Foundation
import SwiftUI
import Core
import PDFKit

@MainActor
public class DocumentViewModel: ObservableObject {
    @Published private(set) var document: Document?
    @Published public var title: String = ""
    @Published public var currentPage: Int = 0
    @Published public var pageCount: Int = 1
    @Published public var selectedText: String = ""
    @Published public var isTextSelected: Bool = false
    @Published public var scrollPosition: CGPoint = .zero
    
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var readingStartTime: Date?
    @Published var lastRecordTime: Date?
    @Published var readingStats: ReadingStats?
    
    private var startTime: Date?
    private var wordsRead: Int = 0
    
    private let progressManager = ReadingProgressManager.shared
    private let statsManager = ReadingStatsManager.shared
    // private let logger = Logger.shared
    
    private var timer: Timer?
    
    public init() {}
    
    deinit {
        timer?.invalidate()
        
        // 在主线程上执行清理工作
        Task { @MainActor [weak self] in
            guard let self = self,
                  let document = self.document,
                  let startTime = self.startTime else { return }
            
            let timeSpent = Date().timeIntervalSince(startTime)
            let wordsCount = self.wordsRead
            
            self.statsManager.recordReading(
                document: document,
                duration: timeSpent,
                pagesRead: wordsCount
            )
        }
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.recordReadingStats()
            }
        }
    }
    
    private func handleDocumentLoaded(_ document: Document) {
        self.document = document
        self.title = document.title
        
        // 恢复阅读进度
        loadProgress(for: document)
        
        // 开始阅读统计
        startReading()
        clearSelection()
    }
    
    private func loadProgress(for document: Document) {
        if let progress = progressManager.getProgress(for: document) {
            currentPage = progress.page
            scrollPosition = progress.scrollPosition
        }
    }
    
    private func startReading() {
        startTime = Date()
        wordsRead = 0
        readingStartTime = Date()
        lastRecordTime = nil
        startStatsTimer()
    }
    
    private func startStatsTimer() {
        // 创建定时器记录阅读统计
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.recordReadingStats()
            }
        }
    }
    
    private func recordReadingStats() async {
        guard let document = document,
              let startTime = startTime else { return }
        
        // 简化函数调用，只保留必要参数
        processDocument(document, format: .text)
        
        let newDoc = transformDocument("some text", docType: .text)
        
        let timeSpent = Date().timeIntervalSince(startTime)
        let wordsCount = self.wordsRead
        
        // 更新阅读统计
        var stats = readingStats ?? ReadingStats()
        stats.totalReadingTime += timeSpent
        stats.sessionCount += 1
        
        // 更新最后记录时间
        lastRecordTime = Date()
        readingStats = stats
        
        // 保存统计数据
        await saveReadingStats(stats, for: document)
    }
    
    private func saveReadingStats(_ stats: ReadingStats, for document: Document) async {
        // TODO: 实现统计数据的持久化
    }
    
    private func updateReadingStats() async {
        guard let document = document, let startTime = startTime else { return }
        let timeSpent = Date().timeIntervalSince(startTime)
        statsManager.recordReading(document: document, duration: timeSpent, pagesRead: wordsRead)
    }
    
    // MARK: - Public Methods
    
    public func loadDocument(from url: URL) async throws {
        isLoading = true
        error = nil
        
        do {
            let fileType = url.pathExtension.lowercased()
            let fileName = url.lastPathComponent
            let documentId = UUID()
            
            let document: Document
            switch fileType {
            case "pdf":
                guard let pdfDocument = PDFDocument(url: url) else {
                    throw DocumentError.invalidPDF
                }
                document = Document(
                    id: documentId,
                    url: url,
                    title: fileName,
                    type: .pdf(pdfDocument),
                    content: .pdf(pdfDocument)
                )
                
            case "txt", "rtf":
                guard let text = try? String(contentsOf: url, encoding: .utf8) else {
                    throw DocumentError.invalidTextEncoding
                }
                let documentType: DocumentType = fileType == "rtf" ? .richText(nil) : .plainText(text)
                document = Document(
                    id: documentId,
                    url: url,
                    title: fileName,
                    type: documentType,
                    content: .text(text)
                )
                
            default:
                throw DocumentError.invalidDocument
            }
            
            self.document = document
            self.title = document.title
            isLoading = false
            loadProgress(for: document)
            startReading()
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    public func closeDocument() {
        document = nil
        error = nil
    }
    
    public func handleTextSelection(_ text: String, range: NSRange) {
        selectedText = text
        isTextSelected = !text.isEmpty
    }
    
    public func clearSelection() {
        selectedText = ""
        isTextSelected = false
    }
    
    public func copySelectedText() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedText, forType: .string)
    }
    
    public func updateScrollPosition(_ point: CGPoint) {
        scrollPosition = point
        if let document = document {
            progressManager.saveProgress(for: document, page: currentPage, scrollPosition: point)
        }
    }
    
    public func nextPage() {
        if currentPage < pageCount - 1 {
            currentPage += 1
            saveProgress()
        }
    }
    
    public func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            saveProgress()
        }
    }
    
    // MARK: - Private Methods
    
    private func saveProgress() {
        guard let document = document else { return }
        progressManager.saveProgress(for: document, page: currentPage, scrollPosition: scrollPosition)
    }
    
    private func getProgress() -> ReadingProgress? {
        guard let document = document else { return nil }
        return progressManager.getProgress(for: document)
    }
    
    private func processDocument(_ document: Document, format: DocumentType) -> Bool {
        return true
    }
    
    func transformDocument(_ text: String, docType: DocumentType) -> Document {
        return Document(content: text, title: "Untitled")
    }
}

struct ReadingStats {
    var totalReadingTime: TimeInterval = 0
    var sessionCount: Int = 0
    var averageSessionDuration: TimeInterval {
        guard sessionCount > 0 else { return 0 }
        return totalReadingTime / Double(sessionCount)
    }
} 