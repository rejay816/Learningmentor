import Foundation

public protocol LanguageLearningProgressService {
    // 进度跟踪
    func trackProgress(for language: SupportedLanguage) async throws -> LearningProgress
    func updateProgress(_ progress: LearningProgress) async throws
    
    // 学习目标
    func setLearningGoals(_ goals: LearningGoals, for language: SupportedLanguage) async throws
    func getLearningGoals(for language: SupportedLanguage) async throws -> LearningGoals
    
    // 学习统计
    func getStatistics(for language: SupportedLanguage) async throws -> LearningStatistics
    func recordLearningSession(_ session: LearningSession) async throws
}

// 学习进度模型
public struct LearningProgress {
    public let language: SupportedLanguage
    public let level: LearningDifficulty.Level
    public let vocabulary: VocabularyProgress
    public let grammar: GrammarProgress
    public let listening: ListeningProgress
    public let reading: ReadingProgress
    public let speaking: SpeakingProgress
    public let writing: WritingProgress
    public let lastUpdated: Date
    
    public struct VocabularyProgress {
        public let knownWords: Int
        public let activeVocabulary: Int
        public let passiveVocabulary: Int
        public let recentlyLearned: [String]
        public let needsReview: [String]
    }
    
    public struct GrammarProgress {
        public let masteredPatterns: [String]
        public let learningPatterns: [String]
        public let troubleSpots: [String]
        public let recentErrors: [(pattern: String, context: String)]
    }
    
    public struct ListeningProgress {
        public let comprehensionRate: Double
        public let totalListeningTime: TimeInterval
        public let completedExercises: Int
        public let difficultSounds: [String]
    }
    
    public struct ReadingProgress {
        public let wordsPerMinute: Int
        public let comprehensionRate: Double
        public let completedTexts: Int
        public let totalReadingTime: TimeInterval
    }
    
    public struct SpeakingProgress {
        public let fluencyScore: Double
        public let pronunciationAccuracy: Double
        public let recordedPracticeTime: TimeInterval
        public let troubleSounds: [String]
    }
    
    public struct WritingProgress {
        public let composedTexts: Int
        public let averageLength: Int
        public let commonErrors: [String]
        public let vocabularyDiversity: Double
    }
}

// 学习目标模型
public struct LearningGoals {
    public let language: SupportedLanguage
    public let targetLevel: LearningDifficulty.Level
    public let deadline: Date?
    public let weeklyGoals: WeeklyGoals
    public let specificGoals: [SpecificGoal]
    
    public struct WeeklyGoals {
        public let studyHours: Int
        public let newVocabulary: Int
        public let readingPages: Int
        public let listeningMinutes: Int
        public let writingExercises: Int
        public let speakingPractice: Int
    }
    
    public struct SpecificGoal {
        public let type: GoalType
        public let description: String
        public let targetDate: Date?
        public let progress: Double
        
        public enum GoalType {
            case vocabulary
            case grammar
            case reading
            case listening
            case speaking
            case writing
            case certification
            case custom(String)
        }
    }
}

// 学习统计模型
public struct LearningStatistics {
    public let totalStudyTime: TimeInterval
    public let sessionsCompleted: Int
    public let averageSessionDuration: TimeInterval
    public let streakDays: Int
    public let weeklyProgress: [WeeklySnapshot]
    public let strengthAreas: [StrengthArea]
    public let weaknessAreas: [WeaknessArea]
    
    public struct WeeklySnapshot {
        public let weekStartDate: Date
        public let studyHours: Double
        public let newWordsLearned: Int
        public let exercisesCompleted: Int
        public let skillProgress: [SkillProgress]
    }
    
    public struct SkillProgress {
        public let skill: Skill
        public let progress: Double
        public let improvement: Double
        
        public enum Skill {
            case vocabulary
            case grammar
            case reading
            case listening
            case speaking
            case writing
        }
    }
    
    public struct StrengthArea {
        public let skill: SkillProgress.Skill
        public let score: Double
        public let evidence: [String]
    }
    
    public struct WeaknessArea {
        public let skill: SkillProgress.Skill
        public let score: Double
        public let recommendations: [String]
    }
}

// 学习会话模型
public struct LearningSession {
    public let startTime: Date
    public let duration: TimeInterval
    public let activities: [LearningActivity]
    public let performance: SessionPerformance
    
    public struct LearningActivity {
        public let type: ActivityType
        public let duration: TimeInterval
        public let content: String
        public let difficulty: LearningDifficulty.Level
        public let completed: Bool
        public let score: Double?
        
        public enum ActivityType {
            case vocabulary
            case grammar
            case reading
            case listening
            case speaking
            case writing
            case review
            case test
        }
    }
    
    public struct SessionPerformance {
        public let accuracyRate: Double
        public let completionRate: Double
        public let focusScore: Double
        public let challengeLevel: Int
        public let notes: String?
    }
}

// 默认实现
public class DefaultLanguageLearningProgressService: LanguageLearningProgressService {
    private let storage: ProgressStorage
    
    public init(storage: ProgressStorage) {
        self.storage = storage
    }
    
    public func trackProgress(for language: SupportedLanguage) async throws -> LearningProgress {
        return try await storage.getProgress(for: language)
    }
    
    public func updateProgress(_ progress: LearningProgress) async throws {
        try await storage.saveProgress(progress)
    }
    
    public func setLearningGoals(_ goals: LearningGoals, for language: SupportedLanguage) async throws {
        try await storage.saveGoals(goals, for: language)
    }
    
    public func getLearningGoals(for language: SupportedLanguage) async throws -> LearningGoals {
        return try await storage.getGoals(for: language)
    }
    
    public func getStatistics(for language: SupportedLanguage) async throws -> LearningStatistics {
        return try await storage.getStatistics(for: language)
    }
    
    public func recordLearningSession(_ session: LearningSession) async throws {
        try await storage.saveSession(session)
        // 更新相关统计数据
        try await updateStatisticsAfterSession(session)
    }
    
    // MARK: - Private Methods
    
    private func updateStatisticsAfterSession(_ session: LearningSession) async throws {
        // 实现统计数据更新逻辑
    }
}

// 存储协议
public protocol ProgressStorage {
    func getProgress(for language: SupportedLanguage) async throws -> LearningProgress
    func saveProgress(_ progress: LearningProgress) async throws
    func getGoals(for language: SupportedLanguage) async throws -> LearningGoals
    func saveGoals(_ goals: LearningGoals, for language: SupportedLanguage) async throws
    func getStatistics(for language: SupportedLanguage) async throws -> LearningStatistics
    func saveStatistics(_ statistics: LearningStatistics, for language: SupportedLanguage) async throws
    func saveSession(_ session: LearningSession) async throws
} 