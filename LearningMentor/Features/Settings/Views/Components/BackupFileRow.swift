import SwiftUI

struct BackupFileRow: View {
    let url: URL
    let onRestore: (URL) -> Void
    let onDelete: (URL) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(url.lastPathComponent)
                    .font(.headline)
                Text(url.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { onRestore(url) }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
            
            Button(action: { onDelete(url) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
    }
}

private extension URL {
    var formattedDate: String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let date = attributes[.modificationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
        } catch {
            print("Error getting file date: \(error)")
        }
        return "Unknown date"
    }
} 