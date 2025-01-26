import SwiftUI
import AppKit

/// 可自动扩展高度、超过一定行数后滚动的多行输入框（macOS版）
/// 通过 layoutManager.usedRect(for:) 来计算实际内容高度
struct GrowingTextEditor: NSViewRepresentable {
    @Binding var text: String
    
    /// 设置输入框的最大高度（超过后内部滚动）
    var maxHeight: CGFloat = 200
    
    // 回调当前高度，用于外部布局
    @Binding var measuredHeight: CGFloat
    
    func makeNSView(context: Context) -> NSScrollView {
        // 创建一个可滚动的 NSTextView
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.isEditable = true
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.allowsUndo = true
        
        // 让 textView 宽度跟随父容器
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.frame.size.width,
            height: .greatestFiniteMagnitude
        )
        
        // 监听文本变化
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 14)
        
        // 禁用滚动条，让超出后再内部滚动
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false
        
        // 为布局管理器设置代理
        textView.layoutManager?.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        
        // 如果外部 @Binding text 改了，就更新到 textView
        if textView.string != text {
            textView.string = text
        }
        
        // 让 textView 宽度始终与父容器匹配
        textView.textContainer?.containerSize = NSSize(
            width: nsView.contentSize.width,
            height: .greatestFiniteMagnitude
        )
        
        // 重新计算高度
        recalcHeight(for: textView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// 根据 NSTextView 的内容重新计算高度
    func recalcHeight(for textView: NSTextView) {
        guard let textContainer = textView.textContainer,
              let layoutManager = textView.layoutManager else { return }
        
        // 先让 layoutManager 做一次排版
        textContainer.containerSize = NSSize(
            width: textView.bounds.width,
            height: .greatestFiniteMagnitude
        )
        layoutManager.glyphRange(for: textContainer)
        
        // usedRect 给出文本实际占用的区域
        let usedRect = layoutManager.usedRect(for: textContainer)
        let contentHeight = usedRect.size.height
        
        // 加上一些内边距，让编辑区域留出余量
        let extraPadding: CGFloat = 8
        
        let newHeight = contentHeight + extraPadding
        DispatchQueue.main.async {
            // 限制最高高度
            self.measuredHeight = min(newHeight, self.maxHeight)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate, NSLayoutManagerDelegate {
        var parent: GrowingTextEditor
        
        init(_ parent: GrowingTextEditor) {
            self.parent = parent
        }
        
        // 当用户编辑时，更新 @Binding text
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.recalcHeight(for: textView)
        }
    }
}
