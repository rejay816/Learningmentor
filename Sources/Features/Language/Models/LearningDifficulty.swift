public struct LearningDifficulty {
    public let level: Level
    public let factors: [DifficultyFactor]
    
    public enum Level: String {
        case beginner = "A1"
        case elementary = "A2"
        case intermediate = "B1"
        case upperIntermediate = "B2"
        case advanced = "C1"
        case mastery = "C2"
    }
    
    public struct DifficultyFactor {
        public let type: FactorType
        public let score: Double
        public let description: String
        
        public enum FactorType {
            case vocabulary
            case grammar
            case sentenceStructure
            case contextualComplexity
        }
        
        public init(type: FactorType, score: Double, description: String) {
            self.type = type
            self.score = score
            self.description = description
        }
    }
    
    public init(level: Level, factors: [DifficultyFactor]) {
        self.level = level
        self.factors = factors
    }
} 