# AITextView 架构详解

> 深入解析 AITextView 的整体架构设计，以及为什么 Native 和 JS 端都需要命令队列机制

## 📋 目录

- [整体架构](#整体架构)
- [通信机制详解](#通信机制详解)
- [为什么需要命令队列](#为什么需要命令队列)
- [数据流向](#数据流向)
- [性能优化考虑](#性能优化考虑)

---

## 🏗️ 整体架构

### 架构层次图

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS 应用层                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  UIKit App   │  │ SwiftUI App  │  │  其他应用    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼─────────────────┼──────────────┘
          │                  │                 │
          └──────────────────┼─────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                  Swift 核心层                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              AITextView (UIView)                     │  │
│  │  • 管理 WebView 生命周期                              │  │
│  │  • 处理流式 Markdown 更新                             │  │
│  │  • 命令队列处理（JS → Swift）                         │  │
│  │  • 智能滚动控制                                       │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │         AITextWebView (WKWebView 包装)                │  │
│  │  • 加载 HTML 容器                                     │  │
│  │  • 拦截 URL 回调（ai-callback://）                    │  │
│  │  • 执行 JavaScript 代码                               │  │
│  └──────────────────┬───────────────────────────────────┘  │
└─────────────────────┼──────────────────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────────────────┐
│                  WebView 容器层                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      stream_markdown_editor.html                     │  │
│  │  • HTML 结构容器                                      │  │
│  │  • 引入 CSS 和 JS 资源                                │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │              markdown.css                             │  │
│  │  • Markdown 样式定义                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────┬──────────────────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────────────────┐
│              JavaScript 核心层                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      stream_markdown_editor.js (2494行)             │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  解析器模块                                   │   │  │
│  │  │  • MarkdownItParser (主解析器)               │   │  │
│  │  │  • SimpleMarkdownParser (备用解析器)          │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  渲染器模块                                   │   │  │
│  │  │  • PureJSMarkdownRenderer                     │   │  │
│  │  │  • 15+ 组件系统 (Text/Heading/Code等)         │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  流式处理模块                                 │   │  │
│  │  │  • streamMarkdownProcessor                    │   │  │
│  │  │  • 增量渲染支持                               │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  命令队列模块                                 │   │  │
│  │  │  • callbackQueue (JS → Swift)                │   │  │
│  │  │  • RE.callback() 方法                         │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 通信机制详解

### 1. Swift → JavaScript（直接调用）

**实现方式**：使用 `WKWebView.evaluateJavaScript()`

```swift
// AITextView.swift
public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
    webView.evaluateJavaScript(js) { (result, error) in
        // 处理结果
        handler?(resultString)
    }
}
```

**特点**：
- ✅ **即时执行**：每次调用立即执行 JavaScript
- ✅ **异步回调**：通过闭包获取执行结果
- ❌ **无队列机制**：每次调用都是独立的
- ⚠️ **顺序不保证**：如果快速连续调用，执行顺序可能不确定

**使用场景**：
```swift
// 流式更新 Markdown
let jsCode = """
window.RE.streamMarkdownProcessor.updateMarkdown('\(escapedMarkdown)', \(isComplete));
"""
runJS(jsCode)

// 设置完整内容
runJS("RE.setMarkdown('\(escapedMarkdown)')")

// 滚动到底部
runJS("RE.scrollToBottom()")
```

### 2. JavaScript → Swift（命令队列机制）

**实现方式**：自定义 URL Scheme + 命令队列

#### JavaScript 端实现

```javascript
// stream_markdown_editor.js
window.RE.callbackQueue = [];

// 添加命令到队列
RE.callback = function(method) {
    if (!RE.callbackQueue) {
        RE.callbackQueue = [];
    }
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

// 触发回调（通过 URL Scheme）
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;
    }
    // 使用 setTimeout 确保在下一个事件循环中执行
    setTimeout(function() {
        window.location.href = "ai-callback://";
    }, 0);
};

// 获取并清空命令队列
RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];  // 清空队列
    return commands;
};
```

#### Swift 端实现

```swift
// AITextView.swift
public func webView(_ webView: WKWebView, 
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
    let callbackPrefix = "ai-callback://"
    if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
        // 获取命令队列
        runJS("RE.getCommandQueue()") { commands in
            if let data = commands.data(using: .utf8) {
                let jsonCommands: [String]
                do {
                    jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                } catch {
                    jsonCommands = []
                }
                
                // 批量执行所有命令
                jsonCommands.forEach(self.performCommand)
            }
        }
        decisionHandler(.cancel)  // 取消导航
        return
    }
    
    decisionHandler(.allow)
}
```

**命令类型示例**：
- `ready` - JS 初始化完成
- `contentUpdate` - 内容更新通知
- `streamComplete` - 流式输出完成
- `heightChange/123` - 高度变化（123 是高度值）
- `debug/xxx` - 调试信息

---

## 🤔 为什么需要命令队列？

### 问题 1：为什么 JavaScript → Swift 需要命令队列？

#### 原因 1：URL Scheme 回调的限制

**问题场景**：
```javascript
// 如果没有队列，每次回调都会触发一次导航
RE.callback('ready');
RE.callback('contentUpdate');
RE.callback('heightChange/500');
// 这会触发 3 次 window.location.href = "ai-callback://"
// Swift 端会收到 3 次导航事件
```

**问题**：
1. **性能开销**：每次 `window.location.href` 都会触发 Swift 端的导航拦截
2. **丢失命令**：如果多个回调快速连续触发，可能只处理最后一个
3. **竞态条件**：Swift 端在处理第一个回调时，第二个回调可能已经触发

#### 解决方案：命令队列

```javascript
// 使用队列，批量处理
RE.callback('ready');        // 加入队列：[ready]
RE.callback('contentUpdate'); // 加入队列：[ready, contentUpdate]
RE.callback('heightChange/500'); // 加入队列：[ready, contentUpdate, heightChange/500]

// 只触发一次导航
window.location.href = "ai-callback://"

// Swift 端一次性获取所有命令
RE.getCommandQueue()  // 返回：["ready", "contentUpdate", "heightChange/500"]
```

**优势**：
- ✅ **批量处理**：一次导航事件处理多个命令
- ✅ **保证顺序**：队列保证命令的执行顺序
- ✅ **减少开销**：减少 Swift 和 JS 之间的往返次数
- ✅ **避免丢失**：所有命令都会被处理

#### 原因 2：异步执行的时序问题

**场景**：流式渲染过程中，多个事件快速触发

```javascript
// 流式更新时，可能同时触发多个事件
streamMarkdownProcessor.updateMarkdown(newContent, false);
// → 触发 contentUpdate
// → 触发 heightChange
// → 触发 scrollToBottom

// 如果没有队列，这些回调可能：
// 1. 被合并（只处理最后一个）
// 2. 顺序错乱
// 3. 部分丢失
```

**使用队列后**：
```javascript
// 所有回调都加入队列
RE.callback('contentUpdate');
RE.callback('heightChange/500');
RE.callback('scrollToBottom');

// 一次性发送给 Swift，保证所有命令都被处理
```

### 问题 2：为什么 Swift → JavaScript 目前没有队列？

#### 当前实现（无队列）

```swift
// 每次流式更新都直接调用
public func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
    let jsCode = """
    window.RE.streamMarkdownProcessor.updateMarkdown('\(escapedMarkdown)', \(isComplete));
    """
    runJS(jsCode)  // 直接执行，无队列
}
```

**为什么可以没有队列？**
1. **单向通信**：Swift → JS 是单向的，不需要等待结果（大部分情况）
2. **即时性要求**：流式更新需要立即显示，延迟会影响用户体验
3. **JS 端处理**：JS 端有 `currentContent` 缓冲区，可以累积内容

#### 潜在问题：频繁调用

**问题场景**：
```swift
// AI 流式输出，每秒可能调用 10-20 次
for chunk in aiStream {
    updateMarkdownStream(chunk, isComplete: false)
    // 每次都调用 evaluateJavaScript
}
```

**潜在问题**：
- ⚠️ **性能开销**：频繁的 `evaluateJavaScript` 调用
- ⚠️ **执行顺序**：如果调用太快，可能顺序不确定
- ⚠️ **资源浪费**：每次调用都有桥接开销

#### 优化方案：Swift 端也可以使用队列（可选）

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

**优势**：
- ✅ **减少调用次数**：批量处理多个更新
- ✅ **保证顺序**：队列保证执行顺序
- ✅ **性能优化**：减少桥接开销

**权衡**：
- ⚠️ **延迟增加**：最多延迟 50ms（可能影响实时性）
- ⚠️ **复杂度增加**：需要管理定时器和队列

---

## 🔄 数据流向

### 流式渲染完整流程

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Swift 端：接收 AI 流式输出                                │
│    updateMarkdownStream("Hello", isComplete: false)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Swift → JS：直接调用（无队列）                            │
│    evaluateJavaScript("RE.streamMarkdownProcessor...")      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. JS 端：累积内容                                           │
│    currentContent += "Hello"                                │
│    parser.parse(currentContent) → AST                       │
│    renderer.renderAST(ast) → DOM                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. JS → Swift：命令队列                                      │
│    RE.callback('contentUpdate')  → 加入队列                 │
│    RE.callback('heightChange/500') → 加入队列               │
│    window.location.href = "ai-callback://" → 触发回调       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Swift 端：批量处理命令                                    │
│    RE.getCommandQueue() → ["contentUpdate", "heightChange/500"]│
│    performCommand("contentUpdate")                          │
│    performCommand("heightChange/500")                       │
└─────────────────────────────────────────────────────────────┘
```

### 命令队列工作流程

```
时间线：
T1: JS 调用 RE.callback('ready')
    → callbackQueue = ['ready']
    → 触发 runCallbackQueue()
    → window.location.href = "ai-callback://"

T2: JS 调用 RE.callback('contentUpdate')
    → callbackQueue = ['ready', 'contentUpdate']
    → (runCallbackQueue 已触发，等待处理)

T3: Swift 拦截导航事件
    → 调用 RE.getCommandQueue()
    → 获取：["ready", "contentUpdate"]
    → 清空队列：callbackQueue = []
    → 执行 performCommand('ready')
    → 执行 performCommand('contentUpdate')

T4: JS 调用 RE.callback('heightChange/500')
    → callbackQueue = ['heightChange/500']
    → 触发 runCallbackQueue()
    → window.location.href = "ai-callback://"

T5: Swift 再次拦截
    → 获取：["heightChange/500"]
    → 执行 performCommand('heightChange/500')
```

---

## ⚡ 性能优化考虑

### 当前架构的性能特点

| 通信方向 | 队列机制 | 性能特点 | 优化空间 |
|---------|---------|---------|---------|
| Swift → JS | ❌ 无队列 | 即时执行，频繁调用有开销 | ✅ 可添加批量队列 |
| JS → Swift | ✅ 有队列 | 批量处理，减少往返 | ✅ 已优化 |

### 优化建议

#### 1. Swift → JS 批量队列（可选）

**适用场景**：
- 流式更新非常频繁（> 20次/秒）
- 对实时性要求不是极高（可接受 50ms 延迟）

**实现**：见上文"优化方案"

#### 2. JS → Swift 队列优化

**当前实现已优化**：
- ✅ 批量处理多个命令
- ✅ 使用 `setTimeout` 避免阻塞
- ✅ 清空队列避免重复处理

**进一步优化**：
```javascript
// 可以添加去重逻辑
RE.callback = function(method) {
    // 如果队列中已有相同命令，可以合并
    if (RE.callbackQueue.includes(method)) {
        return;  // 跳过重复命令
    }
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};
```

---

## 📊 总结

### 架构设计要点

1. **混合架构**：Swift + WebView + JavaScript
   - 利用 Web 技术的 Markdown 渲染能力
   - 保持原生 iOS 的性能和集成

2. **双向通信**：
   - Swift → JS：直接调用（即时执行）
   - JS → Swift：命令队列（批量处理）

3. **命令队列的必要性**：
   - ✅ **JS → Swift**：必须使用队列（解决 URL Scheme 回调限制）
   - ⚠️ **Swift → JS**：可选使用队列（优化频繁调用场景）

### 设计原则

- **解耦**：Swift 和 JS 通过明确的接口通信
- **可靠性**：队列保证命令不丢失、顺序正确
- **性能**：批量处理减少桥接开销
- **可扩展**：命令队列易于添加新命令类型

---

**文档版本**: 1.0  
**最后更新**: 2024





