import Foundation

struct ExportRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let format: ExportFormat
    let deckName: String?  // 仅用于 Anki 导出
    let template: String?  // 仅用于 Anki 导出
    let cardCount: Int
    let success: Bool
    let errorMessage: String?
    
    init(format: ExportFormat, deckName: String? = nil, template: String? = nil, cardCount: Int, success: Bool = true, errorMessage: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.format = format
        self.deckName = deckName
        self.template = template
        self.cardCount = cardCount
        self.success = success
        self.errorMessage = errorMessage
    }
}

class ExportHistoryManager: ObservableObject {
    @Published var records: [ExportRecord] = []
    private let maxRecords = 100
    private let defaults = UserDefaults.standard
    private let recordsKey = "exportHistoryRecords"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ record: ExportRecord) {
        records.insert(record, at: 0)
        if records.count > maxRecords {
            records = Array(records.prefix(maxRecords))
        }
        saveRecords()
    }
    
    func clearHistory() {
        records.removeAll()
        saveRecords()
    }
    
    private func loadRecords() {
        if let data = defaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([ExportRecord].self, from: data) {
            records = decoded
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            defaults.set(encoded, forKey: recordsKey)
        }
    }
} 