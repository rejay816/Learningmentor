# LearningMentor

LearningMentor 是一个基于 SwiftUI 的 macOS 应用程序，用于学习和知识管理。

## 项目结构

```
Sources/
├── Core/                    # 核心功能模块
│   ├── Error/              # 错误处理
│   ├── Extensions/         # Swift 扩展
│   ├── Models/             # 核心数据模型
│   ├── Services/           # 核心服务
│   ├── Utils/              # 工具类
│   ├── Views/              # 通用视图组件
│   ├── Theme/              # 主题管理
│   ├── Font/               # 字体管理
│   ├── Localization/       # 本地化
│   └── Protocols/          # 协议定义
│
├── Features/               # 功能模块
│   ├── Articles/          # 文章管理功能
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── Chat/              # 聊天功能
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   └── Settings/          # 设置功能
│       ├── Models/
│       └── Views/
│
├── App/                    # 应用级别组件
│   ├── Services/          # 应用服务
│   ├── Controllers/       # 应用控制器
│   ├── Models/           # 应用级模型
│   └── Views/            # 应用级视图
│
└── LearningMentorApp/     # 应用入口
```

## 模块说明

### Core 模块

核心模块包含应用的基础功能和共享组件：

- **Models**: 核心数据模型（如 ArticleDocument）
- **Services**: 核心服务实现（如 StorageManager, BackupManager）
- **Utils**: 通用工具类
- **Views**: 可重用的 UI 组件

### Features 模块

功能模块包含应用的主要功能实现：

- **Articles**: 文章管理功能
  - 文章导入和阅读
  - PDF 文档支持
  - 文章列表管理

- **Chat**: 聊天功能
  - 对话管理
  - AI 助手集成
  - 消息历史记录

- **Settings**: 设置功能
  - 应用配置
  - 备份管理
  - 主题设置

### App 模块

应用级别的组件和配置：

- **Services**: 应用级服务（如 ToolbarManager）
- **Controllers**: 文档控制器
- **Views**: 主窗口和导航视图

## 技术栈

- SwiftUI
- Combine
- Swift Package Manager

## 开发要求

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## 构建和运行

1. 克隆仓库
2. 打开 Package.swift
3. 构建并运行项目

## 架构说明

项目采用 MVVM 架构，并遵循以下原则：

1. **模块化**: 功能按模块划分，降低耦合度
2. **依赖注入**: 使用协议和依赖注入提高可测试性
3. **单向数据流**: 使用 Combine 管理状态更新
4. **分层设计**: 清晰的层级结构和职责划分 