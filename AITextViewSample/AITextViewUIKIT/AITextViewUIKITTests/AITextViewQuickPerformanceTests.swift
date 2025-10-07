//
//  AITextViewQuickPerformanceTests.swift
//  AITextViewUIKITTests
//
//  Created by yunning you on 2025/10/7.
//

import UIKit
import XCTest
import WebKit
import AITextView
import MachO
@testable import AITextViewUIKIT

// MARK: - Memory 工具类
class Memory {
    /// 获取当前进程的内存占用（字节）
    static func memoryFootprint() -> UInt64? {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return nil }
        return info.phys_footprint
    }
    
    /// 获取当前进程的内存占用（MB）
    static func memoryFootprintMB() -> Double? {
        guard let footprint = memoryFootprint() else { return nil }
        return Double(footprint) / 1024.0 / 1024.0
    }
}

class AITextViewQuickPerformanceTests: XCTestCase {
    
    var aiTextView: AITextView!
    
    // 基础HTML模板
    private let baseHTMLTemplate = """
        <h1>🎯 AITextView 性能测试</h1>
        <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
        <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
        <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
        <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
        <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
        <h2>📋 标题级别测试</h2>
        <h1>一级标题 H1</h1>
        <h2>二级标题 H2</h2>
        <h3>三级标题 H3</h3>
        <h4>四级标题 H4</h4>
        <h5>五级标题 H5</h5>
        <h6>六级标题 H6</h6>
        <h2>📝 列表测试</h2>
        <h3>有序列表 Ordered List:</h3>
        <ol>
            <li>第一项 First Item</li>
            <li>第二项 Second Item</li>
            <li>第三项 Third Item
                <ol>
                    <li>嵌套项 1 Nested Item 1</li>
                    <li>嵌套项 2 Nested Item 2</li>
                </ol>
            </li>
        </ol>
        <h3>无序列表 Unordered List:</h3>
        <ul>
            <li>项目 A Item A</li>
            <li>项目 B Item B</li>
            <li>项目 C Item C
                <ul>
                    <li>子项目 1 Sub Item 1</li>
                    <li>子项目 2 Sub Item 2</li>
                </ul>
            </li>
        </ul>
        <h2>📐 对齐方式测试</h2>
        <p style="text-align: left;">⬅️ 左对齐文本 Left Aligned Text</p>
        <p style="text-align: center;">🎯 居中对齐文本 Center Aligned Text</p>
        <p style="text-align: right;">➡️ 右对齐文本 Right Aligned Text</p>
        <p style="text-align: justify;">📏 两端对齐文本 Justified Text - This is a longer paragraph to demonstrate justified text alignment. The text should be evenly distributed across the width of the container, creating straight edges on both sides.</p>
        <h2>🔗 链接和媒体测试</h2>
        <p>访问 <a href="https://github.com/youyinian288/AITextView">AITextView GitHub 仓库</a></p>
        <p>查看 <a href="https://www.apple.com">Apple 官网</a> 了解更多信息</p>
        <p>这是一个 <a href="mailto:test@example.com">邮箱链接</a> 和 <a href="tel:+1234567890">电话链接</a></p>
        <h2>🖼️ 图片测试</h2>
        <p>网络图片示例：</p>
        <img src="https://picsum.photos/200/150?random=1" alt="随机网络图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        <p>Base64 图片示例：</p>
        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        <h2>💬 引用和特殊格式</h2>
        <blockquote>
            <p>"这是一个引用块，用于突出显示重要内容或引用他人的话语。"</p>
            <p style="text-align: right; font-style: italic;">— 作者名称</p>
        </blockquote>
        <h2>📊 表格测试</h2>
        <table border="1" style="border-collapse: collapse; width: 100%;">
            <tr>
                <th style="background-color: #f0f0f0; padding: 8px;">功能 Feature</th>
                <th style="background-color: #f0f0f0; padding: 8px;">支持 Support</th>
                <th style="background-color: #f0f0f0; padding: 8px;">说明 Description</th>
            </tr>
            <tr>
                <td style="padding: 8px;">粗体 Bold</td>
                <td style="padding: 8px; text-align: center;">✅</td>
                <td style="padding: 8px;">支持粗体文本格式</td>
            </tr>
            <tr>
                <td style="padding: 8px;">斜体 Italic</td>
                <td style="padding: 8px; text-align: center;">✅</td>
                <td style="padding: 8px;">支持斜体文本格式</td>
            </tr>
            <tr>
                <td style="padding: 8px;">列表 Lists</td>
                <td style="padding: 8px; text-align: center;">✅</td>
                <td style="padding: 8px;">支持有序和无序列表</td>
            </tr>
        </table>
        <h2>🎯 特殊字符和符号</h2>
        <p>数学符号: ∑ ∫ ∏ ∆ ∇ ∞ ≤ ≥ ≠ ≈ ± × ÷</p>
        <p>箭头符号: ← → ↑ ↓ ↔ ↕ ⇐ ⇒ ⇑ ⇓</p>
        <p>货币符号: $ € £ ¥ ₹ ₽</p>
        <p>其他符号: © ® ™ § ¶ † ‡ • ◦ ◊</p>
        <h2>📱 响应式测试</h2>
        <p style="font-size: 12px;">小字体 Small Font (12px)</p>
        <p style="font-size: 16px;">正常字体 Normal Font (16px)</p>
        <p style="font-size: 20px;">大字体 Large Font (20px)</p>
        <p style="font-size: 24px;">超大字体 Extra Large Font (24px)</p>
        <h2>🎨 混合格式测试</h2>
        <p><b><i><u>粗体斜体下划线 Bold Italic Underlined</u></i></b> | <span style="color: red; background-color: yellow;"><b>红字黄底粗体 Red Yellow Bold</b></span></p>
        <p><s><i>删除线斜体 Strikethrough Italic</i></s> | <u><span style="color: blue;">下划线蓝色 Underlined Blue</span></u></p>
        <h2>📝 段落和换行测试</h2>
        <p>这是第一个段落。包含多行文本，用于测试段落的显示效果。AITextView 应该能够正确处理段落间距和换行。</p>
        <p>这是第二个段落。用于测试多个段落之间的间距和格式。每个段落都应该有适当的间距。</p>
        <p>这是第三个段落。<br>这里有一个手动换行。<br>用于测试 <code>br</code> 标签的效果。</p>
        <h2>🔧 代码和预格式化文本</h2>
        <p>内联代码: <code>console.log("Hello World")</code></p>
        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;">
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        </pre>
        <h2>🎉 测试完成</h2>
        <p>这个HTML包含了AITextView支持的大部分功能。请使用工具栏测试各种编辑功能，包括：</p>
        <ul>
            <li>文本格式（粗体、斜体、下划线、删除线）</li>
            <li>颜色和背景色</li>
            <li>标题级别</li>
            <li>列表和缩进</li>
            <li>对齐方式</li>
            <li>链接插入</li>
            <li>图片插入（网络图片、Base64图片）</li>
            <li>撤销重做</li>
            <li>键盘工具栏</li>
        </ul>
        <p style="text-align: center; color: #666; font-style: italic;">
            🚀 开始测试 AITextView 的强大功能吧！
        </p>
        """
    
    override func setUp() {
        super.setUp()
        aiTextView = AITextView(frame: CGRect(x: 0, y: 0, width: 375, height: 600))
    }
    
    override func tearDown() {
        aiTextView = nil
        super.tearDown()
    }
    
    // MARK: - 内存监控工具
    
    /// 获取当前内存使用量（MB）
    private func getCurrentMemoryUsage() -> Double {
        return Memory.memoryFootprintMB() ?? 0.0
    }
    
    /// 获取更准确的内存使用量（包含虚拟内存）
    private func getDetailedMemoryUsage() -> (resident: Double, virtual: Double) {
        // 使用新的 Memory 类获取物理内存占用
        let residentMB = Memory.memoryFootprintMB() ?? 0.0
        
        // 对于虚拟内存，我们仍然使用原来的方法
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        let virtualMB = (kerr == KERN_SUCCESS) ? Double(info.virtual_size) / 1024.0 / 1024.0 : 0.0
        
        return (resident: residentMB, virtual: virtualMB)
    }
    
    /// 生成指定字符数的HTML内容
    private func generateHTMLContent(targetCharacterCount: Int) -> String {
        let baseLength = baseHTMLTemplate.count
        let repeatCount = max(1, targetCharacterCount / baseLength)
        let repeatedContent = String(repeating: baseHTMLTemplate, count: repeatCount)
        
        // 如果还需要更多字符，添加部分内容
        let remainingChars = targetCharacterCount - repeatedContent.count
        if remainingChars > 0 {
            let partialContent = String(baseHTMLTemplate.prefix(remainingChars))
            return repeatedContent + partialContent
        }
        
        return repeatedContent
    }
    
    // MARK: - 性能测试方法
    
    /// 测试内存测量准确性（用于调试负内存问题）
    func testMemoryMeasurementAccuracy() {
        print("🔍 测试内存测量准确性...")
        
        // 测试1: 基础内存测量
        let memory1 = getCurrentMemoryUsage()
        let detailed1 = getDetailedMemoryUsage()
        print("📊 基础内存 - 常驻: \(String(format: "%.2f", memory1))MB, 详细: 常驻\(String(format: "%.2f", detailed1.resident))MB, 虚拟\(String(format: "%.2f", detailed1.virtual))MB")
        
        // 测试2: 分配内存后测量
        let testString = String(repeating: "A", count: 100_000)
        let memory2 = getCurrentMemoryUsage()
        let detailed2 = getDetailedMemoryUsage()
        print("📊 分配100K字符后 - 常驻: \(String(format: "%.2f", memory2))MB, 详细: 常驻\(String(format: "%.2f", detailed2.resident))MB, 虚拟\(String(format: "%.2f", detailed2.virtual))MB")
        print("📈 内存变化: \(String(format: "%.2f", memory2 - memory1))MB")
        
        // 测试3: 设置AITextView内容
        aiTextView.html = testString
        let expectation = self.expectation(description: "内容设置完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let memory3 = self.getCurrentMemoryUsage()
            let detailed3 = self.getDetailedMemoryUsage()
            print("📊 设置AITextView后 - 常驻: \(String(format: "%.2f", memory3))MB, 详细: 常驻\(String(format: "%.2f", detailed3.resident))MB, 虚拟\(String(format: "%.2f", detailed3.virtual))MB")
            print("📈 内存变化: \(String(format: "%.2f", memory3 - memory2))MB")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    /// 测试10万到50万字符的渲染性能（1万字符递增）
    func testLargeContentRenderingPerformance() {
        let testCases = stride(from: 100_000, through: 500_000, by: 10_000)
        var performanceResults: [(characterCount: Int, renderTime: TimeInterval, memoryUsage: Double)] = []
        
        // 创建详细的测试日志
        var detailedLog = ""
        detailedLog += "🚀 AITextView 大内容渲染性能测试开始\n"
        detailedLog += "测试时间: \(Date())\n"
        detailedLog += String(repeating: "=", count: 60) + "\n\n"
        
        for characterCount in testCases {
            let testInfo = "🧪 测试字符数: \(characterCount)\n"
            print(testInfo)
            detailedLog += testInfo
            
            // 生成测试内容
            let testHTML = generateHTMLContent(targetCharacterCount: characterCount)
            let actualCountInfo = "📝 实际生成字符数: \(testHTML.count)\n"
            print(actualCountInfo)
            detailedLog += actualCountInfo
            
            // 预热：清空内容并等待
            self.aiTextView.html = ""
            let warmupExpectation = self.expectation(description: "预热完成")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                warmupExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 1.0)
            
            // 记录开始时间和内存（在设置内容前）
            let startTime = CFAbsoluteTimeGetCurrent()
            let startMemory = self.getCurrentMemoryUsage()
            let startDetailed = self.getDetailedMemoryUsage()
            
            // 执行渲染
            self.aiTextView.html = testHTML
            
            // 等待渲染完成（增加等待时间确保渲染完成）
            let expectation = self.expectation(description: "内容渲染完成")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5.0) { _ in
                let endTime = CFAbsoluteTimeGetCurrent()
                let endMemory = self.getCurrentMemoryUsage()
                let endDetailed = self.getDetailedMemoryUsage()
                
                let renderTime = endTime - startTime
                let memoryUsage = endMemory - startMemory
                let virtualMemoryUsage = endDetailed.virtual - startDetailed.virtual
                
                let result = (characterCount: characterCount, 
                             renderTime: renderTime, 
                             memoryUsage: memoryUsage)
                performanceResults.append(result)
                
                let renderTimeInfo = "⏱️ 渲染时间: \(String(format: "%.3f", renderTime))秒\n"
                let memoryInfo = "💾 常驻内存变化: \(String(format: "%.2f", memoryUsage))MB\n"
                let virtualMemoryInfo = "🌐 虚拟内存变化: \(String(format: "%.2f", virtualMemoryUsage))MB\n"
                let performanceInfo = "📊 字符/秒: \(String(format: "%.0f", Double(characterCount) / renderTime))\n"
                let memoryDetailsInfo = "📈 内存详情 - 开始: 常驻\(String(format: "%.2f", startDetailed.resident))MB/虚拟\(String(format: "%.2f", startDetailed.virtual))MB, 结束: 常驻\(String(format: "%.2f", endDetailed.resident))MB/虚拟\(String(format: "%.2f", endDetailed.virtual))MB\n"
                
                print(renderTimeInfo)
                print(memoryInfo)
                print(virtualMemoryInfo)
                print(performanceInfo)
                print(memoryDetailsInfo)
                
                detailedLog += renderTimeInfo
                detailedLog += memoryInfo
                detailedLog += virtualMemoryInfo
                detailedLog += performanceInfo
                detailedLog += memoryDetailsInfo
                detailedLog += "\n"
                
                // 在每次测试完成后立即写入文件
                self.saveDetailedLogToFile(detailedLog)
            }
        }
        
        // 等待所有测试完成后再输出性能报告
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 输出性能报告
            self.printPerformanceReport(results: performanceResults)
            
            // 验证性能指标
            self.validatePerformanceResults(results: performanceResults)
        }
    }
    
    /// 测试特定字符数的渲染性能（用于详细分析）
    func testSpecificCharacterCountPerformance() {
        let testCharacterCounts = [100_000, 200_000, 300_000, 400_000, 500_000]
        
        for characterCount in testCharacterCounts {
            print("\n🔬 详细测试字符数: \(characterCount)")
            
            let testHTML = generateHTMLContent(targetCharacterCount: characterCount)
            
            // 预热
            aiTextView.html = ""
            let warmupExpectation = self.expectation(description: "预热完成")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                warmupExpectation.fulfill()
            }
            waitForExpectations(timeout: 2.0)
            
            // 正式测试
            let startTime = CFAbsoluteTimeGetCurrent()
            let startMemory = getCurrentMemoryUsage()
            
            aiTextView.html = testHTML
            
            let expectation = self.expectation(description: "渲染完成")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5.0) { _ in
                let endTime = CFAbsoluteTimeGetCurrent()
                let endMemory = self.getCurrentMemoryUsage()
                
                let renderTime = endTime - startTime
                let memoryUsage = endMemory - startMemory
                
                print("📊 字符数: \(characterCount)")
                print("⏱️ 渲染时间: \(String(format: "%.3f", renderTime))秒")
                print("💾 内存使用: \(String(format: "%.2f", memoryUsage))MB")
                print("🚀 性能: \(String(format: "%.0f", Double(characterCount) / renderTime))字符/秒")
                
                // 验证基本性能要求
                XCTAssertLessThan(renderTime, 10.0, "\(characterCount)字符的渲染时间应该少于10秒")
                XCTAssertLessThan(memoryUsage, 200.0, "\(characterCount)字符的内存使用应该少于200MB")
            }
        }
    }
    
    /// 测试内存泄漏
    func testMemoryLeakWithLargeContent() {
        let testHTML = generateHTMLContent(targetCharacterCount: 500_000)
        
        // 记录初始内存
        let initialMemory = getCurrentMemoryUsage()
        print("🔍 初始内存: \(String(format: "%.2f", initialMemory))MB")
        
        // 设置大量内容
        aiTextView.html = testHTML
        
        let expectation = self.expectation(description: "内容设置完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { _ in
            let afterSetMemory = self.getCurrentMemoryUsage()
            print("📝 设置后内存: \(String(format: "%.2f", afterSetMemory))MB")
            
            // 清空内容
            self.aiTextView.html = ""
            
            // 等待垃圾回收
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let finalMemory = self.getCurrentMemoryUsage()
                print("🧹 清空后内存: \(String(format: "%.2f", finalMemory))MB")
                
                // 验证内存没有显著泄漏
                let memoryIncrease = finalMemory - initialMemory
                XCTAssertLessThan(memoryIncrease, 50.0, "内存泄漏应该少于50MB")
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 保存详细日志到文件
    private func saveDetailedLogToFile(_ logContent: String) {
        // 尝试多个可能的文件路径
        let possiblePaths: [URL?] = [
            // 应用沙盒 Documents 目录
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            // 应用沙盒 Library 目录
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first,
            // 临时目录
            FileManager.default.temporaryDirectory
        ]
        
        for (index, basePath) in possiblePaths.enumerated() {
            guard let path = basePath else { continue }
            
            let fileName = "AITextView_Detailed_Test_Log.txt"
            let fileURL = path.appendingPathComponent(fileName)
            
            do {
                try logContent.write(to: fileURL, atomically: true, encoding: .utf8)
                print("📄 测试日志已保存到路径 \(index + 1): \(fileURL.path)")
                return
            } catch {
                print("❌ 路径 \(index + 1) 保存失败: \(error.localizedDescription)")
            }
        }
        
        // 如果所有路径都失败，尝试保存到临时目录的子目录
        let tempDir = FileManager.default.temporaryDirectory
        let subDir = tempDir.appendingPathComponent("AITextView_Logs")
        
        do {
            try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
            let fileURL = subDir.appendingPathComponent("AITextView_Detailed_Test_Log.txt")
            try logContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("📄 测试日志已保存到临时目录: \(fileURL.path)")
        } catch {
            print("❌ 所有路径保存失败: \(error.localizedDescription)")
            // 作为最后手段，打印到控制台
            print("📝 详细日志内容:")
            print(logContent)
        }
    }
    
    /// 保存性能报告到文件
    private func savePerformanceReportToFile(_ reportContent: String) {
        // 尝试多个可能的文件路径
        let possiblePaths: [URL?] = [
            // 应用沙盒 Documents 目录
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            // 应用沙盒 Library 目录
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first,
            // 临时目录
            FileManager.default.temporaryDirectory
        ]
        
        for (index, basePath) in possiblePaths.enumerated() {
            guard let path = basePath else { continue }
            
            let fileName = "AITextView_Performance_Report.txt"
            let fileURL = path.appendingPathComponent(fileName)
            
            do {
                try reportContent.write(to: fileURL, atomically: true, encoding: .utf8)
                print("📄 性能报告已保存到路径 \(index + 1): \(fileURL.path)")
                return
            } catch {
                print("❌ 路径 \(index + 1) 保存失败: \(error.localizedDescription)")
            }
        }
        
        // 如果所有路径都失败，尝试保存到临时目录的子目录
        let tempDir = FileManager.default.temporaryDirectory
        let subDir = tempDir.appendingPathComponent("AITextView_Logs")
        
        do {
            try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: nil)
            let fileURL = subDir.appendingPathComponent("AITextView_Performance_Report.txt")
            try reportContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("📄 性能报告已保存到临时目录: \(fileURL.path)")
        } catch {
            print("❌ 所有路径保存失败: \(error.localizedDescription)")
            // 作为最后手段，打印到控制台
            print("📝 性能报告内容:")
            print(reportContent)
        }
    }
    
    /// 输出性能报告到文件
    private func printPerformanceReport(results: [(characterCount: Int, renderTime: TimeInterval, memoryUsage: Double)]) {
        // 创建性能报告内容
        var reportContent = ""
        reportContent += "\n" + String(repeating: "=", count: 60) + "\n"
        reportContent += "📊 AITextView 大内容渲染性能报告\n"
        reportContent += String(repeating: "=", count: 60) + "\n"
        reportContent += "字符数\t\t渲染时间(秒)\t内存使用(MB)\t性能(字符/秒)\n"
        reportContent += String(repeating: "-", count: 60) + "\n"
        
        for result in results {
            let performance = Double(result.characterCount) / result.renderTime
            reportContent += "\(result.characterCount)\t\t\(String(format: "%.3f", result.renderTime))\t\t\(String(format: "%.2f", result.memoryUsage))\t\t\(String(format: "%.0f", performance))\n"
        }
        
        // 计算统计信息
        let avgRenderTime = results.map { $0.renderTime }.reduce(0, +) / Double(results.count)
        let avgMemoryUsage = results.map { $0.memoryUsage }.reduce(0, +) / Double(results.count)
        let avgPerformance = results.map { Double($0.characterCount) / $0.renderTime }.reduce(0, +) / Double(results.count)
        
        reportContent += String(repeating: "-", count: 60) + "\n"
        reportContent += "📈 平均统计:\n"
        reportContent += "⏱️ 平均渲染时间: \(String(format: "%.3f", avgRenderTime))秒\n"
        reportContent += "💾 平均内存使用: \(String(format: "%.2f", avgMemoryUsage))MB\n"
        reportContent += "🚀 平均性能: \(String(format: "%.0f", avgPerformance))字符/秒\n"
        reportContent += String(repeating: "=", count: 60) + "\n"
        
        // 保存性能报告到文件
        savePerformanceReportToFile(reportContent)
        
        // 同时在控制台输出简要信息
        print("📊 性能测试完成，共测试 \(results.count) 个用例")
        print("📈 平均渲染时间: \(String(format: "%.3f", avgRenderTime))秒")
        print("💾 平均内存使用: \(String(format: "%.2f", avgMemoryUsage))MB")
        print("🚀 平均性能: \(String(format: "%.0f", avgPerformance))字符/秒")
    }
    
    /// 验证性能结果
    private func validatePerformanceResults(results: [(characterCount: Int, renderTime: TimeInterval, memoryUsage: Double)]) {
        for result in results {
            // 验证渲染时间合理
            XCTAssertLessThan(result.renderTime, 15.0, "\(result.characterCount)字符的渲染时间应该少于15秒")
            
            // 验证内存使用合理
            XCTAssertLessThan(result.memoryUsage, 300.0, "\(result.characterCount)字符的内存使用应该少于300MB")
            
            // 验证性能指标
            let performance = Double(result.characterCount) / result.renderTime
            XCTAssertGreaterThan(performance, 1000.0, "\(result.characterCount)字符的渲染性能应该大于1000字符/秒")
        }
    }
}
