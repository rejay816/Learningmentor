import AppKit
import SwiftUI
import Core

public protocol ToolbarViewModelProtocol: AnyObject {
    func createNewConversation() async
}

public final class ToolbarManager: NSObject, NSToolbarDelegate {
    public static let shared = ToolbarManager()
    private weak var viewModel: ToolbarViewModelProtocol?
    
    private override init() {
        super.init()
    }
    
    public func configure(for window: NSWindow, viewModel: ToolbarViewModelProtocol) {
        self.viewModel = viewModel
        
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = true
        
        window.toolbar = toolbar
    }
    
    // MARK: - NSToolbarDelegate
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .newChat:
            return createNewChatItem(itemIdentifier: itemIdentifier)
        default:
            return nil
        }
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            .newChat,
            .flexibleSpace
        ]
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }
    
    // MARK: - Private Methods
    
    private func createNewChatItem(itemIdentifier: NSToolbarItem.Identifier) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "新建对话")
        item.label = "新建对话"
        item.toolTip = "新建对话"
        item.target = self
        item.action = #selector(createNewChat)
        item.visibilityPriority = .high
        return item
    }
    
    @objc private func createNewChat() {
        Task { @MainActor in
            await viewModel?.createNewConversation()
        }
    }
}

// MARK: - Toolbar Item Identifiers

public extension NSToolbarItem.Identifier {
    static let newChat = NSToolbarItem.Identifier("newChat")
} 