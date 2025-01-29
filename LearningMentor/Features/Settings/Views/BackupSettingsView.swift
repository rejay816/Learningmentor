import SwiftUI

struct BackupSettingsView: View {
    @State private var backupFiles: [URL] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var showingBackupInfo = false
    
    // 自动备份设置
    @AppStorage("autoBackupEnabled") private var autoBackupEnabled = false
    @AppStorage("backupFrequency") private var backupFrequency = 0 // 0: 每天, 1: 每周, 2: 每月
    @AppStorage("maxBackupCount") private var maxBackupCount = 10
    
    private let frequencies = ["每天", "每周", "每月"]
    private let maxCounts = [5, 10, 20, 50]
    
    var body: some View {
        List {
            // 自动备份设置
            Section {
                Toggle("自动备份", isOn: $autoBackupEnabled)
                
                if autoBackupEnabled {
                    Picker("备份频率", selection: $backupFrequency) {
                        ForEach(0..<frequencies.count, id: \.self) { index in
                            Text(frequencies[index]).tag(index)
                        }
                    }
                    
                    Picker("保留数量", selection: $maxBackupCount) {
                        ForEach(maxCounts, id: \.self) { count in
                            Text("\(count)个").tag(count)
                        }
                    }
                }
            } header: {
                Text("备份设置")
            } footer: {
                if autoBackupEnabled {
                    Text("系统将自动保留最近\(maxBackupCount)个\(frequencies[backupFrequency])备份")
                }
            }
            
            // 手动备份
            Section {
                Button {
                    createBackup()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.blue)
                        Text("立即备份")
                    }
                }
                .disabled(isLoading)
            } footer: {
                if let lastBackup = backupFiles.first,
                   let date = try? lastBackup.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                    Text("上次备份时间：\(date.formatted(.dateTime))")
                }
            }
            
            // 备份列表
            if !backupFiles.isEmpty {
                Section("备份历史") {
                    ForEach(backupFiles, id: \.lastPathComponent) { url in
                        BackupFileRow(url: url, onRestore: restoreBackup, onDelete: deleteBackup)
                    }
                }
            }
        }
        .navigationTitle("备份管理")
        .toolbar {
            ToolbarItem {
                Button {
                    showingBackupInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .controlSize(.large)
                        .scaleEffect(1.5)
                }
            }
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "未知错误")
        }
        .sheet(isPresented: $showingBackupInfo) {
            BackupInfoView()
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
                try await Task.detached {
                    try BackupManager.shared.restoreBackup(from: url)
                }.value
                NSSound.beep()
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
                try await Task.detached {
                    try BackupManager.shared.deleteBackup(url)
                }.value
                loadBackups()
                NSSound.beep()
            } catch {
                showError(error)
            }
        }
    }
    
    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        NSSound.beep()
    }
}

struct BackupInfoView: View {
    var body: some View {
        List {
            Section("关于备份") {
                InfoRow(title: "备份内容", detail: "包括所有对话记录、设置选项和文件历史")
                InfoRow(title: "备份位置", detail: "备份文件存储在应用的文档目录中")
                InfoRow(title: "加密保护", detail: "所有备份数据都经过加密处理")
            }
            
            Section("自动备份") {
                InfoRow(title: "定时备份", detail: "系统会按照设定的频率自动创建备份")
                InfoRow(title: "空间管理", detail: "超出保留数量的旧备份会被自动清理")
            }
            
            Section("提示") {
                InfoRow(title: "手动备份", detail: "重要更改后建议手动创建备份")
                InfoRow(title: "备份恢复", detail: "恢复操作会覆盖当前数据，请谨慎操作")
            }
        }
        .navigationTitle("备份说明")
        .frame(width: 400, height: 400)
    }
}

struct InfoRow: View {
    let title: String
    let detail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        BackupSettingsView()
    }
} 