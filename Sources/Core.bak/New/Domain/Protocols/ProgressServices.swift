import Foundation

public protocol ProgressTrackingService {
    func trackProgress(_ progress: DocumentProgress) async throws
    func getProgress(for document: Document, user: User) async throws -> DocumentProgress
    func updateProgress(_ progress: DocumentProgress) async throws
    func listProgress(for user: User) async throws -> [DocumentProgress]
}

public protocol StatisticsService {
    func recordActivity(_ activity: LearningActivity) async throws
    func getDailyStatistics(for user: User, on date: Date) async throws -> DailyStatistics
    func getWeeklyStatistics(for user: User, weekStarting: Date) async throws -> WeeklyStatistics
    func getMonthlyStatistics(for user: User, monthStarting: Date) async throws -> MonthlyStatistics
    func getOverallStatistics(for user: User) async throws -> OverallStatistics
}

public protocol AchievementService {
    func unlockAchievement(_ achievement: Achievement, for user: User) async throws
    func getAchievements(for user: User) async throws -> [Achievement]
    func trackProgress(towards milestone: Milestone, for user: User, progress: Int) async throws
    func getMilestones(for user: User) async throws -> [Milestone]
}

public protocol LearningAnalyticsService {
    func analyzeProgress(for user: User) async throws -> [String: Any]
    func generateRecommendations(for user: User) async throws -> [String: Any]
    func predictNextMilestone(for user: User) async throws -> Milestone?
    func calculateEngagementScore(for user: User) async throws -> Double
} 