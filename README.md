# AITextView - 强大的iOS富文本编辑器与AI输出组件

> 一个功能完整的iOS富文本编辑器框架，支持UIKit和SwiftUI，同时可作为AI流式输出的完美展示组件

[![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)](https://github.com/youyinian288/AITextView)
[![Platform](https://img.shields.io/badge/platform-iOS%2012.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.7+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-BSD%203--clause-green.svg)](LICENSE.md)

## 📋 目录

- [功能演示](#-功能演示)
- [项目简介](#-项目简介)
  - [双UI框架支持](#-双ui框架支持)
  - [AI内容生成载体](#-ai内容生成载体)
- [核心特性](#️-核心特性)
- [双重用途](#-双重用途)
- [项目架构](#-项目架构)
- [快速开始](#-快速开始)
- [使用示例](#-使用示例)
- [AI集成指南](#-ai集成指南)
- [性能分析](#-性能分析)
- [安装方式](#-安装方式)
- [API 文档](#-api-文档)
- [贡献指南](#-贡献指南)
- [许可证](#-许可证)

## 🎥 功能演示

### 富文本编辑功能
![富文本编辑功能演示](docs/富文本.gif)

### AI输出功能演示
![AI输出功能演示](docs/AI生成.gif)

## 🎯 项目简介

AITextView 是一个专为iOS应用设计的强大富文本编辑器框架，基于WebKit技术构建，提供了完整的富文本编辑功能。该框架采用混合架构设计，既保持了Web技术的强大编辑能力，又确保了原生iOS应用的性能和用户体验。

### 🎨 双UI框架支持
- **UIKit集成**: 提供完整的UIKit组件，无缝集成到传统iOS项目中
- **SwiftUI支持**: 原生SwiftUI组件，完美适配现代iOS开发架构
- **统一API**: 两套UI框架共享相同的核心功能，确保开发体验一致性

### 🤖 AI内容生成载体
- **流式输出**: 专为AI内容生成优化，支持实时流式文本输出
- **格式保持**: AI生成的内容自动保持富文本格式，支持代码高亮、列表等
### 主要优势

- 🚀 **高性能**: 基于WebKit，支持大量文本和复杂格式
- 🎨 **功能丰富**: 支持所有主流富文本格式和编辑操作
- 🔄 **双框架支持**: 同时支持UIKit和SwiftUI
- 📱 **原生体验**: 完美集成iOS键盘和系统功能
- 🛠️ **高度可定制**: 灵活的配置选项和扩展能力
- 🌙 **暗黑模式**: 完整支持iOS暗黑模式
- 🤖 **AI友好**: 完美适配AI流式输出场景

## 🛠️ 核心特性

### 文本格式化
- ✅ **基础格式**: 粗体、斜体、下划线、删除线
- ✅ **文本样式**: 字体大小、颜色、背景色
- ✅ **文本对齐**: 左对齐、居中、右对齐、两端对齐
- ✅ **缩进控制**: 增加/减少缩进

### 结构化内容
- ✅ **标题级别**: H1-H6 六级标题
- ✅ **列表支持**: 有序列表、无序列表、嵌套列表
- ✅ **引用块**: 支持引用格式
- ✅ **代码块**: 内联代码和代码块

### 媒体支持
- ✅ **图片插入**: 支持相册选择和拍照
- ✅ **链接插入**: 自动识别和格式化链接
- ✅ **表格支持**: 创建和编辑表格

### 编辑功能
- ✅ **撤销/重做**: 完整的操作历史管理
- ✅ **复制/粘贴**: 支持富文本格式保持
- ✅ **全选/清除**: 快速选择操作
- ✅ **自适应高度**: 根据内容自动调整高度

### 用户体验
- ✅ **键盘工具栏**: 自定义键盘上方工具栏
- ✅ **焦点管理**: 智能焦点切换和保持
- ✅ **滚动优化**: 平滑的滚动体验
- ✅ **触摸优化**: 响应式触摸交互

## 🎭 双重用途

### 1. 富文本编辑器
AITextView 可以作为功能完整的富文本编辑器使用，支持：
- 所见即所得编辑
- 丰富的格式化选项
- 媒体内容插入
- 实时预览

### 2. AI输出组件
AITextView 特别适合作为AI应用的输出展示组件：
- **流式输出支持**: 实时显示AI生成的内容
- **HTML格式渲染**: 完美支持AI返回的HTML格式内容
- **富文本展示**: 支持AI生成的各种格式（标题、列表、代码块等）
- **只读模式**: 可设置为只读模式，专门用于内容展示
- **动态更新**: 支持内容的动态追加和更新

## 🏗️ 项目架构

### 架构层次说明

#### 1. **用户接口层**
- 支持 **UIKit** 和 **SwiftUI** 两种使用方式
- 提供灵活的集成选择

#### 2. **SwiftUI包装层**
- `SwiftUIAITextView`: SwiftUI版本的编辑器包装器
- `SwiftUIAITextToolbar`: SwiftUI版本的工具栏包装器  
- `AITextViewState`: 用于状态管理的ObservableObject

#### 3. **UIKit核心层**
- `AITextView`: 核心编辑器组件，继承自UIView
- `AITextToolbar`: 可滚动的工具栏，包含各种编辑操作按钮
- `AITextWebView`: WKWebView的简单包装器

#### 4. **前端实现层**
- `rich_editor.html`: 基础HTML结构，包含可编辑的div
- `rich_editor.js`: JavaScript逻辑，实现所有富文本编辑功能
- `style.css + normalize.css`: 样式定义和浏览器兼容性

### 🔄 关键工作原理

#### JavaScript-Native通信机制
1. **Swift → JavaScript**: 通过`webView.evaluateJavaScript()`调用JS函数
2. **JavaScript → Swift**: 通过回调URL (`re-callback://`) 触发Swift代理方法
3. **命令队列**: JS将多个操作打包成JSON命令队列，Swift批量处理

#### 代理模式
- `AITextViewDelegate`: 处理编辑器事件（内容变化、焦点变化、高度变化）
- `AITextToolbarDelegate`: 处理需要原生UI的操作（颜色选择、图片插入）

## 🚀 快速开始

### 系统要求

- iOS 12.0+
- Swift 5.7+
- Xcode 14.0+

### 安装方式

#### Swift Package Manager (推荐)

1. 在Xcode中选择 `File` → `Add Package Dependencies`
2. 输入仓库URL: `https://github.com/youyinian288/AITextView.git`
3. 选择版本并添加到项目

#### CocoaPods

```ruby
pod 'AITextView', '~> 4.3.0'
```

#### 手动安装

1. 下载项目源码
2. 将 `AITextView/Sources` 文件夹拖入项目
3. 确保添加了所有资源文件

## 📱 使用示例

### UIKit 使用方式

```swift
import UIKit
import AITextView

class ViewController: UIViewController {
    @IBOutlet var editorView: AITextView!
    @IBOutlet var toolbar: AITextToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置编辑器
        editorView.delegate = self
        editorView.placeholder = "请输入内容..."
        editorView.html = "<p>Hello <b>World</b>!</p>"
        
        // 设置工具栏
        toolbar.editor = editorView
        toolbar.options = AITextDefaultOption.all
    }
}

extension ViewController: AITextViewDelegate {
    func aiTextView(_ editor: AITextView, contentDidChange content: String) {
        print("内容变化: \(content)")
    }
    
    func aiTextView(_ editor: AITextView, heightDidChange height: Int) {
        print("高度变化: \(height)")
    }
}
```

### SwiftUI 使用方式

```swift
import SwiftUI
import AITextView

struct ContentView: View {
    @StateObject private var editorState = AITextViewState(
        htmlContent: "<p>Hello <b>World</b>!</p>",
        placeholder: "请输入内容..."
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // 编辑器
            SwiftUIAITextView(
                state: editorState,
                onContentChange: { content in
                    print("内容变化: \(content)")
                },
                onHeightChange: { height in
                    print("高度变化: \(height)")
                }
            )
            .frame(minHeight: 200)
            
            // 工具栏
            SwiftUIAITextToolbar(
                state: editorState,
                options: AITextDefaultOption.all
            )
            .frame(height: 44)
            
            // HTML预览
            ScrollView {
                Text(editorState.htmlContent)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .background(Color(.systemGray6))
        }
    }
}
```

### 自定义工具栏选项

```swift
// 创建自定义工具栏选项
let customOptions: [AITextOption] = [
    AITextDefaultOption.bold,
    AITextDefaultOption.italic,
    AITextDefaultOption.underline,
    AITextDefaultOption.strikeThrough,
    AITextDefaultOption.undo,
    AITextDefaultOption.redo
]

toolbar.options = customOptions
```

### 处理图片插入

```swift
extension ViewController: AITextToolbarDelegate {
    func aiTextToolbar(_ toolbar: AITextToolbar, shouldInsertImage image: UIImage) {
        // 处理图片插入逻辑
        let imageData = image.jpegData(compressionQuality: 0.8)
        let base64String = imageData?.base64EncodedString() ?? ""
        let html = "<img src='data:image/jpeg;base64,\(base64String)' />"
        
        editorView.insertHTML(html)
    }
}
```

## 🤖 AI集成指南

### 作为AI输出组件使用

AITextView 特别适合作为AI应用的输出展示组件，支持流式输出和富文本渲染：

#### 1. 基础AI输出设置

```swift
class AIViewController: UIViewController {
    @IBOutlet var aiOutputView: AITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置为只读模式，专门用于AI输出展示
        aiOutputView.editingEnabled = false
        aiOutputView.placeholder = "AI正在思考中..."
        
        // 设置初始内容
        aiOutputView.html = "<h2>🤖 AI助手</h2><p>请提出您的问题...</p>"
    }
}
```

#### 2. 流式输出实现

```swift
import SwiftOpenAI

class AIStreamController: UIViewController {
    private var aiOutputView: AITextView!
    private var currentMessage: String = ""
    
    private func startAIStream(prompt: String) {
        // 清空之前的内容
        currentMessage = ""
        aiOutputView.html = "<h3>💬 AI回复</h3><p>正在生成回复...</p>"
        
        // 创建OpenAI服务
        let service = OpenAIServiceFactory.service(
            apiKey: "your-api-key",
            overrideBaseURL: "https://api.deepseek.com"
        )
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text("请用HTML格式返回富文本内容，问题：" + prompt))],
            model: .custom("deepseek-chat")
        )
        
        Task {
            do {
                let stream = try await service.startStreamedChat(parameters: parameters)
                
                for try await result in stream {
                    await MainActor.run {
                        let content = result.choices?.first?.delta?.content ?? ""
                        self.currentMessage += content
                        
                        // 实时更新显示
                        self.updateAIOutput()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateAIOutput() {
        let htmlContent = """
        <div style="background-color: #f8f9fa; border-left: 4px solid #28a745; padding: 12px; margin: 8px 0; border-radius: 4px;">
            <h4 style="color: #28a745; margin: 0 0 8px 0;">💬 AI回复</h4>
            <div style="margin: 0; color: #333; line-height: 1.6;">\(currentMessage)</div>
        </div>
        """
        
        aiOutputView.html = htmlContent
    }
}
```

#### 3. SwiftUI AI输出组件

```swift
struct AIOutputView: View {
    @StateObject private var aiState = AITextViewState(
        htmlContent: "<h2>🤖 AI助手</h2>",
        placeholder: "AI正在思考中..."
    )
    
    var body: some View {
        SwiftUIAITextView(
            state: aiState,
            editingEnabled: false, // 只读模式
            onContentChange: { content in
                // 处理内容变化
            }
        )
        .frame(minHeight: 300)
        .background(Color(.systemBackground))
    }
    
    func updateAIResponse(_ response: String) {
        aiState.htmlContent = """
        <div style="padding: 16px; background-color: #f8f9fa; border-radius: 8px;">
            <h3 style="color: #28a745;">🤖 AI回复</h3>
            <div style="margin-top: 12px; line-height: 1.6;">\(response)</div>
        </div>
        """
    }
}
```

### 支持的AI服务

AITextView 可以与多种AI服务集成：

- ✅ **OpenAI GPT系列**
- ✅ **DeepSeek**
- ✅ **Claude (通过OpenRouter)**
- ✅ **Gemini**
- ✅ **本地模型 (Ollama)**
- ✅ **其他兼容OpenAI API的服务**



## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

### 开发环境设置

1. 克隆仓库
2. 打开 `AITextView.xcodeproj`
3. 选择目标设备或模拟器
4. 运行项目

## 📄 许可证

本项目采用 BSD 3-Clause 许可证 - 查看 [LICENSE.md](LICENSE.md) 文件了解详情。

## 🙏 致谢

- 感谢所有贡献者的努力
- 基于 [RichEditorView](https://github.com/T-Pro/AITextView) 项目进行改进
- 感谢开源社区的支持
- 特别感谢 [SwiftOpenAI](https://github.com/youyinian288/SwiftOpenAI) 项目提供的AI集成支持

## 📞 联系方式

- 项目主页: [https://github.com/youyinian288/AITextView](https://github.com/youyinian288/AITextView)
- 问题反馈: [Issues](https://github.com/youyinian288/AITextView/issues)
- 讨论区: [Discussions](https://github.com/youyinian288/AITextView/discussions)

---

**AITextView** - 让富文本编辑和AI输出变得简单而强大！ 🚀

## 🎯 使用场景

### 富文本编辑器场景
- 📝 笔记应用
- 📰 内容管理系统
- 📧 邮件编辑器
- 📄 文档编辑器
- 💬 聊天应用（富文本消息）

### AI输出组件场景
- 🤖 AI聊天应用
- 📊 AI内容生成工具
- 🎓 AI教育应用
- 💡 AI写作助手
- 🔍 AI搜索结果显示

选择 AITextView，为您的iOS应用提供强大的富文本编辑和AI输出能力！