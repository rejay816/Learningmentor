import Foundation

public protocol StorageManaging {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T
    func remove(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

public enum StorageError: Error, LocalizedError {
    case dataNotFound
    case encodingFailed
    case decodingFailed
    case saveFailed
    case removeFailed
    
    public var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "数据不存在"
        case .encodingFailed:
            return "数据编码失败"
        case .decodingFailed:
            return "数据解码失败"
        case .saveFailed:
            return "数据保存失败"
        case .removeFailed:
            return "数据删除失败"
        }
    }
}

public class StorageManager: StorageManaging {
    public static let shared = StorageManager()
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
            if !userDefaults.synchronize() {
                throw StorageError.saveFailed
            }
        } catch {
            throw StorageError.encodingFailed
        }
    }
    
    public func load<T: Decodable>(forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw StorageError.dataNotFound
        }
        
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            throw StorageError.decodingFailed
        }
    }
    
    public func remove(forKey key: String) throws {
        userDefaults.removeObject(forKey: key)
        if !userDefaults.synchronize() {
            throw StorageError.removeFailed
        }
    }
    
    public func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
    
    public func clearAll() throws {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        if !userDefaults.synchronize() {
            throw StorageError.removeFailed
        }
    }
} 