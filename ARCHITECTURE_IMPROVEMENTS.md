# AITextView 架构改进建议

> 本文档分析当前架构的问题，并提出具体的改进方案

## 📊 当前架构评估

### ✅ 优势
- **混合架构设计**：有效结合 Swift 和 Web 技术
- **流式渲染支持**：适合 AI 实时输出场景
- **组件化设计**：JavaScript 端组件系统清晰

### ⚠️ 主要问题

## 🔴 1. 性能问题（高优先级）

### 1.1 完整重新渲染问题

**当前实现**：
```408:408:AITextView/Sources/Resources/stream_markdown_editor.js
    container.innerHTML = ''
```

**问题**：
- 每次流式更新都**清空整个 DOM 并重新渲染**
- 对于长文档（如 10KB+ Markdown），每次更新都要：
  - 解析整个 Markdown
  - 生成完整 AST
  - 创建所有 DOM 节点
  - 触发多次重排和重绘
- **性能影响**：随着内容增长，渲染时间呈线性甚至指数增长

**改进方案**：

#### 方案 A：增量渲染（推荐）✅ 已实现

**实现状态**：已在 `stream_markdown_editor.js` 中实现增量渲染功能

```javascript
// 只渲染新增的节点
renderIncremental(newAST, container) {
    const oldAST = this.lastRenderedAST || [];
    const diff = this.astDiff(oldAST, newAST);

    // 优化：如果是纯追加场景（只有新增节点，没有修改和删除），快速处理
    if (diff.added.length > 0 && diff.modified.length === 0 && diff.removed.length === 0) {
        // 直接追加新节点，无需复杂的DOM操作
        diff.added.forEach(({ node, index }) => {
            const element = this.renderNode(node, container);
            this.astToDOM.set(index, element);
        });
        this.lastRenderedAST = newAST;
        return;
    }

    // 完整更新路径：处理删除、修改和新增
    // ... 其他逻辑
}
```

**优势**：
- ✅ 已实现：纯追加场景下性能最优（O(n) 而非 O(n²)）
- ✅ 支持增量更新：只更新变化的节点
- ✅ 保持 DOM 引用：使用 Map 维护 AST 索引到 DOM 的映射
- ⚠️ 待优化：完整的 diff 算法可以进一步优化（使用更高效的树对比算法）

#### 方案 B：虚拟滚动 + 节流
```javascript
updateMarkdown(newContent, isComplete) {
    // 累积内容但不立即渲染
    this.currentContent += newContent;
    
    // 节流：最多每 100ms 渲染一次
    if (this.renderTimer) {
        clearTimeout(this.renderTimer);
    }
    
    this.renderTimer = setTimeout(() => {
        this.renderContent();
    }, 100);
    
    if (isComplete) {
        clearTimeout(this.renderTimer);
        this.renderContent();
    }
}
```

### 1.2 字符串转义效率问题

**当前实现**：
```195:201:AITextView/Sources/AITextView.swift
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
```

**问题**：
- 多次字符串遍历，效率低
- 每次更新都要转义，CPU 浪费

**改进方案**：
```swift
private func escapeJavaScriptString(_ string: String) -> String {
    // 使用单次遍历 + String 构建器
    var result = ""
    result.reserveCapacity(string.count * 2) // 预分配空间
    
    for char in string {
        switch char {
        case "\\": result += "\\\\"
        case "'": result += "\\'"
        case "\"": result += "\\\""
        case "\n": result += "\\n"
        case "\r": result += "\\r"
        case "\t": result += "\\t"
        default: result.append(char)
        }
    }
    return result
}

// ✅ 已实现：使用 JSONEncoder（更安全，正确处理所有 Unicode 字符）
private func escapeJavaScriptString(_ string: String) -> String {
    // 使用 JSONEncoder 编码字符串
    struct StringArray: Codable {
        let value: String
    }
    
    let wrapper = StringArray(value: string)
    let jsonEncoder = JSONEncoder()
    
    guard let jsonData = try? jsonEncoder.encode(wrapper),
          let jsonString = String(data: jsonData, encoding: .utf8) else {
        // 如果编码失败，使用 JSONSerialization 作为备用方案
        return escapeJavaScriptStringWithJSONSerialization(string)
    }
    
    // 提取 value 字段的值部分（去掉首尾的双引号）
    // 格式: {"value":"escaped_content"}
    if let prefixRange = jsonString.range(of: "\"value\":\""),
       prefixRange.upperBound < jsonString.endIndex {
        let valueStartIndex = prefixRange.upperBound
        // 从 valueStartIndex 开始查找第一个未转义的双引号
        var searchIndex = valueStartIndex
        var escaped = false
        var foundEnd = false
        
        while searchIndex < jsonString.endIndex {
            let char = jsonString[searchIndex]
            if escaped {
                escaped = false
            } else if char == "\\" {
                escaped = true
            } else if char == "\"" {
                foundEnd = true
                break
            }
            searchIndex = jsonString.index(after: searchIndex)
        }
        
        if foundEnd && searchIndex > valueStartIndex {
            let escapedValue = String(jsonString[valueStartIndex..<searchIndex])
            return escapedValue
        }
    }
    
    // 如果解析失败，使用备用方案
    return escapeJavaScriptStringWithJSONSerialization(string)
}
```

**优势**：
- ✅ 正确处理所有 Unicode 字符（包括 emoji、特殊符号）
- ✅ 正确处理 Base64 图片 URL 中的特殊字符（`;`, `:`, `,` 等）
- ✅ 类型安全：使用 Codable 协议
- ✅ 有备用方案：JSONSerialization 作为降级策略

### 1.3 频繁的 JavaScript 桥接调用

**当前问题**：
- 每个流式片段都调用 `evaluateJavaScript`
- Swift → JS → Swift 往返延迟
- 没有批量处理机制

**改进方案**：消息队列 + 批量处理
```swift
class AITextView: UIView {
    private var pendingUpdates: [String] = []
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 0.05 // 50ms
    
    func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
        markdownBuffer += markdown
        
        if isComplete {
            // 立即处理最后一批
            flushUpdates(isComplete: true)
        } else {
            // 加入队列
            pendingUpdates.append(markdown)
            
            // 启动定时器（如果还没启动）
            if updateTimer == nil {
                updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
                    self?.flushUpdates(isComplete: false)
                }
            }
        }
    }
    
    private func flushUpdates(isComplete: Bool) {
        guard !pendingUpdates.isEmpty else { return }
        
        let combined = pendingUpdates.joined()
        pendingUpdates.removeAll()
        
        // 批量发送到 JS
        let jsCode = """
        RE.streamMarkdownProcessor.updateMarkdown('\(escapeJavaScriptString(combined))', \(isComplete));
        """
        runJS(jsCode)
        
        if isComplete {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
}
```

## 🔴 2. 架构设计问题

### 2.1 CDN 依赖问题

**当前实现**：
```12:16:AITextView/Sources/Resources/stream_markdown_editor.html
    <script src="https://cdn.jsdelivr.net/npm/markdown-it@14.0.0/dist/markdown-it.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it-emoji@2.2.0/dist/markdown-it-emoji.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it-code-copy@0.0.6/dist/markdown-it-code-copy.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it-katex@0.6.0/dist/markdown-it-katex.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markdown-it-table@0.1.0/dist/markdown-it-table.min.js"></script>
```

**问题**：
- 需要网络连接，离线不可用
- CDN 失败时功能不可用
- 加载时间不确定

**改进方案**：本地化依赖
```
1. 将 CDN 资源下载到本地 Resources/
2. 打包到 framework 中
3. 提供降级策略（SimpleMarkdownParser）
```

### 2.2 通信机制过于原始

**当前实现**：
- URL Scheme 回调：`ai-callback://`
- JSON 字符串解析
- 字符串命令模式

**问题**：
- 类型不安全
- 难以调试
- 扩展性差

**改进方案**：使用 WKScriptMessageHandler
```swift
// Swift 端
class AITextView: UIView, WKScriptMessageHandler {
    func setupMessageHandler() {
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "aiTextView")
    }
    
    func userContentController(_ userContentController: WKUserContentController, 
                               didReceive message: WKScriptMessage) {
        guard message.name == "aiTextView",
              let body = message.body as? [String: Any] else { return }
        
        // 类型安全的消息处理
        switch body["type"] as? String {
        case "ready":
            handleReady()
        case "contentUpdate":
            handleContentUpdate()
        case "error":
            handleError(body["message"] as? String ?? "")
        default:
            break
        }
    }
}
```

```javascript
// JavaScript 端
RE.postMessage = function(type, data = {}) {
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.aiTextView) {
        window.webkit.messageHandlers.aiTextView.postMessage({
            type: type,
            ...data,
            timestamp: Date.now()
        });
    }
};

// 使用
RE.postMessage('contentUpdate', {
    contentLength: this.currentContent.length,
    nodeCount: ast.length
});
```

### 2.3 缺少错误恢复机制

**当前问题**：
- 解析失败只打印日志
- 没有重试机制
- 错误状态不清除

**改进方案**：
```swift
public enum AITextViewError: Error {
    case webViewNotLoaded
    case parserUnavailable
    case renderFailed(String)
    case networkError(Error)
}

public protocol AITextViewDelegate: AnyObject {
    @objc optional func aiTextView(_ editor: AITextView, didEncounterError error: AITextViewError)
    @objc optional func aiTextView(_ editor: AITextView, didRecoverFromError error: AITextViewError)
}
```

```javascript
// JavaScript 端
updateMarkdown(newContent, isComplete) {
    let retryCount = 0;
    const maxRetries = 3;
    
    const attemptUpdate = () => {
        try {
            const ast = this.parser.parse(this.currentContent);
            this.renderer.renderAST(ast, RE.editor);
            
            // 成功，重置重试计数
            retryCount = 0;
            RE.postMessage('contentUpdate');
        } catch (error) {
            retryCount++;
            
            if (retryCount < maxRetries) {
                // 延迟重试
                setTimeout(attemptUpdate, 100 * retryCount);
            } else {
                // 上报错误
                RE.postMessage('error', {
                    message: error.message,
                    contentLength: this.currentContent.length
                });
            }
        }
    };
    
    attemptUpdate();
}
```

## 🟡 3. 代码质量问题

### 3.1 调试代码污染生产环境

**当前问题**：
- 大量 `print()` 和 `console.log()`
- 调试信息暴露给用户

**改进方案**：统一日志系统
```swift
// 日志级别
enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
}

struct Logger {
    static var level: LogLevel = .warning // 生产环境默认 warning
    static var isDebugMode: Bool = false
    
    static func debug(_ message: String, file: String = #file, line: Int = #line) {
        guard isDebugMode else { return }
        print("[DEBUG] \(message)")
    }
    
    static func error(_ message: String, error: Error? = nil) {
        if level.rawValue <= LogLevel.error.rawValue {
            print("[ERROR] \(message)")
            if let error = error {
                print("  Error: \(error)")
            }
        }
    }
}

// 使用
Logger.debug("流式更新: \(markdown.count)")
Logger.error("渲染失败", error: error)
```

### 3.2 重复的状态管理逻辑

**问题**：
- Swift 和 JavaScript 都有内容累积逻辑
- 状态可能不同步

**改进方案**：单一数据源
```swift
// Swift 只负责传递，不累积
func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
    // 直接发送到 JS，由 JS 管理状态
    let jsCode = """
    RE.streamMarkdownProcessor.appendMarkdown('\(escapeJavaScriptString(markdown))', \(isComplete));
    """
    runJS(jsCode)
    
    // Swift 端只保留一个轻量级的引用（用于读取）
    if isComplete {
        runJS("RE.getMarkdown()") { [weak self] content in
            self?.markdownBuffer = content
        }
    }
}
```

### 3.3 缺少类型安全

**改进方案**：使用强类型协议
```swift
// 定义消息协议
protocol AITextViewMessage {
    var type: MessageType { get }
    var data: [String: Any] { get }
}

enum MessageType: String {
    case ready
    case contentUpdate
    case error
    case streamComplete
}

struct ContentUpdateMessage: AITextViewMessage {
    let type: MessageType = .contentUpdate
    let contentLength: Int
    let nodeCount: Int
    
    var data: [String: Any] {
        return [
            "contentLength": contentLength,
            "nodeCount": nodeCount
        ]
    }
}
```

## 🟡 4. 用户体验问题

### 4.1 自动滚动可能打断用户

**当前问题**：
```226:228:AITextView/Sources/AITextView.swift
        if isAutoScrollEnabled && !markdown.isEmpty {
            scrollToBottom(animated: true)
        }
```

- 用户正在查看上方内容时，被强制滚动到底部

**改进方案**：智能滚动 ✅ 已实现

```swift
func scrollToBottom(animated: Bool = true) {
    let scrollView = webView.scrollView
    let contentHeight = scrollView.contentSize.height
    let viewHeight = scrollView.bounds.height
    let currentOffset = scrollView.contentOffset.y
    
    // 计算距离底部的距离
    let distanceFromBottom = contentHeight - currentOffset - viewHeight
    
    // 如果用户已经滚动到接近底部（距离底部 < 100pt），才自动滚动
    let threshold: CGFloat = 100.0
    if distanceFromBottom < threshold {
        // 执行滚动
        let jsCode = "RE.scrollToBottom();"
        runJS(jsCode) { result, error in
            if let error = error {
                // 备用方案：使用原生滚动
                DispatchQueue.main.async {
                    let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
                    scrollView.setContentOffset(CGPoint(x: 0, y: maxOffsetY), animated: animated)
                }
            }
        }
    } else {
        // 用户正在查看上方内容，不自动滚动
        // TODO: 可以显示一个"新内容"提示
    }
}
```

**优势**：
- ✅ 已实现：智能判断用户是否在底部附近
- ✅ 避免打断用户阅读：如果用户正在查看上方内容，不会强制滚动
- ✅ 有备用方案：JavaScript 滚动失败时使用原生滚动
- ⚠️ 待实现：新内容提示功能（显示一个小气泡提示有新内容）

### 4.2 缺少滚动位置记忆

**改进方案**：
```swift
private var savedScrollPosition: CGFloat = 0

func saveScrollPosition() {
    runJS("window.scrollY") { [weak self] y in
        if let y = Double(y) {
            self?.savedScrollPosition = CGFloat(y)
        }
    }
}

func restoreScrollPosition() {
    let jsCode = "window.scrollTo(0, \(savedScrollPosition));"
    runJS(jsCode)
}
```

## 🟢 5. 可测试性问题

### 5.1 缺少单元测试支持

**改进方案**：
```swift
// 提取可测试的组件
protocol MarkdownProcessor {
    func updateMarkdown(_ content: String, isComplete: Bool)
}

class JavaScriptMarkdownProcessor: MarkdownProcessor {
    weak var webView: WKWebView?
    
    func updateMarkdown(_ content: String, isComplete: Bool) {
        // 实现
    }
}

// 可以创建 Mock 实现用于测试
class MockMarkdownProcessor: MarkdownProcessor {
    var updatedContent: String?
    var isComplete: Bool?
    
    func updateMarkdown(_ content: String, isComplete: Bool) {
        self.updatedContent = content
        self.isComplete = isComplete
    }
}
```

## 📋 改进优先级总结

### 🔴 高优先级（立即改进）
1. ✅ **增量渲染**：解决性能瓶颈
2. ✅ **消息队列 + 节流**：减少频繁调用
3. ✅ **本地化依赖**：解决离线问题

### 🟡 中优先级（近期改进）
4. ✅ **统一日志系统**：清理调试代码
5. ✅ **智能滚动**：改善用户体验
6. ✅ **错误恢复机制**：提高稳定性

### 🟢 低优先级（长期优化）
7. ✅ **WKScriptMessageHandler**：改进通信机制
8. ✅ **单元测试支持**：提高代码质量
9. ✅ **类型安全**：减少运行时错误

## 🚀 实施建议

1. **第一阶段**（1-2周）：
   - 实现增量渲染
   - 添加消息队列和节流
   - 本地化 CDN 依赖

2. **第二阶段**（2-3周）：
   - 统一日志系统
   - 智能滚动
   - 错误处理改进

3. **第三阶段**（持续优化）：
   - WKScriptMessageHandler 迁移
   - 单元测试覆盖
   - 性能监控和分析

---

**文档版本**: 1.0  
**最后更新**: 2024

