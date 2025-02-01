import Foundation

public struct CacheConfiguration {
    public let memoryLimit: Int
    public let persistToDisk: Bool
    public let diskLimit: Int64
    public let defaultExpiration: TimeInterval?
    public let cleanupInterval: TimeInterval
    
    public init(
        memoryLimit: Int = 100,
        persistToDisk: Bool = true,
        diskLimit: Int64 = 100 * 1024 * 1024, // 100MB
        defaultExpiration: TimeInterval? = nil,
        cleanupInterval: TimeInterval = 300 // 5 minutes
    ) {
        self.memoryLimit = memoryLimit
        self.persistToDisk = persistToDisk
        self.diskLimit = diskLimit
        self.defaultExpiration = defaultExpiration
        self.cleanupInterval = cleanupInterval
    }
    
    // MARK: - Factory Methods
    
    public static var `default`: CacheConfiguration {
        CacheConfiguration()
    }
    
    public static var memoryOnly: CacheConfiguration {
        CacheConfiguration(
            memoryLimit: 50,
            persistToDisk: false
        )
    }
    
    public static var persistent: CacheConfiguration {
        CacheConfiguration(
            memoryLimit: 200,
            persistToDisk: true,
            diskLimit: 500 * 1024 * 1024, // 500MB
            defaultExpiration: 86400 // 24 hours
        )
    }
    
    public static var testing: CacheConfiguration {
        CacheConfiguration(
            memoryLimit: 10,
            persistToDisk: true,
            diskLimit: 10 * 1024 * 1024, // 10MB
            defaultExpiration: 300, // 5 minutes
            cleanupInterval: 60 // 1 minute
        )
    }
} 