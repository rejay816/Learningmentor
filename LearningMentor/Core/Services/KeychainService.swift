import Security
import Foundation

public enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidItemFormat
    case unexpectedStatus(OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "未找到密钥"
        case .duplicateItem:
            return "密钥已存在"
        case .invalidItemFormat:
            return "密钥格式无效"
        case .unexpectedStatus(let status):
            return "钥匙串操作失败: \(status)"
        }
    }
}

public class KeychainService {
    public static let shared = KeychainService()
    
    private init() {}
    
    public func saveAPIKey(_ key: String, service: String) throws {
        guard !key.isEmpty else {
            throw KeychainError.invalidItemFormat
        }
        
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try updateAPIKey(key, service: service)
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public func loadAPIKey(service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8),
              !key.isEmpty else {
            return nil
        }
        
        return key
    }
    
    public func deleteAPIKey(service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    private func updateAPIKey(_ key: String, service: String) throws {
        guard !key.isEmpty else {
            throw KeychainError.invalidItemFormat
        }
        
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
} 