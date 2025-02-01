import SwiftUI
import Core
import Features

@main
struct LearningMentorApp: App {
    @StateObject private var viewModel = ReadingViewModel()
    @NSApplicationDelegateAdaptor(LearningMentorAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("Open...") {
                    Task {
                        do {
                            try await viewModel.handleFileOpen()
                        } catch {
                            print("Error opening file: \(error.localizedDescription)")
                        }
                    }
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Import...") {
                    Task {
                        do {
                            try await viewModel.handleFileImport()
                        } catch {
                            print("Error importing files: \(error.localizedDescription)")
                        }
                    }
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
            }
        }
    }
} 