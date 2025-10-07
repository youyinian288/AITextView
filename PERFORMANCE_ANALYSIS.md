# AITextView runJS 性能分析

## 测试结果总结

根据性能测试结果，回调版本的 runJS 方法比 async/await 版本性能更好：

- **回调版本总时间**: 0.008422017097473145秒
- **Async/Await版本总时间**: 0.021973013877868652秒
- **性能差异**: 回调版本快约 2.6 倍

## 性能差异原因分析

### 1. 执行模式差异

#### 回调版本（并发执行）
```swift
for i in 0..<totalExecutions {
    let jsCode = "document.getElementById('editor').clientHeight + \(i)"
    aiTextView.runJS(jsCode) { result in
        // 回调处理
    }
}
// 所有调用几乎同时发出，并发执行
```

#### Async/Await版本（串行执行）
```swift
for i in 0..<totalExecutions {
    let jsCode = "document.getElementById('editor').clientHeight + \(i)"
    let result = try await aiTextView.runJS(jsCode) // 等待前一个完成
    // 处理结果
}
// 每个 await 都会阻塞，导致串行执行
```

### 2. 关键性能因素

#### 回调版本优势
- ✅ **并发执行**: 所有JS调用同时发出
- ✅ **无阻塞**: 不等待单个调用完成
- ✅ **低开销**: 直接调用，无额外框架开销
- ✅ **高效等待**: 使用 `waitForExpectations` 等待所有完成

#### Async/Await版本劣势
- ❌ **串行执行**: 必须等待前一个调用完成
- ❌ **阻塞等待**: 每个 `await` 都会阻塞
- ❌ **额外开销**: Task 创建和 MainActor 切换
- ❌ **框架复杂性**: 异步框架的额外处理

### 3. 时间线对比

#### 回调版本时间线
```
时间 0ms: 发出100个JS调用
时间 1ms: 所有调用并发执行
时间 8ms: 所有调用完成
```

#### Async/Await版本时间线
```
时间 0ms: 发出第1个JS调用
时间 0.2ms: 第1个完成，发出第2个
时间 0.4ms: 第2个完成，发出第3个
...
时间 22ms: 第100个完成
```

## 优化建议

### 1. 使用并发 async/await
```swift
// 并发版本 - 性能接近回调版本
await withTaskGroup(of: String.self) { group in
    for i in 0..<count {
        group.addTask {
            try await aiTextView.runJS(operation)
        }
    }
    
    for await result in group {
        // 处理结果
    }
}
```

### 2. 根据场景选择方法

#### 使用回调版本的情况
- 需要最高性能
- 大量并发JS调用
- 简单的错误处理
- 兼容旧版本iOS

#### 使用 async/await 的情况
- 需要复杂的异步流程控制
- 错误处理要求高
- 代码可读性优先
- 现代Swift开发

### 3. 混合使用策略
```swift
// 对于性能关键的批量操作使用回调
func batchJSExecution(_ operations: [String]) {
    let expectation = expectation(description: "Batch JS")
    var completed = 0
    
    for operation in operations {
        aiTextView.runJS(operation) { result in
            completed += 1
            if completed == operations.count {
                expectation.fulfill()
            }
        }
    }
    
    waitForExpectations(timeout: 10.0)
}

// 对于复杂流程使用 async/await
func complexWorkflow() async throws {
    let result1 = try await aiTextView.runJS("RE.getHtml()")
    let result2 = try await aiTextView.runJS("RE.getText()")
    // 基于结果进行复杂处理
}
```

## 结论

回调版本性能更好的根本原因是**执行模式的差异**：
- 回调版本天然支持并发执行
- async/await 版本默认串行执行

这不是 async/await 本身的问题，而是使用方式的问题。通过使用 `withTaskGroup` 等并发工具，async/await 版本也能达到接近回调版本的性能。

选择哪种方法应该基于：
1. **性能要求**: 极高性能场景选择回调
2. **代码复杂度**: 复杂异步流程选择 async/await
3. **团队偏好**: 现代Swift开发推荐 async/await
4. **维护性**: 长期维护考虑代码可读性
