import Foundation

public struct User: Identifiable, Codable {
    public let id: UUID
    public let email: String
    public let name: String
    public var preferences: UserPreferences
    
    public init(id: UUID = UUID(), email: String, name: String, preferences: UserPreferences = .default) {
        self.id = id
        self.email = email
        self.name = name
        self.preferences = preferences
    }
} 