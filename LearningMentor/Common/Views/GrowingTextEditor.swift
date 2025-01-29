import SwiftUI
import AppKit

/// 可自动扩展高度、超过一定行数后滚动的多行输入框（macOS版）
/// 通过 layoutManager.usedRect(for:) 来计算实际内容高度
struct GrowingTextEditorView: NSViewRepresentable {
    @Binding var text: String
    @Binding var measuredHeight: CGFloat
    
    /// 设置输入框的最大高度（超过后内部滚动）
    var maxHeight: CGFloat = 200
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.isEditable = true
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.allowsUndo = true
        
        textView.font = .systemFont(ofSize: 14)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.bounds.width,
            height: .greatestFiniteMagnitude
        )
        
        textView.delegate = context.coordinator
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            recalcHeight(for: textView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// 根据 NSTextView 的内容重新计算高度
    private func recalcHeight(for textView: NSTextView) {
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
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GrowingTextEditorView
        
        init(_ parent: GrowingTextEditorView) {
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

#Preview {
    GrowingTextEditorView(text: .constant("Sample text"), measuredHeight: .constant(100))
        .frame(height: 100)
}
