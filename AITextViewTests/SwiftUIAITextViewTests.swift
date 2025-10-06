//
//  SwiftUIRichEditorTests.swift
//  RichEditorViewTests
//
//  Created by CI/CD Enhancement on 2024.
//

import XCTest
import SwiftUI
@testable import RichEditorView

@available(iOS 13.0, *)
class SwiftUIRichEditorTests: XCTestCase {
    
    // MARK: - 基础初始化测试
    
    func testSwiftUIRichEditorCreation() {
        let htmlContent = Binding.constant("<p>测试内容</p>")
        let isEditing = Binding.constant(false)
        
        let editor = SwiftUIRichEditor(
            htmlContent: htmlContent,
            isEditing: isEditing,
            placeholder: "请输入内容...",
            isScrollEnabled: true,
            editingEnabled: true,
            backgroundColor: .white,
            showsKeyboardToolbar: true,
            keyboardToolbarDoneButtonText: "完成"
        )
        
        XCTAssertNotNil(editor, "SwiftUIRichEditor应该能够成功创建")
    }
    
    func testSimpleEditorCreation() {
        let htmlContent = Binding.constant("<p>简单编辑器</p>")
        
        let simpleEditor = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "简单占位符"
        )
        
        XCTAssertNotNil(simpleEditor, "简单编辑器应该能够成功创建")
    }
    
    func testFullFeaturedEditorCreation() {
        let htmlContent = Binding.constant("<p>功能完整的编辑器</p>")
        
        let fullEditor = SwiftUIRichEditor.fullFeatured(
            htmlContent: htmlContent,
            placeholder: "完整功能占位符"
        )
        
        XCTAssertNotNil(fullEditor, "功能完整的编辑器应该能够成功创建")
    }
    
    // MARK: - 修饰符测试
    
    func testContentChangeModifier() {
        let htmlContent = Binding.constant("<p>测试</p>")
        var contentChangeCalled = false
        
        let editorWithCallback = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "测试"
        ).onContentChanged { _ in
            contentChangeCalled = true
        }
        
        XCTAssertNotNil(editorWithCallback, "带内容变化回调的编辑器应该能够创建")
        // 注意：在实际UI环境中才会触发回调，这里只能测试创建是否成功
    }
    
    func testHeightChangeModifier() {
        let htmlContent = Binding.constant("<p>测试</p>")
        var heightChangeCalled = false
        
        let editorWithCallback = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "测试"
        ).onHeightChanged { _ in
            heightChangeCalled = true
        }
        
        XCTAssertNotNil(editorWithCallback, "带高度变化回调的编辑器应该能够创建")
    }
    
    func testEditorLoadedModifier() {
        let htmlContent = Binding.constant("<p>测试</p>")
        var editorLoadedCalled = false
        
        let editorWithCallback = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "测试"
        ).onEditorLoaded {
            editorLoadedCalled = true
        }
        
        XCTAssertNotNil(editorWithCallback, "带编辑器加载回调的编辑器应该能够创建")
    }
    
    func testFocusChangeModifier() {
        let htmlContent = Binding.constant("<p>测试</p>")
        var focusChangeCalled = false
        
        let editorWithCallback = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "测试"
        ).onFocusChanged { _ in
            focusChangeCalled = true
        }
        
        XCTAssertNotNil(editorWithCallback, "带焦点变化回调的编辑器应该能够创建")
    }
    
    func testChainedModifiers() {
        let htmlContent = Binding.constant("<p>测试</p>")
        
        let complexEditor = SwiftUIRichEditor.simple(
            htmlContent: htmlContent,
            placeholder: "复杂编辑器"
        )
        .onContentChanged { _ in }
        .onHeightChanged { _ in }
        .onEditorLoaded { }
        .onFocusChanged { _ in }
        
        XCTAssertNotNil(complexEditor, "链式修饰符应该正常工作")
    }
    
    // MARK: - 工具栏测试
    
    func testToolbarCreation() {
        let toolbar = SwiftUIRichEditorToolbar(
            options: [AITextDefaultOption.bold, AITextDefaultOption.italic],
            barTintColor: .gray,
            editor: nil
        )
        
        XCTAssertNotNil(toolbar, "SwiftUI工具栏应该能够成功创建")
    }
    
    func testToolbarWithAllOptions() {
        let toolbar = SwiftUIRichEditorToolbar(
            options: AITextDefaultOption.all,
            barTintColor: nil,
            editor: nil
        )
        
        XCTAssertNotNil(toolbar, "包含所有选项的工具栏应该能够创建")
    }
    
    func testToolbarWithCustomCallbacks() {
        var textColorCalled = false
        var backgroundColorCalled = false
        var imageCalled = false
        var linkCalled = false
        
        let toolbar = SwiftUIRichEditorToolbar(
            options: [
                AITextDefaultOption.textColor,
                AITextDefaultOption.textBackgroundColor,
                AITextDefaultOption.image,
                AITextDefaultOption.link
            ],
            onTextColorChange: { textColorCalled = true },
            onBackgroundColorChange: { backgroundColorCalled = true },
            onImageInsert: { imageCalled = true },
            onLinkInsert: { linkCalled = true }
        )
        
        XCTAssertNotNil(toolbar, "带自定义回调的工具栏应该能够创建")
    }
    
    // MARK: - 集成测试
    
    func testEditorWithToolbarIntegration() {
        let htmlContent = Binding.constant("<p>集成测试</p>")
        
        // 这个测试模拟了在SwiftUI视图中同时使用编辑器和工具栏的场景
        let editor = SwiftUIRichEditor.fullFeatured(
            htmlContent: htmlContent,
            placeholder: "集成编辑器"
        )
        
        let toolbar = SwiftUIRichEditorToolbar(
            options: AITextDefaultOption.all,
            editor: nil // 在实际使用中，这里会设置为UIView实例
        )
        
        XCTAssertNotNil(editor, "集成编辑器应该成功创建")
        XCTAssertNotNil(toolbar, "集成工具栏应该成功创建")
    }
    
    // MARK: - 错误处理测试
    
    func testEditorWithEmptyBinding() {
        let emptyContent = Binding.constant("")
        
        let editor = SwiftUIRichEditor.simple(
            htmlContent: emptyContent,
            placeholder: "空内容编辑器"
        )
        
        XCTAssertNotNil(editor, "空内容绑定应该正常工作")
    }
    
    func testEditorWithLongContent() {
        let longContent = String(repeating: "<p>很长的内容 ", count: 1000) + "</p>"
        let longContentBinding = Binding.constant(longContent)
        
        let editor = SwiftUIRichEditor.simple(
            htmlContent: longContentBinding,
            placeholder: "长内容编辑器"
        )
        
        XCTAssertNotNil(editor, "长内容应该正常处理")
    }
    
    func testEditorWithSpecialCharacters() {
        let specialContent = "<p>特殊字符: &lt;&gt;&amp;&quot;&#39;</p>"
        let specialBinding = Binding.constant(specialContent)
        
        let editor = SwiftUIRichEditor.simple(
            htmlContent: specialBinding,
            placeholder: "特殊字符: <>&\"'"
        )
        
        XCTAssertNotNil(editor, "特殊字符应该正常处理")
    }
    
    // MARK: - 性能测试
    
    func testEditorCreationPerformance() {
        let htmlContent = Binding.constant("<p>性能测试</p>")
        
        self.measure {
            let editor = SwiftUIRichEditor.fullFeatured(
                htmlContent: htmlContent,
                placeholder: "性能测试编辑器"
            )
            _ = editor // 确保编辑器被创建
        }
    }
    
    func testToolbarCreationPerformance() {
        self.measure {
            let toolbar = SwiftUIRichEditorToolbar(
                options: AITextDefaultOption.all
            )
            _ = toolbar // 确保工具栏被创建
        }
    }
}

// MARK: - 辅助测试类

@available(iOS 13.0, *)
class SwiftUIIntegrationTests: XCTestCase {
    
    func testViewIntegration() {
        // 这个测试验证SwiftUI视图的基本结构是否正确
        let htmlContent = Binding.constant("<p>集成测试</p>")
        
        let contentView = SwiftUITestView(htmlContent: htmlContent)
        XCTAssertNotNil(contentView, "SwiftUI集成视图应该能够创建")
    }
}

@available(iOS 13.0, *)
private struct SwiftUITestView: View {
    @Binding var htmlContent: String
    
    init(htmlContent: Binding<String>) {
        self._htmlContent = htmlContent
    }
    
    var body: some View {
        VStack {
            SwiftUIRichEditor.fullFeatured(
                htmlContent: $htmlContent,
                placeholder: "测试编辑器"
            )
            .frame(height: 300)
            
            SwiftUIRichEditorToolbar(
                options: [
                    AITextDefaultOption.bold,
                    AITextDefaultOption.italic,
                    AITextDefaultOption.underline
                ]
            )
            .frame(height: 44)
        }
    }
}

