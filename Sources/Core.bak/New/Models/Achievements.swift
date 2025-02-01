import Foundation

public struct Achievement: Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let type: AchievementType
    public let unlockedAt: Date?
    
    public enum AchievementType: String, Codable {
        case readingStreak
        case documentsRead
        case timeSpent
        case perfectScore
    }
}

public struct Milestone: Codable {
    public let id: UUID
    public let title: String
    public let targetValue: Int
    public let currentValue: Int
    public let type: MilestoneType
    
    public enum MilestoneType: String, Codable {
        case daily
        case weekly
        case monthly
        case lifetime
    }
} 