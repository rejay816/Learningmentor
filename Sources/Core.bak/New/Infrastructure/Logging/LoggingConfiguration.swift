import Foundation

public struct LoggingConfiguration {
    public let subsystem: String
    public let category: String
    public let minimumLevel: LogLevel
    public let writeToFile: Bool
    public let maxFileSize: Int64
    public let maxFileCount: Int
    public let retentionDays: Int
    
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.learningmentor",
        category: String = "app",
        minimumLevel: LogLevel = .debug,
        writeToFile: Bool = true,
        maxFileSize: Int64 = 10 * 1024 * 1024, // 10MB
        maxFileCount: Int = 5,
        retentionDays: Int = 7
    ) {
        self.subsystem = subsystem
        self.category = category
        self.minimumLevel = minimumLevel
        self.writeToFile = writeToFile
        self.maxFileSize = maxFileSize
        self.maxFileCount = maxFileCount
        self.retentionDays = retentionDays
    }
    
    // MARK: - Factory Methods
    
    public static var `default`: LoggingConfiguration {
        LoggingConfiguration()
    }
    
    public static var debug: LoggingConfiguration {
        LoggingConfiguration(
            minimumLevel: .debug,
            writeToFile: true,
            maxFileSize: 20 * 1024 * 1024, // 20MB
            maxFileCount: 10,
            retentionDays: 14
        )
    }
    
    public static var production: LoggingConfiguration {
        LoggingConfiguration(
            minimumLevel: .info,
            writeToFile: true,
            maxFileSize: 5 * 1024 * 1024, // 5MB
            maxFileCount: 3,
            retentionDays: 3
        )
    }
    
    public static var testing: LoggingConfiguration {
        LoggingConfiguration(
            subsystem: "com.learningmentor.testing",
            category: "test",
            minimumLevel: .debug,
            writeToFile: false
        )
    }
} 