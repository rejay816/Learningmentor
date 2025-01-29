import SwiftUI

struct InputView: View {
    @Binding var text: String
    @Binding var height: CGFloat
    let isProcessing: Bool
    let onSubmit: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 10) {
                GrowingTextEditor(text: $text, height: $height)
                    .frame(height: height)
                    .padding(.vertical, 8)
                
                Button(action: {
                    guard !text.isEmpty else { return }
                    onSubmit(text)
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(text.isEmpty || isProcessing)
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
        }
        .background(Color(.textBackgroundColor))
    }
}

struct GrowingTextEditor: View {
    @Binding var text: String
    @Binding var height: CGFloat
    
    var body: some View {
        NSTextViewWrapper(text: $text, calculatedHeight: $height)
            .frame(minHeight: 44)
    }
}

struct NSTextViewWrapper: NSViewRepresentable {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.textContainer?.containerSize = NSSize(
            width: textView.frame.size.width,
            height: .greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = true
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
        }
        
        recalculateHeight(textView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func recalculateHeight(_ textView: NSTextView) {
        let contentSize = textView.layoutManager?.usedRect(for: textView.textContainer!)
        let newHeight = contentSize?.height ?? 0
        
        if calculatedHeight != newHeight {
            calculatedHeight = max(44, newHeight)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NSTextViewWrapper
        
        init(_ parent: NSTextViewWrapper) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.recalculateHeight(textView)
        }
    }
}

#Preview {
    InputView(
        text: .constant("Hello"),
        height: .constant(44),
        isProcessing: false,
        onSubmit: { _ in }
    )
} 