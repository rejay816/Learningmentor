import Foundation

public struct DocumentStats: Codable {
    public let documentId: UUID
    public let readTime: TimeInterval
    public let completionPercentage: Double
    public let lastAccessed: Date
}

public struct DailyStatistics: Codable {
    public let date: Date
    public let totalReadingTime: TimeInterval
    public let documentsRead: Int
}

public struct WeeklyStatistics: Codable {
    public let weekStarting: Date
    public let dailyStats: [DailyStatistics]
}

public struct MonthlyStatistics: Codable {
    public let month: Date
    public let weeklyStats: [WeeklyStatistics]
}

public struct OverallStatistics: Codable {
    public let totalReadingTime: TimeInterval
    public let totalDocuments: Int
    public let averageReadingTime: TimeInterval
} 