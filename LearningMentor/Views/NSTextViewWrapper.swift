import SwiftUI
import AppKit

struct NSTextViewWrapper: NSViewRepresentable {
    let text: String
    let font: NSFont
    let textColor: NSColor
    let showsVerticalScroller: Bool
    let showsHorizontalScroller: Bool
    @Binding var dynamicHeight: CGFloat
    
    init(
        text: String,
        font: NSFont = .systemFont(ofSize: NSFont.systemFontSize),
        textColor: NSColor = .textColor,
        showsVerticalScroller: Bool = false,
        showsHorizontalScroller: Bool = false,
        dynamicHeight: Binding<CGFloat> = .constant(0)
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.showsVerticalScroller = showsVerticalScroller
        self.showsHorizontalScroller = showsHorizontalScroller
        self._dynamicHeight = dynamicHeight
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.string = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.font = font
        textView.textColor = textColor
        
        scrollView.hasVerticalScroller = showsVerticalScroller
        scrollView.hasHorizontalScroller = showsHorizontalScroller
        
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = true
        
        // 监听文本高度变化
        textView.layoutManager?.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        textView.string = text
        textView.font = font
        textView.textColor = textColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSLayoutManagerDelegate {
        var parent: NSTextViewWrapper
        
        init(_ parent: NSTextViewWrapper) {
            self.parent = parent
        }
        
        func layoutManager(
            _ layoutManager: NSLayoutManager,
            didCompleteLayoutFor textContainer: NSTextContainer?,
            atEnd layoutFinishedFlag: Bool
        ) {
            guard let textView = layoutManager.textContainers.first?.textView else { return }
            // 计算文本高度
            let height = textView.intrinsicContentSize.height
            DispatchQueue.main.async {
                self.parent.dynamicHeight = height
            }
        }
    }
}

// 预览
struct NSTextViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NSTextViewWrapper(text: "这是一段测试文本")
                .frame(width: 300, height: 100)
            
            NSTextViewWrapper(
                text: "这是一段测试文本",
                font: .systemFont(ofSize: 16),
                textColor: .red
            )
            .frame(width: 300, height: 100)
            
            @State var textHeight: CGFloat = 0
            NSTextViewWrapper(
                text: "这是一段测试文本",
                dynamicHeight: $textHeight
            )
            .frame(width: 300, height: textHeight)
        }
    }
}
