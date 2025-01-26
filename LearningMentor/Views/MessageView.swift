import SwiftUI
import NaturalLanguage

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
    let message: LMChatMessage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                // AI 头像
                Image(systemName: "brain")
                    .foregroundColor(colorScheme == .dark ? .gray : .gray.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // AI 消息靠左
                TypewriterText(text: message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .textSelection(.enabled)
                
                Spacer()
            } else {
                // 用户消息靠右
                Spacer()
                
                Text(message.content)
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .textSelection(.enabled)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .id(message.id)
        // 用户消息保留缩放动画，AI消息移除动画（由打字机效果替代）
        .transition(.asymmetric(
            insertion: message.isUser 
                ? .scale(scale: 0.95).combined(with: .opacity).animation(.spring(response: 0.15))
                : .opacity.animation(.easeIn(duration: 0.1)),
            removal: .opacity
        ))
    }
}

// 预览
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageView(message: LMChatMessage(content: "Hello! How can I help you?", isUser: false))
            MessageView(message: LMChatMessage(content: "I need help with **Markdown** formatting", isUser: true))
        }
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
