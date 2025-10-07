//
//  AITextToolbarTests.swift
//  AITextViewUIKITTests
//
//  Created by yunning you on 2025/10/7.
//

import UIKit
import XCTest
import AITextView
@testable import AITextViewUIKIT

class AITextToolbarTests: XCTestCase {
    
    var toolbar: AITextToolbar!
    var editorView: AITextView!
    var mockDelegate: MockToolbarDelegate!
    
    override func setUp() {
        super.setUp()
        toolbar = AITextToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        editorView = AITextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        mockDelegate = MockToolbarDelegate()
        
        toolbar.editor = editorView
        toolbar.delegate = mockDelegate
    }
    
    override func tearDown() {
        toolbar = nil
        editorView = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - 基础初始化测试
    
    func testToolbarInitialization() {
        XCTAssertNotNil(toolbar, "AITextToolbar应该能够成功初始化")
        XCTAssertEqual(toolbar.frame.size, CGSize(width: 320, height: 44), "工具栏应该有正确的frame大小")
        XCTAssertEqual(toolbar.options.count, 0, "默认选项数组应该为空")
    }
    
    func testEditorAssignment() {
        XCTAssertNotNil(toolbar.editor, "编辑器应该正确关联")
        XCTAssertTrue(toolbar.editor === editorView, "编辑器引用应该正确")
    }
    
    func testDelegateAssignment() {
        XCTAssertNotNil(toolbar.delegate, "代理应该正确设置")
        XCTAssertTrue(toolbar.delegate === mockDelegate, "代理引用应该正确")
    }
    
    // MARK: - 选项配置测试
    
    func testEmptyOptions() {
        toolbar.options = []
        XCTAssertEqual(toolbar.options.count, 0, "空选项数组应该正确设置")
    }
    
    func testSingleOption() {
        toolbar.options = [AITextDefaultOption.bold]
        XCTAssertEqual(toolbar.options.count, 1, "单个选项应该正确设置")
    }
    
    func testMultipleOptions() {
        let options: [AITextOption] = [
            AITextDefaultOption.bold,
            AITextDefaultOption.italic,
            AITextDefaultOption.underline
        ]
        toolbar.options = options
        XCTAssertEqual(toolbar.options.count, 3, "多个选项应该正确设置")
    }
    
    func testAllDefaultOptions() {
        toolbar.options = AITextDefaultOption.all
        XCTAssertGreaterThan(toolbar.options.count, 10, "所有默认选项应该包含多个选项")
    }
    
    // MARK: - 默认选项测试
    
    func testBoldOption() {
        let boldOption = AITextDefaultOption.bold
        XCTAssertNotNil(boldOption.image, "粗体选项应该有图标")
        XCTAssertEqual(boldOption.title, "Bold", "粗体选项标题应该正确")
        
        // 测试操作不会崩溃
        XCTAssertNoThrow(boldOption.action(toolbar), "粗体操作应该安全执行")
    }
    
    func testItalicOption() {
        let italicOption = AITextDefaultOption.italic
        XCTAssertNotNil(italicOption.image, "斜体选项应该有图标")
        XCTAssertEqual(italicOption.title, "Italic", "斜体选项标题应该正确")
        XCTAssertNoThrow(italicOption.action(toolbar), "斜体操作应该安全执行")
    }
    
    func testUnderlineOption() {
        let underlineOption = AITextDefaultOption.underline
        XCTAssertNotNil(underlineOption.image, "下划线选项应该有图标")
        XCTAssertEqual(underlineOption.title, "Underline", "下划线选项标题应该正确")
        XCTAssertNoThrow(underlineOption.action(toolbar), "下划线操作应该安全执行")
    }
    
    func testHeaderOptions() {
        for level in 1...6 {
            let headerOption = AITextDefaultOption.header(level)
            XCTAssertNotNil(headerOption.image, "标题H\(level)选项应该有图标")
            XCTAssertEqual(headerOption.title, "H\(level)", "标题H\(level)选项标题应该正确")
            XCTAssertNoThrow(headerOption.action(toolbar), "标题H\(level)操作应该安全执行")
        }
    }
    
    func testListOptions() {
        let orderedListOption = AITextDefaultOption.orderedList
        XCTAssertNotNil(orderedListOption.image, "有序列表选项应该有图标")
        XCTAssertEqual(orderedListOption.title, "Ordered List", "有序列表选项标题应该正确")
        
        let unorderedListOption = AITextDefaultOption.unorderedList
        XCTAssertNotNil(unorderedListOption.image, "无序列表选项应该有图标")
        XCTAssertEqual(unorderedListOption.title, "Unordered List", "无序列表选项标题应该正确")
    }
    
    func testColorOptions() {
        let textColorOption = AITextDefaultOption.textColor
        XCTAssertNotNil(textColorOption.image, "文字颜色选项应该有图标")
        XCTAssertEqual(textColorOption.title, "Text Color", "文字颜色选项标题应该正确")
        
        let bgColorOption = AITextDefaultOption.textBackgroundColor
        XCTAssertNotNil(bgColorOption.image, "背景颜色选项应该有图标")
        XCTAssertEqual(bgColorOption.title, "Text Background Color", "背景颜色选项标题应该正确")
    }
    
    // MARK: - 自定义选项测试
    
    func testCustomOptionItem() {
        let customImage = UIImage()
        let customTitle = "自定义选项"
        var actionCalled = false
        
        let customOption = AITextOptionItem(image: customImage, title: customTitle) { _ in
            actionCalled = true
        }
        
        XCTAssertTrue(customOption.image === customImage, "自定义选项图标应该正确")
        XCTAssertEqual(customOption.title, customTitle, "自定义选项标题应该正确")
        
        // 测试操作调用
        customOption.action(toolbar)
        XCTAssertTrue(actionCalled, "自定义选项操作应该被调用")
    }
    
    func testCustomOptionWithoutImage() {
        let customTitle = "无图标选项"
        let customOption = AITextOptionItem(image: nil, title: customTitle) { _ in }
        
        XCTAssertNil(customOption.image, "自定义选项应该可以没有图标")
        XCTAssertEqual(customOption.title, customTitle, "无图标选项标题应该正确")
    }
    
    // MARK: - 工具栏外观测试
    
    func testBarTintColor() {
        let testColor = UIColor.blue
        toolbar.barTintColor = testColor
        XCTAssertEqual(toolbar.barTintColor, testColor, "工具栏背景色应该正确设置")
    }
    
    func testDefaultBarTintColor() {
        XCTAssertNil(toolbar.barTintColor, "默认工具栏背景色应该为nil")
    }
    
    // MARK: - 代理方法测试
    
    func testTextColorChangeDelegate() {
        toolbar.options = [AITextDefaultOption.textColor]
        let textColorOption = AITextDefaultOption.textColor
        
        textColorOption.action(toolbar)
        XCTAssertTrue(mockDelegate.textColorChangeCalled, "文字颜色变化代理方法应该被调用")
    }
    
    func testBackgroundColorChangeDelegate() {
        toolbar.options = [AITextDefaultOption.textBackgroundColor]
        let bgColorOption = AITextDefaultOption.textBackgroundColor
        
        bgColorOption.action(toolbar)
        XCTAssertTrue(mockDelegate.backgroundColorChangeCalled, "背景颜色变化代理方法应该被调用")
    }
    
    func testImageInsertDelegate() {
        toolbar.options = [AITextDefaultOption.image]
        let imageOption = AITextDefaultOption.image
        
        imageOption.action(toolbar)
        XCTAssertTrue(mockDelegate.imageInsertCalled, "图片插入代理方法应该被调用")
    }
    
    func testLinkInsertDelegate() {
        toolbar.options = [AITextDefaultOption.link]
        let linkOption = AITextDefaultOption.link
        
        linkOption.action(toolbar)
        XCTAssertTrue(mockDelegate.linkInsertCalled, "链接插入代理方法应该被调用")
    }
    
    // MARK: - 性能测试
    
    func testToolbarInitializationPerformance() {
        self.measure {
            let testToolbar = AITextToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
            testToolbar.options = AITextDefaultOption.all
        }
    }
    
    func testOptionsUpdatePerformance() {
        self.measure {
            toolbar.options = AITextDefaultOption.all
        }
    }
    
    // MARK: - 边界测试
    
    func testLargeNumberOfOptions() {
        var manyOptions: [AITextOption] = []
        for i in 1...100 {
            let option = AITextOptionItem(image: nil, title: "选项\(i)") { _ in }
            manyOptions.append(option)
        }
        
        XCTAssertNoThrow(toolbar.options = manyOptions, "设置大量选项应该安全")
        XCTAssertEqual(toolbar.options.count, 100, "应该正确设置所有选项")
    }
    
    func testNilEditorReference() {
        toolbar.editor = nil
        let boldOption = AITextDefaultOption.bold
        
        // 应该不会崩溃，即使editor为nil
        XCTAssertNoThrow(boldOption.action(toolbar), "nil编辑器引用应该安全处理")
    }
}

// MARK: - Mock Toolbar Delegate

class MockToolbarDelegate: NSObject, AITextToolbarDelegate {
    var textColorChangeCalled = false
    var backgroundColorChangeCalled = false
    var imageInsertCalled = false
    var linkInsertCalled = false
    
    func aiTextToolbarChangeTextColor(_ toolbar: AITextToolbar) {
        textColorChangeCalled = true
        // 模拟选择颜色
        toolbar.editor?.setTextColor(.red)
    }
    
    func aiTextToolbarChangeBackgroundColor(_ toolbar: AITextToolbar) {
        backgroundColorChangeCalled = true
        // 模拟选择背景颜色
        toolbar.editor?.setTextBackgroundColor(.yellow)
    }
    
    func aiTextToolbarInsertImage(_ toolbar: AITextToolbar) {
        imageInsertCalled = true
        // 模拟插入图片
        toolbar.editor?.insertImage("test-image.png", alt: "测试图片")
    }
    
    func aiTextToolbarInsertLink(_ toolbar: AITextToolbar) {
        linkInsertCalled = true
        // 模拟插入链接
        toolbar.editor?.insertLink("https://example.com", title: "示例链接")
    }
}

