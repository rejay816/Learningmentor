import SwiftUI

struct FilePreviewView: View {
    /// 传入的文件内容（纯文本）
    let text: String
    
    /// 文件信息
    let fileName: String
    let fileSize: String
    let fileType: String
    
    /// 点击"确定"时的回调，带回文本
    var onConfirm: (String) -> Void
    
    /// 点击"取消"时的回调
    var onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 文件信息
            Text("文件名称：\(fileName)")
            Text("文件大小：\(fileSize)")
            Text("文件类型：\(fileType)")
            
            Divider()
            
            // 文本预览
            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .padding()
            }
            .frame(minHeight: 300)
            
            // 底部按钮
            HStack {
                Spacer()
                Button("取消", action: onCancel)
                Button("确定") {
                    onConfirm(text)
                }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct FilePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        FilePreviewView(
            text: "这是示例文本的内容。",
            fileName: "example.txt",
            fileSize: "1 KB",
            fileType: "文本文件",
            onConfirm: { newText in
                print("User pressed OK, text = \(newText)")
            },
            onCancel: {
                print("User pressed Cancel.")
            }
        )
    }
}
