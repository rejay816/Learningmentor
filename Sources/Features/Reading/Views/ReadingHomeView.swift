// existing code...

// 1. 如果不需要 SwiftUI 界面，直接删除全部
// 2. 若保留，则需 import SwiftUI 并解决 @EnvironmentObject / View 的依赖
// existing code...

public struct ReadingHomeView: View {
    @EnvironmentObject var viewModel: ReadingViewModel
    
    public var body: some View {
        ReadingContentView(viewModel: viewModel.documentViewModel)
    }
} 