# AITextView 性能测试说明

## 概述

本目录包含了 AITextView 的性能测试，专门用于测试大量字符（10万到50万字符）的渲染性能。

## 测试文件

### 1. AITextViewTests.swift
- 包含基础功能测试和简化的性能测试
- `testLargeContentRendering()` - 测试10万字符的渲染性能

### 2. AITextViewQuickPerformanceTests.swift
- 专门用于性能测试的快速版本
- `testLargeContentRenderingPerformance()` - 测试10万到50万字符的渲染性能（1万字符递增）
- `testSpecificCharacterCountPerformance()` - 测试特定字符数的渲染性能
- `testMemoryLeakWithLargeContent()` - 测试内存泄漏

### 3. AITextViewPerformanceTests.swift
- 完整的性能测试套件，包含详细的内存监控和性能分析

## 如何运行测试

### 运行所有测试
```bash
# 在 Xcode 中
⌘ + U

# 或者使用命令行
xcodebuild test -scheme AITextViewUIKIT -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 运行特定测试
```bash
# 运行性能测试
xcodebuild test -scheme AITextViewUIKIT -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AITextViewUIKITTests/AITextViewQuickPerformanceTests/testLargeContentRenderingPerformance

# 运行内存泄漏测试
xcodebuild test -scheme AITextViewUIKIT -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AITextViewUIKITTests/AITextViewQuickPerformanceTests/testMemoryLeakWithLargeContent
```

## 测试内容

### 基础HTML模板
测试使用包含以下元素的丰富HTML内容：
- 标题（H1-H6）
- 文本格式（粗体、斜体、下划线、删除线）
- 颜色和背景色
- 列表（有序和无序）
- 对齐方式
- 链接和图片
- 表格
- 特殊字符和符号
- 代码块

### 测试范围
- **字符数范围**: 100,000 - 500,000 字符
- **递增步长**: 10,000 字符
- **测试次数**: 41 次测试（100K, 110K, 120K, ..., 500K）

## 性能指标

### 预期性能
- **渲染时间**: < 15秒（50万字符）
- **内存使用**: < 300MB（50万字符）
- **渲染速度**: > 1,000字符/秒

### 监控指标
1. **渲染时间**: 从设置HTML到渲染完成的时间
2. **内存使用**: 渲染过程中的内存占用
3. **渲染速度**: 字符数/渲染时间

## 测试结果示例

```
📊 AITextView 大内容渲染性能报告
============================================================
字符数		渲染时间(秒)	内存使用(MB)	性能(字符/秒)
------------------------------------------------------------
100000		0.250		15.50		400000
110000		0.275		17.20		400000
120000		0.300		18.90		400000
...
500000		1.250		75.00		400000
------------------------------------------------------------
📈 平均统计:
⏱️ 平均渲染时间: 0.675秒
💾 平均内存使用: 45.30MB
🚀 平均性能: 400000字符/秒
============================================================
```

## 注意事项

1. **测试环境**: 建议在真机上运行以获得准确的性能数据
2. **内存监控**: 测试会监控内存使用情况，检测潜在的内存泄漏
3. **异步渲染**: AITextView使用WebKit进行渲染，测试会等待渲染完成
4. **预热**: 某些测试会进行预热以提高准确性

## 故障排除

### 测试失败
- 检查设备内存是否充足
- 确保测试在真机上运行
- 检查Xcode控制台的详细错误信息

### 性能不达标
- 检查设备性能
- 确保没有其他应用占用资源
- 考虑优化HTML内容的复杂度

## 自定义测试

### 修改测试字符数范围
```swift
// 在 AITextViewQuickPerformanceTests.swift 中修改
let testCases = stride(from: 50_000, through: 1_000_000, by: 50_000) // 5万到100万字符，5万递增
```

### 修改基础HTML模板
```swift
// 修改 baseHTMLTemplate 变量以测试不同的HTML内容
private let baseHTMLTemplate = """
    <h1>自定义测试内容</h1>
    <p>你的HTML内容...</p>
    """
```

### 调整性能阈值
```swift
// 在 validatePerformanceResults 方法中修改
XCTAssertLessThan(result.renderTime, 20.0, "渲染时间阈值")
XCTAssertLessThan(result.memoryUsage, 500.0, "内存使用阈值")
XCTAssertGreaterThan(performance, 500.0, "性能阈值")
```
