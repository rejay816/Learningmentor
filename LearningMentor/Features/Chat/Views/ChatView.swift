import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var dynamicTextHeight: CGFloat = 44
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if let conversation = viewModel.selectedConversation {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if conversation.hasMoreMessages {
                                Button(action: {
                                    conversation.loadMoreMessages()
                                }) {
                                    if conversation.isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.8)
                                    } else {
                                        Label("加载更多消息", systemImage: "arrow.up.circle")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 14))
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.05))
                                .disabled(conversation.isLoadingMore)
                            }
                            
                            ForEach(conversation.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: conversation.messages) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue.last?.id, anchor: .bottom)
                        }
                    }
                }
            } else {
                VStack {
                    Text("选择或创建一个对话开始聊天")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            InputView(
                text: $viewModel.inputText,
                height: $dynamicTextHeight,
                isProcessing: viewModel.isProcessing,
                onSubmit: { content in
                    Task {
                        await viewModel.sendMessage(content)
                    }
                }
            )
        }
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(apiKey: "", deepSeekApiKey: ""))
} 