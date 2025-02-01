import Foundation
import Core

public class ReadingStatsManager {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public static let shared = ReadingStatsManager()
    
    private let statsKey = "reading_statistics"
    private let monthlyStatsKey = "monthly_reading_statistics"
    
    private init() {}
    
    // MARK: - 统计记录
    
    public func recordReading(document: Document, duration: TimeInterval, pagesRead: Int) {
        // 更新文档统计
        updateDocumentStats(document, duration: duration, pagesRead: pagesRead)
        // 更新每月统计
        updateMonthlyStats(duration: duration, pagesRead: pagesRead)
    }
    
    // MARK: - 文档统计
    
    private func updateDocumentStats(_ document: Document, duration: TimeInterval, pagesRead: Int) {
        var stats = getDocumentStats()
        let documentId = document.id.uuidString
        
        if var docStats = stats[documentId] {
            docStats.totalDuration += duration
            docStats.totalPagesRead += pagesRead
            docStats.lastReadDate = Date()
            docStats.readCount += 1
            stats[documentId] = docStats
        } else {
            stats[documentId] = DocumentStats(
                documentId: document.id,
                title: document.title,
                totalDuration: duration,
                totalPagesRead: pagesRead,
                readCount: 1,
                lastReadDate: Date()
            )
        }
        
        saveDocumentStats(stats)
    }
    
    public func getDocumentStats() -> [String: DocumentStats] {
        guard let data = defaults.data(forKey: statsKey),
              let stats = try? decoder.decode([String: DocumentStats].self, from: data) else {
            return [:]
        }
        return stats
    }
    
    private func saveDocumentStats(_ stats: [String: DocumentStats]) {
        if let data = try? encoder.encode(stats) {
            defaults.set(data, forKey: statsKey)
        }
    }
    
    // MARK: - 月度统计
    
    private func updateMonthlyStats(duration: TimeInterval, pagesRead: Int) {
        var stats = getMonthlyStats()
        let key = currentMonthKey()
        
        if var monthStats = stats[key] {
            monthStats.totalDuration += duration
            monthStats.totalPagesRead += pagesRead
            monthStats.readDays.insert(currentDayKey())
            stats[key] = monthStats
        } else {
            stats[key] = MonthlyStats(
                year: Calendar.current.component(.year, from: Date()),
                month: Calendar.current.component(.month, from: Date()),
                totalDuration: duration,
                totalPagesRead: pagesRead,
                readDays: Set([currentDayKey()])
            )
        }
        
        saveMonthlyStats(stats)
    }
    
    public func getMonthlyStats() -> [String: MonthlyStats] {
        guard let data = defaults.data(forKey: monthlyStatsKey),
              let stats = try? decoder.decode([String: MonthlyStats].self, from: data) else {
            return [:]
        }
        return stats
    }
    
    private func saveMonthlyStats(_ stats: [String: MonthlyStats]) {
        if let data = try? encoder.encode(stats) {
            defaults.set(data, forKey: monthlyStatsKey)
        }
    }
    
    // MARK: - Helpers
    
    private func currentMonthKey() -> String {
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        return "\(year)-\(String(format: "%02d", month))"
    }
    
    private func currentDayKey() -> String {
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }
}

// MARK: - Models

public struct DocumentStats: Codable {
    public let documentId: UUID
    public let title: String
    public var totalDuration: TimeInterval
    public var totalPagesRead: Int
    public var readCount: Int
    public var lastReadDate: Date
    
    public var averageTimePerPage: TimeInterval {
        guard totalPagesRead > 0 else { return 0 }
        return totalDuration / Double(totalPagesRead)
    }
}

public struct MonthlyStats: Codable {
    public let year: Int
    public let month: Int
    public var totalDuration: TimeInterval
    public var totalPagesRead: Int
    public var readDays: Set<String>
    
    public var readDaysCount: Int {
        readDays.count
    }
    
    public var averageTimePerDay: TimeInterval {
        guard !readDays.isEmpty else { return 0 }
        return totalDuration / Double(readDays.count)
    }
    
    public var averagePagesPerDay: Double {
        guard !readDays.isEmpty else { return 0 }
        return Double(totalPagesRead) / Double(readDays.count)
    }
} 