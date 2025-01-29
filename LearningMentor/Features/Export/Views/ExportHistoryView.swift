import SwiftUI

struct ExportHistoryView: View {
    @ObservedObject var historyManager: ExportHistoryManager
    @Environment(\.dismiss) var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("导出历史记录")
                    .font(.headline)
                
                Spacer()
                
                Button("清除历史") {
                    historyManager.clearHistory()
                }
                .disabled(historyManager.records.isEmpty)
                
                Button("关闭") {
                    dismiss()
                }
            }
            .padding(.bottom)
            
            if historyManager.records.isEmpty {
                Text("暂无导出记录")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(historyManager.records) { record in
                        ExportHistoryRow(record: record)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct ExportHistoryRow: View {
    let record: ExportRecord
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: record.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(record.success ? .green : .red)
                
                Text(dateFormatter.string(from: record.timestamp))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack {
                    Image(systemName: record.format.iconName)
                    Text(record.format.description)
                }
                .foregroundColor(.secondary)
            }
            
            if record.format == .anki {
                VStack(alignment: .leading, spacing: 4) {
                    if let deckName = record.deckName {
                        Text("牌组：\(deckName)")
                            .font(.caption)
                    }
                    if let template = record.template {
                        Text("模板：\(template)")
                            .font(.caption)
                    }
                }
            }
            
            HStack {
                Text("导出数量：\(record.cardCount)")
                    .font(.caption)
                
                if let error = record.errorMessage {
                    Text("错误：\(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 