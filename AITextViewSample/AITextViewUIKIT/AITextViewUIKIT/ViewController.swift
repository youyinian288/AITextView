//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import WebKit
import AITextView

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var editorView: AITextView!
    var htmlTextView: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEditorView()
        setupNavigationBar()
    }
    
    private func setupUI() {
        // 创建editorView
        editorView = AITextView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editorView)
        
        // 创建htmlTextView
        htmlTextView = UITextView()
        htmlTextView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            htmlTextView.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            htmlTextView.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        htmlTextView.font = UIFont(name: "CourierNewPSMT", size: 14)
        htmlTextView.isEditable = false
        htmlTextView.text = "HTML Preview"
        view.addSubview(htmlTextView)
        
        
        // 设置约束
        setupConstraints()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // editorView占上半部分
            editorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            editorView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.5, constant: -22),
            
            // htmlTextView占下半部分
            htmlTextView.topAnchor.constraint(equalTo: editorView.bottomAnchor),
            htmlTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            htmlTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            htmlTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupEditorView() {
        editorView.delegate = self
        // 通过 JavaScript 设置占位符
        editorView.webView.evaluateJavaScript("RE.editor.setAttribute('placeholder', 'Edit here');") { result, error in
            if let error = error {
                print("设置占位符失败: \(error)")
            }
        }
        
        
        editorView.markdown = """
        # 🎯 AITextView 流式 Markdown 渲染测试
        
        ## 📝 文本格式测试
        **粗体文本 Bold Text** | *斜体文本 Italic Text* | ~~删除线文本 Strikethrough Text~~
        
        ***粗斜体文本 Bold Italic Text*** | `内联代码 Inline Code`
        
        上标: H~2~O | 下标: x^2^ + y^2^ = z^2^
        
        ## 🎨 颜色和样式测试
        <span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span>
        
        <span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span>
        
        ## 📋 标题级别测试
        # 一级标题 H1
        ## 二级标题 H2
        ### 三级标题 H3
        #### 四级标题 H4
        ##### 五级标题 H5
        ###### 六级标题 H6
        
        ## 📝 列表测试
        ### 有序列表 Ordered List:
        1. 第一项 First Item
        2. 第二项 Second Item
        3. 第三项 Third Item
           1. 嵌套项 1 Nested Item 1
           2. 嵌套项 2 Nested Item 2
        
        ### 无序列表 Unordered List:
        - 项目 A Item A
        - 项目 B Item B
        - 项目 C Item C
          - 子项目 1 Sub Item 1
          - 子项目 2 Sub Item 2
        
        ## 📐 对齐方式测试
        <div style="text-align: left;">⬅️ 左对齐文本 Left Aligned Text</div>
        <div style="text-align: center;">🎯 居中对齐文本 Center Aligned Text</div>
        <div style="text-align: right;">➡️ 右对齐文本 Right Aligned Text</div>
        <div style="text-align: justify;">📏 两端对齐文本 Justified Text - This is a longer paragraph to demonstrate justified text alignment. The text should be evenly distributed across the width of the container, creating straight edges on both sides.</div>
        
        ## 🔗 链接和媒体测试
        访问 [AITextView GitHub 仓库](https://github.com/youyinian288/AITextView)
        
        查看 [Apple 官网](https://www.apple.com) 了解更多信息
        
        这是一个 [邮箱链接](mailto:test@example.com) 和 [电话链接](tel:+1234567890)
        
        ## 🖼️ 图片测试
        网络图片示例：
        
        ![随机网络图片](https://picsum.photos/200/150?random=1)
        
        Base64 图片示例（小图标）：
        
        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        
        ## 💬 引用和特殊格式
        > "这是一个引用块，用于突出显示重要内容或引用他人的话语。"
        > 
        > — 作者名称
        
        ## 📊 表格测试
        | 功能 Feature | 支持 Support | 说明 Description |
        |-------------|-------------|------------------|
        | 粗体 Bold | ✅ | 支持粗体文本格式 |
        | 斜体 Italic | ✅ | 支持斜体文本格式 |
        | 列表 Lists | ✅ | 支持有序和无序列表 |
        
        ## 🎯 特殊字符和符号
        数学符号: ∑ ∫ ∏ ∆ ∇ ∞ ≤ ≥ ≠ ≈ ± × ÷
        
        箭头符号: ← → ↑ ↓ ↔ ↕ ⇐ ⇒ ⇑ ⇓
        
        货币符号: $ € £ ¥ ₹ ₽
        
        其他符号: © ® ™ § ¶ † ‡ • ◦ ◊
        
        ## 📱 响应式测试
        <span style="font-size: 12px;">小字体 Small Font (12px)</span>
        
        <span style="font-size: 16px;">正常字体 Normal Font (16px)</span>
        
        <span style="font-size: 20px;">大字体 Large Font (20px)</span>
        
        <span style="font-size: 24px;">超大字体 Extra Large Font (24px)</span>
        
        ## 🎨 混合格式测试
        ***粗体斜体下划线 Bold Italic Underlined*** | <span style="color: red; background-color: yellow;">**红字黄底粗体 Red Yellow Bold**</span>
        
        ~~*删除线斜体 Strikethrough Italic*~~ | <u><span style="color: blue;">下划线蓝色 Underlined Blue</span></u>
        
        ## 📝 段落和换行测试
        这是第一个段落。包含多行文本，用于测试段落的显示效果。AITextView 应该能够正确处理段落间距和换行。
        
        这是第二个段落。用于测试多个段落之间的间距和格式。每个段落都应该有适当的间距。
        
        这是第三个段落。  
        这里有一个手动换行。  
        用于测试 Markdown 换行的效果。
        
        ## 🔧 代码和预格式化文本
        内联代码: `console.log("Hello World")`
        
        ```javascript
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        ```
        
        ## 🎉 测试完成
        这个 Markdown 包含了 AITextView 流式渲染支持的大部分功能。请测试各种 Markdown 功能，包括：
        
        - 文本格式（粗体、斜体、删除线）
        - 颜色和背景色
        - 标题级别
        - 列表和缩进
        - 对齐方式
        - 链接插入
        - 图片插入（网络图片、Base64图片）
        - 代码块和语法高亮
        - 表格渲染
        - 引用块
        
        ### 📸 图片插入功能说明
        **支持的图片格式：**
        
        - 🌐 **网络图片**：通过URL直接插入在线图片
        - 📱 **本地图片**：从相册选择，自动转换为Base64格式
        - 🔧 **Base64图片**：直接插入Base64编码的图片数据
        
        **Base64图片优势：**
        
        - ✅ 无需网络连接，离线可用
        - ✅ 图片数据直接嵌入HTML，便于分享
        - ✅ 支持SVG矢量图形，缩放不失真
        - ✅ 适合小图标、简单图形等场景
        
        <div style="text-align: center; color: #666; font-style: italic;">
            🚀 开始测试 AITextView 的流式 Markdown 渲染功能吧！
        </div>
           
        """
    }
    
    private func setupNavigationBar() {
        // 设置导航栏标题
        title = "AITextView 编辑器"
    }
    

    
   
    

    }
    
    // MARK: - UIImagePickerControllerDelegate
    

extension ViewController: AITextViewDelegate {

    func aiTextView(_ editor: AITextView, heightDidChange height: Int) { }

    func aiTextView(_ editor: AITextView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

    func aiTextViewTookFocus(_ editor: AITextView) { }
    
    func aiTextViewLostFocus(_ editor: AITextView) { }
    
    func aiTextViewDidLoad(_ editor: AITextView) { }
    
    func aiTextView(_ editor: AITextView, shouldInteractWith url: URL) -> Bool { return true }

    func aiTextView(_ editor: AITextView, handle action: String) { }
    
}

