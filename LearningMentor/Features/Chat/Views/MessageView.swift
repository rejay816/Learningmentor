import SwiftUI
import NaturalLanguage
import AppKit

struct TypewriterText: View {
    let text: String
    @State private var displayedText: String = ""
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Text(displayedText)
            .font(.system(size: 14))
            .onAppear {
                if !isAnimating {
                    isAnimating = true
                    displayedText = ""
                    for (index, character) in text.enumerated() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {
                            displayedText += String(character)
                        }
                    }
                }
            }
    }
}

struct MessageView: View {
    let message: ChatMessage
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.isUser ? "用户" : "助手")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.content)
                    .textSelection(.enabled)
                    .padding(12)
                    .background(message.isUser ? Color.blue.opacity(0.1) : (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: NSScreen.main?.frame.width ?? 1000 * 0.7, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        MessageView(message: ChatMessage(content: "Hello", isUser: true))
        MessageView(message: ChatMessage(content: "Hi there!", isUser: false))
    }
}

func smartSplitText(_ text: String) -> [String] {
    var sentences: [String] = []
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
        let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        if !sentence.isEmpty {
            sentences.append(sentence)
        }
        return true
    }
    return sentences
}

// remove or comment out the function analyzeLongTextBySentence:
// (assuming we have moved it to a ViewModel and won't call it directly in the View)
/// func analyzeLongTextBySentence(_ fullText: String) async {
///     guard let selectedConvIndex = conversations.firstIndex(where: { $0.id == selectedConversation?.id }) else {
///         return
///     }
///     
///     // 使用智能分句函数
///     let sentences = smartSplitText(fullText)
///     
///     for sentence in sentences {
///         let prompt = makeSingleLinePrompt(for: sentence)
///         
///         do {
///             let gptReply = try await openAIService.analyze(text: sentence, prompt: prompt)
///             
///             let newMsg = LMChatMessage(content: gptReply, isUser: false)
///             conversations[selectedConvIndex].messages.append(newMsg)
///             
///             selectedConversation = conversations[selectedConvIndex]
///             
///             try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5秒
///             
///         } catch {
///             let errMsg = "分析失败(\(sentence.prefix(15))...): \(error.localizedDescription)"
///             let errorMessage = LMChatMessage(content: errMsg, isUser: false)
///             conversations[selectedConvIndex].messages.append(errorMessage)
///         }
///     }
/// }

private func makeSingleLinePrompt(for sentence: String) -> String {
    return """
你是一位资深法语教师，专门从事法语教学和语言点分析。你需要帮助学生逐句分析法语文本，突出重点词汇和语法结构。

分析要求：
1. 只关注当前这一句，不要考虑上下文。分析完当前句后，再分析下一句。直到分析完所有句子。
2. 翻译要准确、地道，符合中英文表达习惯
3. Note部分重点解释：
   - A1-B2 水平的重要词汇、短语
   - 句子的语法结构解释（阴阳性、时态、数、格、人称、语气等）
   - 常见搭配和表达方式解释

待分析句子：\(sentence)

请严格按照以下格式输出（注意保持格式的一致性，包括换行和缩进）：

【法语表达】：
\(sentence)

【翻译】：
(准确、地道的中文翻译)

【Note】：
(用短横线列表的形式说明：
- 当前句子中重要词汇解释
- 语法结构分析
- 常用搭配说明)

注意事项：
1. 严格按照上述三个部分输出，不要添加其他内容
2. 每个部分之间要空一行
3. Note部分使用短横线列表，每点一行
4. 不要对句子内容做评价或补充说明
5. 不要在输出中包含任何多余的标点符号
6. 确保 Note 中的解释适合 A1-B2 水平的学习者
"""
}
