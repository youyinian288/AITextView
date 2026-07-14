# Swift 与 JavaScript 通信机制详解

## 📋 概述

AITextView 使用 **双向通信机制**：

1. **Swift → JavaScript**: 直接调用（无队列）
2. **JavaScript → Swift**: 命令队列机制

## 🔄 通信方向对比

| 方向 | 方法 | 是否有队列 | 实现方式 |
|------|------|-----------|---------|
| Swift → JS | `evaluateJavaScript()` | ❌ 无队列，直接调用 | 同步/异步执行 JS 代码 |
| JS → Swift | `callbackQueue` | ✅ 有队列 | 自定义 URL 协议 + 队列 |

---

## 🚀 Swift → JavaScript（直接调用，无队列）

### 实现方式

Swift 通过 `WKWebView.evaluateJavaScript()` **直接执行** JavaScript 代码，**没有队列机制**。

### 代码实现

```swift
// AITextView.swift
public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
    webView.evaluateJavaScript(js) { (result, error) in
        if let error = error {
            print("WKWebViewJavascriptBridge Error: \(error)")
            handler?("")
            return
        }
        // 处理结果...
        handler?(resultString)
    }
}
```

### 使用示例

```swift
// 直接调用，每次都是新的执行
let jsCode = """
window.RE.streamMarkdownProcessor.updateMarkdown('\(escapedMarkdown)', \(isComplete));
"""
runJS(jsCode) { result in
    // 处理结果
}
```

### 特点

- ✅ **即时执行**: 每次调用立即执行
- ✅ **异步回调**: 通过闭包获取结果
- ❌ **无队列**: 每次调用都是独立的
- ⚠️ **顺序不保证**: 如果多次快速调用，执行顺序可能不确定

### 流式更新场景

```swift
// 流式更新时，每次都是直接调用
public func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
    // 累积到缓冲区
    markdownBuffer += markdown
    
    // 直接调用 JS，无队列
    let jsCode = """
    window.RE.streamMarkdownProcessor.updateMarkdown('\(escapedMarkdown)', \(isComplete));
    """
    runJS(jsCode)
}
```

**注意**: 如果流式更新非常频繁，可以考虑在 Swift 端实现批量队列（见后文改进建议）。

---

## 📬 JavaScript → Swift（命令队列机制）

这是**真正的队列系统**，用于 JavaScript 向 Swift 发送命令。

### 队列结构

```javascript
// stream_markdown_editor.js

// 全局命令队列（数组）
RE.callbackQueue = []

// 添加命令到队列
RE.callback = function(method) {
    RE.callbackQueue.push(method);  // 推入队列
    RE.runCallbackQueue();          // 触发处理
}

// 触发 Swift 回调
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;  // 队列为空，不处理
    }
    // 通过修改 location 触发 Swift 端拦截
    setTimeout(function() {
        window.location.href = "ai-callback://";
    }, 0);
}

// 获取并清空队列（Swift 端调用）
RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);  // 序列化为 JSON
    RE.callbackQueue = [];  // 清空队列
    return commands;
}
```

### 队列特点

1. **FIFO 队列**: 先进先出，数组结构
2. **批量处理**: 一次可以发送多个命令
3. **自动清空**: `getCommandQueue()` 后队列被清空
4. **异步触发**: 使用 `setTimeout` 确保在下一个事件循环触发

### Swift 端处理流程

```swift
// AITextView.swift

public func webView(_ webView: WKWebView, 
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
    let callbackPrefix = "ai-callback://"
    
    // 1. 拦截自定义 URL 协议
    if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
        
        // 2. 获取命令队列（JSON 字符串）
        runJS("RE.getCommandQueue()") { commands in
            if let data = commands.data(using: .utf8) {
                // 3. 解析 JSON 数组
                let jsonCommands: [String]
                do {
                    jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                } catch {
                    jsonCommands = []
                    NSLog("AITextView: Failed to parse JSON Commands")
                }
                
                // 4. 顺序执行每个命令
                jsonCommands.forEach(self.performCommand)
            }
        }
        
        // 5. 取消导航（因为这只是回调）
        return decisionHandler(WKNavigationActionPolicy.cancel)
    }
    
    // 默认允许导航
    return decisionHandler(WKNavigationActionPolicy.allow)
}
```

### 完整流程图

```
JavaScript 端
    ↓
RE.callback('ready')              // 1. 添加命令
    ↓
RE.callbackQueue.push('ready')    // 2. 推入队列: ['ready']
    ↓
RE.runCallbackQueue()             // 3. 检查队列非空
    ↓
window.location.href = "ai-callback://"  // 4. 触发 URL 跳转
    ↓
─────────────────────────────────────────
    ↓
Swift 端 (WKNavigationDelegate)
    ↓
拦截 URL: "ai-callback://"        // 5. 检测到回调
    ↓
runJS("RE.getCommandQueue()")     // 6. 获取队列
    ↓
JavaScript 返回: '["ready"]'      // 7. 队列序列化为 JSON
    ↓
RE.callbackQueue = []             // 8. JS 端清空队列
    ↓
JSON.parse('["ready"]')           // 9. Swift 解析 JSON
    ↓
jsonCommands = ["ready"]          // 10. 得到命令数组
    ↓
forEach(performCommand)           // 11. 顺序执行
    ↓
performCommand("ready")           // 12. 处理命令
```

### 命令类型示例

```javascript
// JavaScript 端调用
RE.callback('ready')                    // 初始化完成
RE.callback('contentUpdate')            // 内容更新
RE.callback('streamComplete')           // 流式完成
RE.callback('contentReset')             // 内容重置
RE.callback('heightChange/123')         // 高度变化（带参数）
RE.callback('debug/初始化完成')          // 调试信息
RE.callback('themeChange/dark')          // 主题变化
```

### 队列示例

```javascript
// 连续调用多个命令
RE.callback('debug/开始处理')
RE.callback('contentUpdate')
RE.callback('debug/处理完成')
RE.callback('streamComplete')

// 此时队列状态:
// RE.callbackQueue = [
//   'debug/开始处理',
//   'contentUpdate',
//   'debug/处理完成',
//   'streamComplete'
// ]

// Swift 端一次获取所有命令:
// jsonCommands = [
//   "debug/开始处理",
//   "contentUpdate",
//   "debug/处理完成",
//   "streamComplete"
// ]
```

---

## 🎯 为什么 JS → Swift 需要队列？

### 原因

1. **WKWebView 限制**: JavaScript 不能直接调用 Swift 方法
2. **URL 拦截**: 只能通过拦截 URL 来触发回调
3. **批量处理**: 避免频繁的 URL 跳转，提高性能
4. **命令顺序**: 保证命令按顺序执行

### 如果没有队列会怎样？

```javascript
// ❌ 没有队列的问题：
RE.callback('command1')
window.location.href = "ai-callback://"  // 立即跳转
RE.callback('command2')
window.location.href = "ai-callback://"  // 立即跳转
RE.callback('command3')
window.location.href = "ai-callback://"  // 立即跳转

// 问题：
// 1. 每次跳转都需要 Swift 端处理，开销大
// 2. 可能丢失命令（如果跳转太快）
// 3. 无法保证顺序
```

```javascript
// ✅ 有队列的优势：
RE.callback('command1')  // 加入队列
RE.callback('command2')  // 加入队列
RE.callback('command3')  // 加入队列
// 只触发一次 URL 跳转
window.location.href = "ai-callback://"

// 优势：
// 1. 批量处理，性能更好
// 2. 保证顺序
// 3. 不会丢失命令
```

---

## 🔧 Swift → JS 队列化改进建议

虽然当前 Swift → JS **没有队列**，但在**流式更新场景**下，可以考虑实现队列：

### 当前问题

```swift
// 流式更新时，每次片段都直接调用
updateMarkdownStream("片段1")  // 立即执行 JS
updateMarkdownStream("片段2")  // 立即执行 JS
updateMarkdownStream("片段3")  // 立即执行 JS

// 问题：
// 1. 频繁的 JS 调用，性能开销大
// 2. 可能导致渲染卡顿
```

### 改进方案：Swift 端队列

```swift
class AITextView: UIView {
    // 待发送的更新队列
    private var pendingUpdates: [String] = []
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 0.05 // 50ms
    
    func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
        if isComplete {
            // 完成时，立即处理所有待发送的内容
            flushUpdates(isComplete: true)
        } else {
            // 流式更新时，加入队列
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
        
        // 合并所有待发送的内容
        let combined = pendingUpdates.joined()
        pendingUpdates.removeAll()
        
        // 批量发送到 JS
        let jsCode = """
        window.RE.streamMarkdownProcessor.updateMarkdown('\(escapeJavaScriptString(combined))', \(isComplete));
        """
        runJS(jsCode)
        
        if isComplete {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
}
```

### 改进效果

| 场景 | 当前实现 | 改进后 |
|------|---------|--------|
| 100 个片段 | 100 次 JS 调用 | 约 20 次 JS 调用（50ms 批量） |
| 性能开销 | 高 | 低 |
| 渲染流畅度 | 可能卡顿 | 更流畅 |

---

## 📊 队列对比总结

| 特性 | Swift → JS | JS → Swift |
|------|-----------|-----------|
| **队列类型** | ❌ 无队列 | ✅ FIFO 数组队列 |
| **实现方式** | `evaluateJavaScript()` | `callbackQueue` + URL 拦截 |
| **批量处理** | ❌ 不支持 | ✅ 支持 |
| **顺序保证** | ⚠️ 不保证 | ✅ 保证 FIFO |
| **性能** | ⚠️ 频繁调用开销大 | ✅ 批量处理效率高 |
| **适用场景** | 单次调用 | 批量命令通知 |

---

## 🔍 调试队列

### 查看当前队列状态

```javascript
// 在浏览器控制台或 JS 代码中
console.log('当前队列:', RE.callbackQueue);
console.log('队列长度:', RE.callbackQueue.length);
```

### Swift 端调试

```swift
// 在 performCommand 中添加日志
private func performCommand(_ method: String) {
    print("🔔 收到 JavaScript 命令: \(method)")
    // ... 处理命令
}
```

---

## 📝 总结

1. **Swift → JS**: 
   - 直接调用，无队列
   - 适合单次操作
   - 流式场景可考虑实现队列优化

2. **JS → Swift**: 
   - 使用 FIFO 队列
   - 批量处理，性能更好
   - 保证命令顺序

3. **改进方向**: 
   - Swift 端可以实现队列来优化流式更新
   - 使用定时器批量发送，减少 JS 调用次数





