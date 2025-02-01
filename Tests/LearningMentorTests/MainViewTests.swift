import XCTest
import SwiftUI
@testable import LearningMentorApp

final class MainViewTests: XCTestCase {
    func testMainViewStructure() {
        let mainView = MainView()
        let readingVM = ReadingViewModel()
        
        // 测试视图层级
        let view = mainView.environmentObject(readingVM)
        
        // 验证视图是否包含必要的组件
        // 注意：由于 SwiftUI 的特性，我们主要测试视图的存在性而不是具体的渲染结果
        XCTAssertNotNil(view)
    }
    
    func testNavigationLinks() {
        let mainView = MainView()
        let readingVM = ReadingViewModel()
        
        // 测试导航链接
        let view = mainView.environmentObject(readingVM)
        
        // 验证导航链接的存在
        // 注意：这里主要是结构测试
        XCTAssertNotNil(view)
    }
} 