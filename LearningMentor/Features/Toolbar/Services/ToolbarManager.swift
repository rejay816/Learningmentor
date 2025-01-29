import AppKit
import SwiftUI

class ToolbarManager: NSObject, NSToolbarDelegate {
    static let shared = ToolbarManager()
    private var viewModel: ChatViewModel?
    
    private override init() {
        super.init()
    }
    
    func configure(for window: NSWindow, viewModel: ChatViewModel) {
        self.viewModel = viewModel
        
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = true
        
        window.toolbar = toolbar
    }
    
    // MARK: - NSToolbarDelegate
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier("newChat"):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "新建对话")
            item.label = "新建对话"
            item.toolTip = "新建对话"
            item.target = self
            item.action = #selector(createNewChat)
            item.visibilityPriority = .high
            return item
            
        default:
            return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            NSToolbarItem.Identifier("newChat"),
            .flexibleSpace
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }
    
    // MARK: - Actions
    
    @objc private func createNewChat() {
        Task { @MainActor in
            viewModel?.createNewConversation()
        }
    }
} 