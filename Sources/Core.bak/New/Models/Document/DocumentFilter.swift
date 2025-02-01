import Foundation

public struct DocumentFilter {
    public let userId: String
    public let tags: [String]
    public let startDate: Date?
    public let endDate: Date?
    
    public init(userId: String, tags: [String] = [], startDate: Date? = nil, endDate: Date? = nil) {
        self.userId = userId
        self.tags = tags
        self.startDate = startDate
        self.endDate = endDate
    }
} 