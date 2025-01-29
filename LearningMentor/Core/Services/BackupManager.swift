import Foundation

class BackupManager {
    static let shared = BackupManager()
    private init() {}
    
    private let fileManager = FileManager.default
    private let backupExtension = "lmbackup"
    
    private var backupDirectoryURL: URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = documentsURL.appendingPathComponent("Backups", isDirectory: true)
        
        if !fileManager.fileExists(atPath: backupURL.path) {
            try? fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)
        }
        
        return backupURL
    }
    
    // 创建备份
    func createBackup() throws -> URL {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        
        let backupURL = backupDirectoryURL.appendingPathComponent("backup_\(timestamp).\(backupExtension)")
        
        // 收集需要备份的数据
        let backupData = try collectBackupData()
        
        // 写入文件
        try backupData.write(to: backupURL)
        
        return backupURL
    }
    
    // 恢复备份
    func restoreBackup(from url: URL) throws {
        guard url.pathExtension == backupExtension else {
            throw BackupError.invalidBackupFile
        }
        
        let data = try Data(contentsOf: url)
        try restoreFromData(data)
    }
    
    // 获取所有备份
    func getAllBackups() throws -> [URL] {
        let contents = try fileManager.contentsOfDirectory(
            at: backupDirectoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )
        
        return contents
            .filter { $0.pathExtension == backupExtension }
            .sorted { lhs, rhs in
                let lhsDate = try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                let rhsDate = try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                return (lhsDate ?? .distantPast) > (rhsDate ?? .distantPast)
            }
    }
    
    // 删除备份
    func deleteBackup(_ url: URL) throws {
        guard url.pathExtension == backupExtension else {
            throw BackupError.invalidBackupFile
        }
        
        try fileManager.removeItem(at: url)
    }
    
    // MARK: - Private Methods
    
    private func collectBackupData() throws -> Data {
        // 创建编码器
        let encoder = JSONEncoder()
        
        // 收集需要备份的数据
        let backup = BackupData(
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
            timestamp: Date(),
            conversations: UserDefaults.standard.data(forKey: "conversations"),
            settings: UserDefaults.standard.dictionaryRepresentation()
        )
        
        // 编码数据
        return try encoder.encode(backup)
    }
    
    private func restoreFromData(_ data: Data) throws {
        let decoder = JSONDecoder()
        let backup = try decoder.decode(BackupData.self, from: data)
        
        // 检查版本兼容性
        guard isVersionCompatible(backup.version) else {
            throw BackupError.incompatibleVersion
        }
        
        // 恢复会话数据
        if let conversations = backup.conversations {
            UserDefaults.standard.set(conversations, forKey: "conversations")
        }
        
        // 恢复设置
        for (key, value) in backup.settings {
            UserDefaults.standard.set(value, forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    private func isVersionCompatible(_ version: String) -> Bool {
        // 这里可以添加版本兼容性检查的逻辑
        return true
    }
}

// MARK: - Supporting Types

private struct BackupData: Codable {
    let version: String
    let timestamp: Date
    let conversations: Data?
    let settings: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case version, timestamp, conversations, settings
    }
    
    init(version: String, timestamp: Date, conversations: Data?, settings: [String: Any]) {
        self.version = version
        self.timestamp = timestamp
        self.conversations = conversations
        self.settings = settings
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(conversations, forKey: .conversations)
        
        // 编码设置字典
        let settingsData = try JSONSerialization.data(withJSONObject: settings)
        try container.encode(settingsData, forKey: .settings)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        conversations = try container.decodeIfPresent(Data.self, forKey: .conversations)
        
        // 解码设置字典
        let settingsData = try container.decode(Data.self, forKey: .settings)
        settings = try JSONSerialization.jsonObject(with: settingsData) as? [String: Any] ?? [:]
    }
}

enum BackupError: LocalizedError {
    case invalidBackupFile
    case incompatibleVersion
    
    var errorDescription: String? {
        switch self {
        case .invalidBackupFile:
            return "无效的备份文件"
        case .incompatibleVersion:
            return "备份文件版本不兼容"
        }
    }
} 