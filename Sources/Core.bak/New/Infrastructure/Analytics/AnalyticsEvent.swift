import Foundation

public struct AnalyticsEvent: Codable {
    public let name: String
    public let timestamp: Date
    
    private let _parameters: [String: String]
    
    public var parameters: [String: Any]? {
        return _parameters
    }
    
    public init(name: String, parameters: [String: Any]?, timestamp: Date = Date()) {
        self.name = name
        self.timestamp = timestamp
        self._parameters = parameters?.compactMapValues { "\($0)" } ?? [:]
    }
} 