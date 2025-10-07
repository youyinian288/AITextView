# AITextView runJS 性能测试指南

## 概述

本测试套件专门用于测试 AITextView 库中 `runJS` 方法的性能，包括两个版本：
1. **回调版本** (`runJS(_:handler:)`) - 传统的回调方式
2. **Async/Await版本** (`runJS(_:) async throws -> String`) - iOS 13.0+ 的现代异步方式

## 测试文件

### 1. AITextViewRunJSPerformanceTests.swift
包含全面的性能测试，涵盖：
- 基础 runJS 性能测试
- 不同JS操作类型性能测试
- 并发JS执行性能测试
- 错误处理性能测试
- 大数据量JS操作性能测试
- 内存使用性能测试

### 2. AITextViewRunJSComparisonTests.swift
专门用于对比两种 runJS 方法的性能差异：
- 基础性能对比
- 详细性能分析
- 内存使用对比
- 结果一致性验证

## 运行测试

### 方法1: 使用脚本（推荐）
```bash
./run_js_performance_tests.sh
```

### 方法2: 使用 Xcode
1. 打开 `AITextViewSample/AITextViewUIKIT/AITextViewUIKIT.xcodeproj`
2. 选择测试目标
3. 运行 `AITextViewRunJSPerformanceTests` 或 `AITextViewRunJSComparisonTests`

### 方法3: 使用命令行
```bash
# 运行所有 runJS 性能测试
xcodebuild test \
    -project AITextViewSample/AITextViewUIKIT/AITextViewUIKIT.xcodeproj \
    -scheme AITextViewUIKIT \
    -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
    -only-testing:AITextViewUIKITTests/AITextViewRunJSPerformanceTests

# 运行对比测试
xcodebuild test \
    -project AITextViewSample/AITextViewUIKIT/AITextViewUIKIT.xcodeproj \
    -scheme AITextViewUIKIT \
    -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
    -only-testing:AITextViewUIKITTests/AITextViewRunJSComparisonTests
```

## 测试指标

### 性能指标
- **执行时间**: 单个JS操作的平均执行时间
- **吞吐量**: 单位时间内完成的JS操作数量
- **响应时间**: 从调用到返回结果的时间
- **并发性能**: 多线程环境下的执行效率

### 内存指标
- **基础内存占用**: 无操作时的内存使用
- **操作内存增长**: 执行JS操作时的内存变化
- **内存泄漏检测**: 长时间运行后的内存稳定性

### 错误处理指标
- **错误率**: 无效JS代码的执行失败率
- **错误恢复时间**: 从错误中恢复的时间
- **异常处理开销**: 错误处理机制的性能影响

## 测试场景

### 1. 基础性能测试
- 简单JS操作（获取元素属性、调用基础方法）
- 复杂JS操作（HTML获取、文本处理、选择操作）
- 格式化操作（粗体、斜体、颜色设置等）

### 2. 压力测试
- 大量连续JS操作
- 并发JS执行
- 长时间运行稳定性

### 3. 边界测试
- 错误JS代码处理
- 大数据量处理
- 内存限制测试

## 结果分析

### 性能对比
测试会输出详细的性能对比数据：
```
=== 性能对比结果 ===
回调版本总时间: 2.345秒
Async/Await版本总时间: 2.123秒
性能差异: 0.222秒
回调版本平均每次: 0.023秒
Async/Await版本平均每次: 0.021秒
```

### 内存使用对比
```
=== 内存使用对比 ===
回调版本内存使用: 15.2 MB
Async/Await版本内存使用: 14.8 MB
内存差异: 0.4 MB
```

## 优化建议

### 基于测试结果的优化方向
1. **如果回调版本更快**: 考虑在简单操作中使用回调版本
2. **如果async/await版本更快**: 优先使用现代异步方式
3. **如果内存使用差异大**: 优化内存管理策略
4. **如果并发性能差**: 考虑优化线程管理

### 性能优化策略
1. **批量操作**: 将多个JS操作合并为单个调用
2. **缓存结果**: 避免重复执行相同的JS操作
3. **异步处理**: 使用适当的异步模式
4. **内存管理**: 及时释放不需要的资源

## 注意事项

1. **测试环境**: 建议在真机上运行测试以获得更准确的结果
2. **多次测试**: 运行多次测试以获取平均值
3. **设备差异**: 不同设备的性能表现可能有差异
4. **iOS版本**: async/await版本需要iOS 13.0+

## 扩展测试

如需添加更多测试场景，可以：
1. 在现有测试类中添加新的测试方法
2. 创建新的测试类专门测试特定功能
3. 修改测试参数以适应不同的测试需求

## 问题排查

如果测试失败，请检查：
1. 项目配置是否正确
2. 模拟器或设备是否可用
3. 测试超时设置是否合理
4. 内存是否充足
