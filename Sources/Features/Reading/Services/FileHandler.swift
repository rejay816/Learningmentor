import Foundation
import AppKit
import UniformTypeIdentifiers

@MainActor
public final class FileHandler {
    // MARK: - Properties
    
    public static let shared = FileHandler()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    public func openFile() async throws -> URL {
        let panel = await NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.pdf, .plainText, .rtf]
        
        guard await panel.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) == .OK,
              let url = await panel.url else {
            throw FileHandlerError.userCancelled
        }
        
        return url
    }
    
    public func importFiles() async throws -> [URL] {
        let panel = await NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.pdf, .plainText, .rtf]
        
        guard await panel.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) == .OK,
              !(await panel.urls).isEmpty else {
            throw FileHandlerError.userCancelled
        }
        
        return await panel.urls
    }
}

// MARK: - Error Handling

public enum FileHandlerError: LocalizedError {
    case userCancelled
    case invalidFile
    case accessDenied
    case unsupportedFileType
    
    public var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Operation cancelled by user"
        case .invalidFile:
            return "The selected file is invalid"
        case .accessDenied:
            return "Access to the file was denied"
        case .unsupportedFileType:
            return "The file type is not supported"
        }
    }
} 