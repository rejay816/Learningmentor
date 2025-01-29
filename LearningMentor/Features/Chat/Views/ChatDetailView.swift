import SwiftUI

struct ChatDetailView: View {
    @ObservedObject var conversation: Conversation
    @ObservedObject var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(conversation.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: conversation.messages) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue.last?.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            VStack(spacing: 8) {
                if !conversation.customPrompt.isEmpty {
                    Text("当前提示词：\(conversation.customPrompt)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .bottom) {
                    TextEditor(text: $viewModel.inputText)
                        .font(.body)
                        .frame(height: 100)
                        .focused($isInputFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage(viewModel.inputText)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [.command])
                    .disabled(viewModel.inputText.isEmpty || viewModel.isProcessing)
                }
            }
            .padding()
        }
        .onAppear {
            isInputFocused = true
        }
    }
} 