# AITextView 流式 Markdown 渲染使用指南

## 概述

AITextView 现在支持基于 markdown-it 的流式 Markdown 渲染功能，可以实时显示 AI 生成的 Markdown 内容。

## 核心特性

- ✅ **流式渲染**：支持实时更新 Markdown 内容
- ✅ **语法补全**：自动处理不完整的 Markdown 语法
- ✅ **丰富功能**：支持表格、代码高亮、数学公式、emoji 等
- ✅ **模式切换**：可在普通 HTML 模式和 Markdown 模式间切换
- ✅ **性能优化**：基于 JavaScript 的 markdown-it 解析器

## 快速开始

### 1. 基本使用

```swift
import AITextView

class ViewController: UIViewController {
    @IBOutlet weak var editorView: AITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 切换到 Markdown 模式
        editorView.setupStreamMarkdown()
    }
    
    func startStreaming() {
        // 流式更新 Markdown 内容
        editorView.updateMarkdownStream("# 标题\n\n这是第一段内容", isComplete: false)
        editorView.updateMarkdownStream("\n\n## 子标题\n\n这是第二段内容", isComplete: false)
        editorView.updateMarkdownStream("\n\n**粗体文本** 和 *斜体文本*", isComplete: true)
    }
}
```

### 2. 模式切换

```swift
// 切换到 Markdown 模式
editorView.setupStreamMarkdown()

// 切换到普通 HTML 模式
editorView.switchToNormalMode()

// 检查当前模式
let isMarkdownMode = editorView.isCurrentlyStreaming
```

### 3. 流式更新

```swift
// 开始流式更新
editorView.updateMarkdownStream("开始内容...", isComplete: false)

// 继续添加内容
editorView.updateMarkdownStream("\n\n更多内容...", isComplete: false)

// 完成流式更新
editorView.updateMarkdownStream("\n\n**完成！**", isComplete: true)
```

## 支持的 Markdown 语法

### 基础语法
- 标题：`# H1` `## H2` `### H3`
- 强调：`**粗体**` `*斜体*` `***粗斜体***`
- 删除线：`~~删除文本~~`
- 内联代码：`` `代码` ``
- 链接：`[文本](URL)`
- 图片：`![alt](URL)`

### 高级语法
- 代码块：`` ```语言 `` 代码 `` ``` ``
- 表格：`| 列1 | 列2 |`
- 列表：`- 无序列表` `1. 有序列表`
- 引用：`> 引用内容`
- 水平线：`---`
- 任务列表：`- [x] 已完成` `- [ ] 未完成`

### 扩展功能
- 数学公式：`$E = mc^2$` `$$\sum_{i=1}^{n} x_i$$`
- 表情符号：`:smile:` `:heart:` `:rocket:`
- 脚注：`文本[^1]` `[^1]: 脚注内容`

## API 参考

### StreamMarkdownProcessor

```swift
public class StreamMarkdownProcessor {
    // 初始化
    public init(webView: WKWebView)
    
    // 流式更新
    public func updateMarkdownStream(_ markdown: String, isComplete: Bool = false)
    
    // 设置完整内容
    public func setMarkdown(_ markdown: String)
    
    // 重置状态
    public func reset()
    
    // 获取当前内容
    public var currentContent: String { get }
    
    // 检查是否正在流式更新
    public var isCurrentlyStreaming: Bool { get }
}
```

### AITextView 扩展

```swift
public extension AITextView {
    // 初始化流式 Markdown
    func setupStreamMarkdown()
    
    // 流式更新
    func updateMarkdownStream(_ markdown: String, isComplete: Bool = false)
    
    // 设置 Markdown 内容
    func setMarkdown(_ markdown: String)
    
    // 重置流式状态
    func resetMarkdownStream()
    
    // 切换模式
    func switchToNormalMode()
    
    // 获取当前内容
    var currentMarkdownContent: String { get }
    
    // 检查流式状态
    var isCurrentlyStreaming: Bool { get }
}
```

## 测试示例

项目包含完整的测试示例，位于 `AIStreamTestViewController.swift`：

1. **模式切换测试**：点击"切换到 Markdown 模式"按钮
2. **流式渲染测试**：点击"Markdown 流式测试"按钮
3. **功能验证**：测试各种 Markdown 语法和流式更新

## 技术实现

### 架构设计
```
AI 流式输出 → Swift 缓冲处理 → JavaScript markdown-it 解析 → HTML 渲染 → WebView 显示
```

### 核心组件
- **StreamMarkdownProcessor**：Swift 端流式处理器
- **stream_markdown_editor.html**：包含 markdown-it 的 HTML 模板
- **markdown.css**：Markdown 样式文件
- **AITextView+StreamMarkdown**：AITextView 扩展

### 流式处理逻辑
1. 接收 Markdown 内容片段
2. 处理不完整语法（自动补全）
3. 调用 JavaScript markdown-it 解析
4. 更新 WebView 显示
5. 自动滚动到底部

## 注意事项

1. **模式切换**：在 Markdown 模式和普通模式间切换会重新加载 WebView
2. **性能优化**：大量内容建议分批更新，避免阻塞主线程
3. **错误处理**：JavaScript 执行错误会在控制台输出
4. **样式定制**：可通过修改 `markdown.css` 自定义样式

## 更新日志

- **v1.0.0**：初始版本，支持基础流式 Markdown 渲染
- 支持 markdown-it 解析器
- 支持流式更新和语法补全
- 支持模式切换
- 支持丰富的 Markdown 语法
