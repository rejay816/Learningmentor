import SwiftUI

struct BackupTestView: View {
    @State private var backupFiles: [URL] = []
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        List {
            Section {
                Button("创建备份") {
                    createBackup()
                }
                .disabled(isLoading)
            }
            
            Section("备份文件") {
                if isLoading {
                    ProgressView()
                } else if backupFiles.isEmpty {
                    Text("暂无备份")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(backupFiles, id: \.lastPathComponent) { url in
                        BackupFileRow(url: url, onRestore: restoreBackup, onDelete: deleteBackup)
                    }
                }
            }
        }
        .navigationTitle("备份测试")
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "未知错误")
        }
        .onAppear {
            loadBackups()
        }
    }
    
    private func loadBackups() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                backupFiles = try BackupManager.shared.getAllBackups()
            } catch {
                showError(error)
            }
        }
    }
    
    private func createBackup() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                _ = try BackupManager.shared.createBackup()
                loadBackups()
            } catch {
                showError(error)
            }
        }
    }
    
    private func restoreBackup(_ url: URL) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try BackupManager.shared.restoreBackup(from: url)
            } catch {
                showError(error)
            }
        }
    }
    
    private func deleteBackup(_ url: URL) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try BackupManager.shared.deleteBackup(url)
                loadBackups()
            } catch {
                showError(error)
            }
        }
    }
    
    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

#Preview {
    NavigationView {
        BackupTestView()
    }
} 