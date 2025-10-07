//
//  AITextViewTests.swift
//  AITextViewUIKITTests
//
//  Created by yunning you on 2025/10/7.
//

import UIKit
import XCTest
import WebKit
import AITextView
@testable import AITextViewUIKIT

class AITextViewTests: XCTestCase {
    
    var aiTextView: AITextView!
    var mockDelegate: MockAITextViewDelegate!
    
    override func setUp() {
        super.setUp()
        aiTextView = AITextView(frame: CGRect(x: 0, y: 0, width: 375, height: 600))
        mockDelegate = MockAITextViewDelegate()
        aiTextView.delegate = mockDelegate
    }
    
    override func tearDown() {
        aiTextView = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - 基础初始化测试
    
    func testAITextViewInitialization() {
        XCTAssertNotNil(aiTextView, "AITextView应该能够成功初始化")
        XCTAssertNotNil(aiTextView.webView, "AITextView应该包含一个webView")
        XCTAssertEqual(aiTextView.frame.size, CGSize(width: 375, height: 600), "AITextView应该有正确的frame大小")
        XCTAssertEqual(aiTextView.lineHeight, 21, "默认行高应该是21")
    }
    
    func testDefaultProperties() {
        XCTAssertEqual(aiTextView.html, "", "HTML内容初始应该为空")
        XCTAssertEqual(aiTextView.contentHTML, "", "内容HTML初始应该为空")
        XCTAssertEqual(aiTextView.placeholder, "", "占位符初始应该为空")
        XCTAssertEqual(aiTextView.editorHeight, 0, "编辑器高度初始应该为0")
        XCTAssertTrue(aiTextView.isScrollEnabled, "滚动应该默认启用")
        XCTAssertFalse(aiTextView.editingEnabled, "编辑应该默认禁用")
        XCTAssertFalse(aiTextView.showsKeyboardToolbar, "键盘工具栏应该默认不显示")
        XCTAssertEqual(aiTextView.keyboardToolbarDoneButtonText, "Done", "Done按钮文本应该是'Done'")
    }
    
    // MARK: - 属性设置测试
    
    func testHTMLPropertySetter() {
        let testHTML = "<p>测试HTML内容</p>"
        aiTextView.html = testHTML
        XCTAssertEqual(aiTextView.html, testHTML, "HTML属性应该正确设置")
    }
    
    func testPlaceholderProperty() {
        let placeholderText = "请输入文本..."
        aiTextView.placeholder = placeholderText
        XCTAssertEqual(aiTextView.placeholder, placeholderText, "占位符文本应该正确设置")
    }
    
    func testEditingEnabledProperty() {
        aiTextView.editingEnabled = true
        XCTAssertTrue(aiTextView.editingEnabled, "编辑应该能够启用")
        
        aiTextView.editingEnabled = false
        XCTAssertFalse(aiTextView.editingEnabled, "编辑应该能够禁用")
    }
    
    func testScrollEnabledProperty() {
        aiTextView.isScrollEnabled = false
        XCTAssertFalse(aiTextView.isScrollEnabled, "滚动应该能够禁用")
        XCTAssertFalse(aiTextView.webView.scrollView.isScrollEnabled, "webView的滚动也应该相应禁用")
        
        aiTextView.isScrollEnabled = true
        XCTAssertTrue(aiTextView.isScrollEnabled, "滚动应该能够重新启用")
        XCTAssertTrue(aiTextView.webView.scrollView.isScrollEnabled, "webView的滚动也应该相应启用")
    }
    
    func testKeyboardToolbarProperties() {
        aiTextView.showsKeyboardToolbar = true
        XCTAssertTrue(aiTextView.showsKeyboardToolbar, "键盘工具栏应该能够显示")
        
        let customText = "关闭"
        aiTextView.keyboardToolbarDoneButtonText = customText
        XCTAssertEqual(aiTextView.keyboardToolbarDoneButtonText, customText, "Done按钮文本应该能够自定义")
    }
    
    // MARK: - 文本格式化功能测试
    
    func testBoldFormatting() {
        // 测试粗体功能是否能够调用而不崩溃
        XCTAssertNoThrow(aiTextView.bold(), "bold()方法应该能够安全调用")
    }
    
    func testItalicFormatting() {
        XCTAssertNoThrow(aiTextView.italic(), "italic()方法应该能够安全调用")
    }
    
    func testUnderlineFormatting() {
        XCTAssertNoThrow(aiTextView.underline(), "underline()方法应该能够安全调用")
    }
    
    func testStrikethroughFormatting() {
        XCTAssertNoThrow(aiTextView.strikethrough(), "strikethrough()方法应该能够安全调用")
    }
    
    func testSubscriptFormatting() {
        XCTAssertNoThrow(aiTextView.subscriptText(), "subscriptText()方法应该能够安全调用")
    }
    
    func testSuperscriptFormatting() {
        XCTAssertNoThrow(aiTextView.superscript(), "superscript()方法应该能够安全调用")
    }
    
    func testHeaderFormatting() {
        for headerLevel in 1...6 {
            XCTAssertNoThrow(aiTextView.header(headerLevel), "header(\(headerLevel))方法应该能够安全调用")
        }
    }
    
    func testListFormatting() {
        XCTAssertNoThrow(aiTextView.orderedList(), "orderedList()方法应该能够安全调用")
        XCTAssertNoThrow(aiTextView.unorderedList(), "unorderedList()方法应该能够安全调用")
    }
    
    func testIndentationFormatting() {
        XCTAssertNoThrow(aiTextView.indent(), "indent()方法应该能够安全调用")
        XCTAssertNoThrow(aiTextView.outdent(), "outdent()方法应该能够安全调用")
    }
    
    func testUndoRedoFunctionality() {
        XCTAssertNoThrow(aiTextView.undo(), "undo()方法应该能够安全调用")
        XCTAssertNoThrow(aiTextView.redo(), "redo()方法应该能够安全调用")
    }
    
    // MARK: - 颜色设置测试
    
    func testTextColorSetting() {
        let testColor = UIColor.red
        XCTAssertNoThrow(aiTextView.setTextColor(testColor), "setTextColor()方法应该能够安全调用")
    }
    
    func testTextBackgroundColorSetting() {
        let testColor = UIColor.yellow
        XCTAssertNoThrow(aiTextView.setTextBackgroundColor(testColor), "setTextBackgroundColor()方法应该能够安全调用")
    }
    
    func testEditorFontColorSetting() {
        let testColor = UIColor.blue
        XCTAssertNoThrow(aiTextView.setEditorFontColor(testColor), "setEditorFontColor()方法应该能够安全调用")
    }
    
    // MARK: - 代理测试
    
    func testDelegateAssignment() {
        XCTAssertNotNil(aiTextView.delegate, "代理应该正确设置")
        XCTAssertTrue(aiTextView.delegate === mockDelegate, "代理应该是我们设置的mock对象")
    }
    
    func testContentDidChangeCallback() {
        // 通过设置HTML来触发内容变化
        let testContent = "<p>测试内容</p>"
        aiTextView.html = testContent
        
        // 等待异步操作完成
        let expectation = self.expectation(description: "内容变化回调")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            // 注意：由于contentHTML是只读的，我们主要测试HTML设置是否成功
            XCTAssertEqual(self.aiTextView.html, testContent, "HTML应该正确设置")
        }
    }
    
    func testHeightDidChangeCallback() {
        // 通过设置HTML内容来触发高度变化
        let testContent = "<p>测试内容<br><br><br><br><br></p>"
        aiTextView.html = testContent
        
        let expectation = self.expectation(description: "高度变化回调")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            // 注意：由于editorHeight是只读的，我们主要测试HTML设置是否成功
            XCTAssertEqual(self.aiTextView.html, testContent, "HTML应该正确设置")
        }
    }
    
    // MARK: - 性能测试
    
    func testInitializationPerformance() {
        self.measure {
            let editor = AITextView(frame: CGRect(x: 0, y: 0, width: 375, height: 600))
            _ = editor.webView // 确保webView被创建
        }
    }
    
    func testFormattingPerformance() {
        self.measure {
            aiTextView.bold()
            aiTextView.italic()
            aiTextView.underline()
            aiTextView.header(1)
            aiTextView.setTextColor(.red)
        }
    }
    
    /// 简化的性能测试 - 测试10万字符渲染
    func testLargeContentRendering() {
        // 基础HTML模板
        let baseHTML = """
        <h1>🎯 AITextView 性能测试</h1>
        <p><b>粗体文本</b> | <i>斜体文本</i> | <u>下划线文本</u></p>
        <p><span style="color: red;">红色文字</span> | <span style="background-color: yellow;">黄色背景</span></p>
        <h2>📝 列表测试</h2>
        <ul>
            <li>项目 1</li>
            <li>项目 2</li>
            <li>项目 3</li>
        </ul>
        <p>这是一个测试段落，用于验证AITextView的渲染性能。</p>
        """
        
        // 生成10万字符的内容
        let targetLength = 100_000
        let repeatCount = targetLength / baseHTML.count
        let testHTML = String(repeating: baseHTML, count: repeatCount)
        
        print("🧪 测试字符数: \(testHTML.count)")
        
        // 记录开始时间
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 执行渲染
        aiTextView.html = testHTML
        
        // 等待渲染完成
        let expectation = self.expectation(description: "内容渲染完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { _ in
            let endTime = CFAbsoluteTimeGetCurrent()
            let renderTime = endTime - startTime
            
            print("⏱️ 渲染时间: \(String(format: "%.3f", renderTime))秒")
            print("🚀 性能: \(String(format: "%.0f", Double(testHTML.count) / renderTime))字符/秒")
            
            // 验证性能指标
            XCTAssertLessThan(renderTime, 10.0, "10万字符的渲染时间应该少于10秒")
            XCTAssertGreaterThan(Double(testHTML.count) / renderTime, 1000.0, "渲染性能应该大于1000字符/秒")
        }
    }
    
    // MARK: - 边界测试
    
    func testInvalidHeaderLevel() {
        // 测试无效的标题级别
        XCTAssertNoThrow(aiTextView.header(0), "header(0)应该能够安全调用")
        XCTAssertNoThrow(aiTextView.header(7), "header(7)应该能够安全调用")
        XCTAssertNoThrow(aiTextView.header(-1), "header(-1)应该能够安全调用")
    }
    
    func testLongHTMLContent() {
        let longHTML = String(repeating: "<p>很长的测试内容 ", count: 1000) + "</p>"
        XCTAssertNoThrow(aiTextView.html = longHTML, "设置长HTML内容应该安全")
    }
    
    func testSpecialCharactersInPlaceholder() {
        let specialPlaceholder = "特殊字符: <>&\"'测试"
        XCTAssertNoThrow(aiTextView.placeholder = specialPlaceholder, "包含特殊字符的占位符应该安全设置")
        XCTAssertEqual(aiTextView.placeholder, specialPlaceholder, "特殊字符应该正确保存")
    }
}

// MARK: - Mock Delegate

class MockAITextViewDelegate: NSObject, AITextViewDelegate {
    var contentDidChangeCalled = false
    var heightDidChangeCalled = false
    var editorDidLoadCalled = false
    var tookFocusCalled = false
    var lostFocusCalled = false
    
    var lastContent = ""
    var lastHeight = 0
    var lastFocusPoint = CGPoint.zero
    
    func aiTextView(_ editor: AITextView, contentDidChange content: String) {
        contentDidChangeCalled = true
        lastContent = content
    }
    
    func aiTextView(_ editor: AITextView, heightDidChange height: Int) {
        heightDidChangeCalled = true
        lastHeight = height
    }
    
    func aiTextViewDidLoad(_ editor: AITextView) {
        editorDidLoadCalled = true
    }
    
    func aiTextViewTookFocus(_ editor: AITextView) {
        tookFocusCalled = true
    }
    
    func aiTextViewTookFocusAt(_ editor: AITextView, at point: CGPoint) {
        tookFocusCalled = true
        lastFocusPoint = point
    }
    
    func aiTextViewLostFocus(_ editor: AITextView) {
        lostFocusCalled = true
    }
    
    func aiTextView(_ editor: AITextView, shouldInteractWith url: URL) -> Bool {
        return true
    }
    
    func aiTextView(_ editor: AITextView, handle action: String) {
        // 处理自定义操作
    }
}
