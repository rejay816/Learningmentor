import SwiftUI

struct FileHistoryView: View {
    @StateObject private var fileHistoryManager = FileHistoryManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(fileHistoryManager.records) { record in
                    FileHistoryRow(record: record)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        fileHistoryManager.removeRecord(fileHistoryManager.records[index])
                    }
                }
            }
            .navigationTitle("文件历史")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("清空") {
                        fileHistoryManager.clearHistory()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct FileHistoryRow: View {
    let record: FileRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.fileName)
                    .font(.headline)
                Spacer()
                Text(record.fileType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("大小: \(formatFileSize(record.fileSize))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("时间: \(formatDate(record.timestamp))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    FileHistoryView()
} 