# AITextView 性能测试总结

## 已完成的工作

### 1. 创建了三个性能测试文件

#### AITextViewTests.swift (更新)
- 添加了 `testLargeContentRendering()` 方法
- 测试10万字符的渲染性能
- 包含基本的性能验证

#### AITextViewQuickPerformanceTests.swift (新建)
- 专门用于快速性能测试
- 测试10万到50万字符的渲染性能（1万字符递增）
- 包含内存监控和性能分析
- 提供详细的性能报告

#### AITextViewPerformanceTests.swift (新建)
- 完整的性能测试套件
- 包含详细的内存监控工具
- 支持自定义测试参数

### 2. 测试功能特性

#### 基础HTML模板
- 使用与 ViewController.swift 中相同的丰富HTML内容
- 包含标题、文本格式、颜色、列表、对齐、链接、图片、表格等
- 字符数约 1,500 字符

#### 测试范围
- **字符数**: 100,000 - 500,000 字符
- **递增步长**: 10,000 字符
- **测试次数**: 41 次测试

#### 性能监控
- **渲染时间**: 从设置HTML到渲染完成的时间
- **内存使用**: 渲染过程中的内存占用变化
- **渲染速度**: 字符数/渲染时间

### 3. 性能指标验证

#### 预期性能
- 渲染时间 < 15秒（50万字符）
- 内存使用 < 300MB（50万字符）
- 渲染速度 > 1,000字符/秒

#### 测试验证
- 每个测试都会验证性能指标
- 失败时会显示具体的性能数据
- 提供详细的性能报告

### 4. 辅助工具

#### 内存监控
```swift
private func getCurrentMemoryUsage() -> Double
```
- 使用 `mach_task_basic_info` 获取准确的内存使用量
- 返回MB为单位的内存使用量

#### 内容生成
```swift
private func generateHTMLContent(targetCharacterCount: Int) -> String
```
- 根据目标字符数生成测试HTML内容
- 通过重复基础模板达到目标字符数

#### 性能报告
```swift
private func printPerformanceReport(results: [...])
```
- 输出格式化的性能报告
- 包含字符数、渲染时间、内存使用、性能等指标
- 计算平均统计数据

### 5. 文档和脚本

#### PERFORMANCE_TESTING_README.md
- 详细的测试说明文档
- 包含如何运行测试的指令
- 性能指标说明和故障排除指南

#### run_performance_tests.sh
- 自动化测试运行脚本
- 支持在模拟器上运行所有测试
- 提供测试结果摘要

## 使用方法

### 运行所有测试
```bash
# 在 Xcode 中
⌘ + U

# 或使用脚本
./run_performance_tests.sh
```

### 运行特定测试
```bash
# 运行性能测试
xcodebuild test -scheme AITextViewUIKIT -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AITextViewUIKITTests/AITextViewQuickPerformanceTests/testLargeContentRenderingPerformance
```

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

## 自定义配置

### 修改测试范围
```swift
// 在 AITextViewQuickPerformanceTests.swift 中
let testCases = stride(from: 50_000, through: 1_000_000, by: 50_000)
```

### 调整性能阈值
```swift
// 在 validatePerformanceResults 方法中
XCTAssertLessThan(result.renderTime, 20.0, "渲染时间阈值")
XCTAssertLessThan(result.memoryUsage, 500.0, "内存使用阈值")
```

## 文件结构

```
AITextViewUIKITTests/
├── AITextViewTests.swift                    # 基础测试（已更新）
├── AITextViewQuickPerformanceTests.swift    # 快速性能测试
├── AITextViewPerformanceTests.swift         # 完整性能测试
├── AITextToolbarTests.swift                 # 工具栏测试
└── PERFORMANCE_TESTING_README.md            # 测试说明文档

../run_performance_tests.sh                  # 测试运行脚本
../PERFORMANCE_TESTS_SUMMARY.md              # 本总结文档
```

## 下一步建议

1. **真机测试**: 在真机上运行测试以获得准确的性能数据
2. **压力测试**: 可以增加更大的字符数测试（如100万字符）
3. **内存优化**: 根据测试结果优化内存使用
4. **性能优化**: 根据测试结果优化渲染性能
5. **自动化**: 将性能测试集成到CI/CD流程中
