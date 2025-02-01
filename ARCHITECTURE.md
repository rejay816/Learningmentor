# LearningMentor 架构文档

## 模块依赖关系

```
App ──────► Features ──────► Core
  │                           ▲
  └───────────────────────────┘
```

## 优化后的目录结构

```
Sources/
├── Core/                    # 核心功能模块
│   ├── Common/             # 通用功能
│   │   ├── Extensions/     # Swift 扩展
│   │   └── Utils/          # 工具类
│   │
│   ├── Domain/             # 领域模型和接口
│   │   ├── Models/         # 核心数据模型
│   │   └── Protocols/      # 核心协议定义
│   │
│   ├── Infrastructure/     # 基础设施
│   │   ├── Storage/        # 存储相关
│   │   ├── Network/        # 网络相关
│   │   └── Security/       # 安全相关
│   │
│   └── UI/                 # UI 相关
│       ├── Components/     # 可重用组件
│       ├── Theme/          # 主题管理
│       └── Localization/   # 本地化
│
├── Features/               # 功能模块
│   ├── Articles/          # 文章功能
│   │   ├── Domain/        # 领域模型
│   │   ├── Presentation/  # 视图和视图模型
│   │   └── Services/      # 功能服务
│   │
│   ├── Chat/              # 聊天功能
│   │   ├── Domain/        # 领域模型
│   │   ├── Presentation/  # 视图和视图模型
│   │   └── Services/      # 功能服务
│   │
│   └── Settings/          # 设置功能
│       ├── Domain/        # 领域模型
│       └── Presentation/  # 视图和视图模型
│
├── App/                    # 应用模块
│   ├── Composition/       # 组件组装
│   │   └── DependencyContainer.swift
│   │
│   ├── Protocols/         # 应用级协议
│   │   └── ToolbarViewModelProtocol.swift
│   │
│   ├── Navigation/        # 导航管理
│   │   ├── Models/
│   │   └── Coordinator/
│   │
│   └── Main/              # 主程序
│       ├── AppDelegate.swift
│       └── MainWindow.swift
│
└── LearningMentorApp/     # 应用入口
    └── LearningMentorApp.swift

```

## 模块职责

### Core 模块
- 提供基础设施和通用功能
- 定义核心数据模型和协议
- 不依赖其他模块

### Features 模块
- 实现具体业务功能
- 依赖 Core 模块
- 每个功能模块内部采用 Domain-Driven Design

### App 模块
- 负责应用程序组装
- 管理导航和生命周期
- 提供应用级协议
- 依赖 Core 和 Features 模块

## 依赖注入

使用依赖容器管理模块间的依赖：

```swift
class DependencyContainer {
    static let shared = DependencyContainer()
    
    // Core Services
    let storageManager: StorageManager
    let backupManager: BackupManager
    
    // Feature ViewModels
    let articleViewModel: ArticleViewModel
    let chatViewModel: ChatViewModel
    
    private init() {
        // 初始化服务和视图模型
    }
}
```

## 通信机制

1. **向下通信**：通过协议和接口
2. **向上通信**：通过回调和事件
3. **跨模块通信**：通过应用级协议

## 最佳实践

1. **依赖原则**
   - 依赖倒置：高层模块不应该依赖低层模块
   - 依赖注入：通过协议解耦模块间的依赖

2. **模块化**
   - 每个功能模块应该是自包含的
   - 通过明确的接口与其他模块通信

3. **分层设计**
   - 清晰的职责划分
   - 单向依赖关系

4. **可测试性**
   - 使用协议定义接口
   - 依赖注入便于单元测试 