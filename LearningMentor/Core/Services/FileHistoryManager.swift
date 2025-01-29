import Foundation

@MainActor
public class FileHistoryManager: ObservableObject {
    public static let shared = FileHistoryManager()
    
    @Published public private(set) var records: [FileRecord] = []
    private let storageManager = StorageManager.shared
    private let maxRecords = 100
    
    private init() {
        loadRecords()
    }
    
    public func addRecord(_ record: FileRecord) {
        records.insert(record, at: 0)
        if records.count > maxRecords {
            records.removeLast()
        }
        saveRecords()
    }
    
    public func removeRecord(_ record: FileRecord) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    public func clearHistory() {
        records.removeAll()
        saveRecords()
    }
    
    private func loadRecords() {
        do {
            records = try storageManager.load(forKey: "fileHistory")
        } catch {
            records = []
        }
    }
    
    private func saveRecords() {
        do {
            try storageManager.save(records, forKey: "fileHistory")
        } catch {
            print("Failed to save file history: \(error.localizedDescription)")
        }
    }
} 