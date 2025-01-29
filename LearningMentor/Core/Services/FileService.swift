import Foundation
import PDFKit
import AppKit

@MainActor
public class FileService {
    public static let shared = FileService()
    private let errorHandler = ErrorHandler.shared
    private let fileManager = FileManager.default
    
    private init() {}
    
    public func readFileContent(fileURL: URL) throws -> String {
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw AppError.fileError("无法访问文件权限")
        }
        
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        let ext = fileURL.pathExtension.lowercased()
        switch ext {
        case "txt", "md":
            return try String(contentsOf: fileURL, encoding: .utf8)
        case "pdf":
            return try readPDFContent(fileURL: fileURL)
        case "doc", "docx":
            return try readWordContent(fileURL: fileURL, ext: ext)
        default:
            throw AppError.fileError("不支持的文件格式: \(ext)")
        }
    }
    
    private func readPDFContent(fileURL: URL) throws -> String {
        guard let pdf = PDFDocument(url: fileURL) else {
            throw AppError.fileError("PDF读取失败")
        }
        
        var content = ""
        for pageIndex in 0..<pdf.pageCount {
            if let page = pdf.page(at: pageIndex),
               let pageContent = page.string {
                content += pageContent
                if pageIndex < pdf.pageCount - 1 {
                    content += "\n"
                }
            }
        }
        
        if content.isEmpty {
            throw AppError.fileError("PDF内容为空")
        }
        
        return content
    }
    
    private func readWordContent(fileURL: URL, ext: String) throws -> String {
        let docType: NSAttributedString.DocumentType = ext == "doc" ? .docFormat : .officeOpenXML
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: docType]
        
        do {
            let attr = try NSAttributedString(url: fileURL, options: options, documentAttributes: nil)
            let content = attr.string
            
            if content.isEmpty {
                throw AppError.fileError("Word文档内容为空")
            }
            
            return content
        } catch {
            throw AppError.fileError("Word文档读取失败: \(error.localizedDescription)")
        }
    }
    
    public func exportConversation(_ messages: [ChatMessage], format: ExportFormat) throws -> URL {
        // 创建导出目录
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let exportDirURL = documentsURL.appendingPathComponent("LearningMentor导出", isDirectory: true)
        try? fileManager.createDirectory(at: exportDirURL, withIntermediateDirectories: true)
        
        // 创建文件名
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "对话记录_\(timestamp).\(format.fileExtension)"
        let fileURL = exportDirURL.appendingPathComponent(fileName)
        
        // 写入内容
        let content = format.formatContent(messages)
        try content.data(using: .utf8)?.write(to: fileURL, options: .atomic)
        
        // 在 Finder 中显示
        NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: exportDirURL.path)
        
        return fileURL
    }
    
    func showInFinder(_ url: URL) {
        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }
} 