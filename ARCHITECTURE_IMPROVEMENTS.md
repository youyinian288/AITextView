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

#### 方案 A：增量渲染（推荐）
```javascript
class IncrementalRenderer {
    constructor() {
        this.lastRenderedAST = [];
        this.renderCache = new Map(); // 节点缓存，避免重复渲染
    }
    
    // AST 差异计算（简化版，实际可使用更复杂的算法如 Myers diff）
    astDiff(oldAST, newAST) {
        const diff = {
            added: [],
            modified: [],
            removed: [],
            unchanged: []
        };
        
        const oldLength = oldAST.length;
        const newLength = newAST.length;
        const maxLength = Math.max(oldLength, newLength);
        
        // 简单的基于索引和类型的比较
        for (let i = 0; i < maxLength; i++) {
            const oldNode = oldAST[i];
            const newNode = newAST[i];
            
            if (!oldNode && newNode) {
                // 新增节点
                diff.added.push({ node: newNode, index: i });
            } else if (oldNode && !newNode) {
                // 删除节点
                diff.removed.push({ node: oldNode, index: i });
            } else if (oldNode && newNode) {
                // 比较节点内容（简化：基于类型和内容）
                if (this.nodeEquals(oldNode, newNode)) {
                    diff.unchanged.push({ node: newNode, index: i });
                } else {
                    diff.modified.push({ oldNode, newNode, index: i });
                }
            }
        }
        
        return diff;
    }
    
    // 节点相等性判断（可根据需要扩展）
    nodeEquals(node1, node2) {
        if (node1.type !== node2.type) return false;
        if (node1.content !== node2.content) return false;
        if (JSON.stringify(node1.attrs) !== JSON.stringify(node2.attrs)) return false;
        return true;
    }
    
    // 增量渲染主方法
    renderIncremental(newAST, container) {
        if (!newAST || newAST.length === 0) {
            container.innerHTML = '';
            this.lastRenderedAST = [];
            return;
        }
        
        // 首次渲染或完全重建（当差异过大时）
        if (this.lastRenderedAST.length === 0 || 
            newAST.length < this.lastRenderedAST.length * 0.5) {
            this.renderFull(newAST, container);
            return;
        }
        
        try {
            const diff = this.astDiff(this.lastRenderedAST, newAST);
            
            // 从后往前删除，避免索引变化
            diff.removed.reverse().forEach(({ index }) => {
                const child = container.children[index];
                if (child) {
                    child.remove();
                }
            });
            
            // 更新修改的节点
            diff.modified.forEach(({ oldNode, newNode, index }) => {
                const oldElement = container.children[index];
                if (oldElement && this.renderCache.has(oldNode)) {
                    // 复用缓存的渲染函数
                    const cached = this.renderCache.get(oldNode);
                    if (cached) {
                        const newElement = this.renderNode(newNode);
                        oldElement.replaceWith(newElement);
                        this.renderCache.set(newNode, newElement);
                        this.renderCache.delete(oldNode);
                    }
                } else {
                    const newElement = this.renderNode(newNode);
                    oldElement?.replaceWith(newElement) || container.appendChild(newElement);
                    this.renderCache.set(newNode, newElement);
                }
            });
            
            // 添加新节点（保持顺序）
            diff.added.forEach(({ node, index }) => {
                const newElement = this.renderNode(node);
                const refNode = container.children[index];
                if (refNode) {
                    container.insertBefore(newElement, refNode);
                } else {
                    container.appendChild(newElement);
                }
                this.renderCache.set(node, newElement);
            });
            
            this.lastRenderedAST = [...newAST];
            
        } catch (error) {
            console.error('增量渲染失败，回退到全量渲染:', error);
            this.renderFull(newAST, container);
        }
    }
    
    // 全量渲染（fallback）
    renderFull(ast, container) {
        container.innerHTML = '';
        ast.forEach(node => {
            const element = this.renderNode(node);
            container.appendChild(element);
            this.renderCache.set(node, element);
        });
        this.lastRenderedAST = [...ast];
    }
    
    // 清理缓存
    clearCache() {
        this.renderCache.clear();
        this.lastRenderedAST = [];
    }
}
```

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

// 方案 B：使用 JSONEncoder（推荐 - 更安全，正确处理所有 Unicode 字符）
// JSONEncoder 能够正确处理所有特殊字符，包括：
// - 控制字符（\n, \r, \t 等）
// - Unicode 字符（emoji、中文等）
// - 转义字符（\, ", ' 等）
// - 零宽字符等边界情况
private func escapeJavaScriptString(_ string: String) -> String {
    // 使用 JSONEncoder 编码字符串，它会自动添加引号和转义
    do {
        let jsonData = try JSONEncoder().encode(string)
        // JSON 编码的结果是 "..." 格式，需要去掉首尾引号才能嵌入到 JavaScript 字符串中
        if let jsonString = String(data: jsonData, encoding: .utf8),
           jsonString.hasPrefix("\""),
           jsonString.hasSuffix("\"") {
            let startIndex = jsonString.index(jsonString.startIndex, offsetBy: 1)
            let endIndex = jsonString.index(jsonString.endIndex, offsetBy: -1)
            return String(jsonString[startIndex..<endIndex])
        }
        // 如果格式不符合预期，回退到手动转义
        return escapeJavaScriptStringManual(string)
    } catch {
        // 编码失败时回退到手动转义方案
        print("⚠️ JSONEncoder 编码失败，使用手动转义: \(error)")
        return escapeJavaScriptStringManual(string)
    }
}

// 手动转义（作为 fallback，或在性能敏感场景使用）
private func escapeJavaScriptStringManual(_ string: String) -> String {
    var result = ""
    result.reserveCapacity(string.count * 2) // 预分配空间，减少内存分配
    
    for char in string {
        switch char {
        case "\\": result += "\\\\"
        case "'": result += "\\'"
        case "\"": result += "\\\""
        case "\n": result += "\\n"
        case "\r": result += "\\r"
        case "\t": result += "\\t"
        case "\u{2028}": result += "\\u2028"  // 行分隔符
        case "\u{2029}": result += "\\u2029"  // 段落分隔符
        default:
            // 处理控制字符
            if char.isASCII && char.unicodeScalars.first?.value ?? 0 < 32 {
                result += String(format: "\\u%04x", char.unicodeScalars.first?.value ?? 0)
            } else {
                result.append(char)
            }
        }
    }
    return result
}
```

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
```220:222:AITextView/Sources/AITextView.swift
        if isAutoScrollEnabled && !markdown.isEmpty {
            scrollToBottom(animated: true)
        }
```

- 用户正在查看上方内容时，被强制滚动到底部
- 无法感知是否有新内容到达
- 滚动阈值硬编码，不够灵活

**改进方案**：智能滚动 + 新内容提示
```swift
class AITextView: UIView {
    // 可配置的滚动阈值（距离底部多少像素时触发自动滚动）
    @objc public var autoScrollThreshold: CGFloat = 100.0
    
    // 新内容提示视图
    private var newContentIndicator: UIView?
    private var newContentCount: Int = 0
    
    /// 智能滚动到底部（仅在用户接近底部时滚动）
    func scrollToBottom(animated: Bool = true) {
        guard isAutoScrollEnabled else { return }
        
        let scrollView = webView.scrollView
        let contentHeight = scrollView.contentSize.height
        let viewHeight = scrollView.bounds.height
        let currentOffset = scrollView.contentOffset.y
        
        // 计算距离底部的距离
        let distanceFromBottom = contentHeight - currentOffset - viewHeight
        
        // 如果用户已经滚动到接近底部，才自动滚动
        if distanceFromBottom <= autoScrollThreshold {
            // 执行滚动
            let jsCode = """
            (function() {
                window.scrollTo({
                    top: document.body.scrollHeight,
                    behavior: '\(animated ? "smooth" : "auto")'
                });
            })();
            """
            runJS(jsCode)
            
            // 滚动时隐藏新内容提示
            hideNewContentIndicator()
        } else {
            // 用户正在查看上方内容，不自动滚动
            // 显示新内容提示
            incrementNewContentIndicator()
        }
    }
    
    /// 显示/更新新内容提示
    private func incrementNewContentIndicator() {
        newContentCount += 1
        
        // 延迟显示，避免频繁更新 UI
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(showNewContentIndicator),
            object: nil
        )
        perform(#selector(showNewContentIndicator), with: nil, afterDelay: 0.3)
    }
    
    @objc private func showNewContentIndicator() {
        guard newContentCount > 0 else { return }
        
        // 创建或更新提示视图
        if newContentIndicator == nil {
            let indicator = UIView()
            indicator.backgroundColor = .systemBlue
            indicator.layer.cornerRadius = 16
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "新内容"
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            indicator.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: indicator.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: indicator.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: -12),
                indicator.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
            ])
            
            newContentIndicator = indicator
            indicator.alpha = 0
            indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        // 更新计数显示
        if let label = newContentIndicator?.subviews.first as? UILabel {
            if newContentCount > 1 {
                label.text = "\(newContentCount) 条新内容"
            } else {
                label.text = "新内容"
            }
        }
        
        // 动画显示
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.newContentIndicator?.alpha = 1.0
            self.newContentIndicator?.transform = .identity
        })
        
        // 添加点击手势，点击时滚动到底部
        if newContentIndicator?.gestureRecognizers?.isEmpty ?? true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onNewContentIndicatorTapped))
            newContentIndicator?.addGestureRecognizer(tapGesture)
            newContentIndicator?.isUserInteractionEnabled = true
        }
    }
    
    @objc private func onNewContentIndicatorTapped() {
        // 强制滚动到底部
        let jsCode = """
        (function() {
            window.scrollTo({
                top: document.body.scrollHeight,
                behavior: 'smooth'
            });
        })();
        """
        runJS(jsCode)
        hideNewContentIndicator()
    }
    
    /// 隐藏新内容提示
    private func hideNewContentIndicator() {
        guard let indicator = newContentIndicator, indicator.alpha > 0 else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            indicator.alpha = 0
            indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.newContentCount = 0
        }
    }
}
```

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

