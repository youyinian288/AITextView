//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import AITextView

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var editorView: AITextView!
    var htmlTextView: UITextView!

    lazy var toolbar: AITextToolbar = {
        let toolbar = AITextToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = AITextDefaultOption.all
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEditorView()
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
        
        // 添加toolbar
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            // toolbar在editorView底部
            toolbar.topAnchor.constraint(equalTo: editorView.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            
            // htmlTextView占下半部分
            htmlTextView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            htmlTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            htmlTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            htmlTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupEditorView() {
        editorView.delegate = self
        editorView.placeholder = "Edit here"
        
        // 使用新的键盘工具栏功能 - 更简洁的方式
        editorView.showsKeyboardToolbar = true
        editorView.keyboardToolbarDoneButtonText = "Done"
        
        toolbar.delegate = self
        toolbar.editor = editorView
        editorView.html = """
        <h1>🎯 AITextView 全面功能测试</h1>
        
        <h2>📝 文本格式测试</h2>
        <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
        <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
        <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
        
        <h2>🎨 颜色和样式测试</h2>
        <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
        <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
        <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
        
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
        
        <p>Base64 图片示例（小图标）：</p>
        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        
        <p>Base64 图片示例（彩色渐变）：</p>
        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        
        <p>Base64 图片示例（简单几何图形）：</p>
        <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
        
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
        
        <h3>📸 图片插入功能说明</h3>
        <p><strong>支持的图片格式：</strong></p>
        <ul>
            <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
            <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
            <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
        </ul>
        
        <p><strong>Base64图片优势：</strong></p>
        <ul>
            <li>✅ 无需网络连接，离线可用</li>
            <li>✅ 图片数据直接嵌入HTML，便于分享</li>
            <li>✅ 支持SVG矢量图形，缩放不失真</li>
            <li>✅ 适合小图标、简单图形等场景</li>
        </ul>
        
        <p style="text-align: center; color: #666; font-style: italic;">
            🚀 开始测试 AITextView 的强大功能吧！
        </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
                <h1>🎯 AITextView 全面功能测试</h1>
                
                <h2>📝 文本格式测试</h2>
                <p><b>粗体文本 Bold Text</b> | <i>斜体文本 Italic Text</i> | <u>下划线文本 Underlined Text</u> | <s>删除线文本 Strikethrough Text</s></p>
                <p><strong>强调文本 Strong Text</strong> | <em>强调斜体 Emphasized Text</em></p>
                <p>上标: H<sub>2</sub>O | 下标: x<sup>2</sup> + y<sup>2</sup> = z<sup>2</sup></p>
                
                <h2>🎨 颜色和样式测试</h2>
                <p><span style="color: red;">红色文字 Red Text</span> | <span style="color: blue;">蓝色文字 Blue Text</span> | <span style="color: green;">绿色文字 Green Text</span></p>
                <p><span style="background-color: yellow;">黄色背景 Yellow Background</span> | <span style="background-color: lightblue;">浅蓝背景 Light Blue Background</span></p>
                <p><span style="color: white; background-color: black;">白字黑底 White on Black</span> | <span style="color: purple; font-size: 18px;">紫色大字体 Purple Large Text</span></p>
                
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
                
                <p>Base64 图片示例（小图标）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 SVG 图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（彩色渐变）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+" alt="Base64 渐变图片" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
                <p>Base64 图片示例（简单几何图形）：</p>
                <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==" alt="Base64 几何图形" style="max-width: 100%; height: auto; border-radius: 8px; margin: 10px 0;">
                
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
                
                <h3>📸 图片插入功能说明</h3>
                <p><strong>支持的图片格式：</strong></p>
                <ul>
                    <li>🌐 <strong>网络图片</strong>：通过URL直接插入在线图片</li>
                    <li>📱 <strong>本地图片</strong>：从相册选择，自动转换为Base64格式</li>
                    <li>🔧 <strong>Base64图片</strong>：直接插入Base64编码的图片数据</li>
                </ul>
                
                <p><strong>Base64图片优势：</strong></p>
                <ul>
                    <li>✅ 无需网络连接，离线可用</li>
                    <li>✅ 图片数据直接嵌入HTML，便于分享</li>
                    <li>✅ 支持SVG矢量图形，缩放不失真</li>
                    <li>✅ 适合小图标、简单图形等场景</li>
                </ul>
                
                <p style="text-align: center; color: #666; font-style: italic;">
                    🚀 开始测试 AITextView 的强大功能吧！
                </p>
        """
    }
    
    // MARK: - Image Selection Methods
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func presentImageURLInput() {
        let alertController = UIAlertController(title: "输入图片URL", message: "请输入图片的网络地址", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "https://example.com/image.jpg"
            textField.keyboardType = .URL
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let urlString = textField.text,
               !urlString.isEmpty {
                self.insertImageFromURL(urlString)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func insertImageFromURL(_ urlString: String) {
        editorView.insertImage(urlString, alt: "Online Image")
    }
    
    private func insertLocalImage(_ image: UIImage) {
        // 将本地图片转换为base64格式插入
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            let dataURL = "data:image/jpeg;base64,\(base64String)"
            editorView.insertImage(dataURL, alt: "Local Image")
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let editedImage = info[.editedImage] as? UIImage {
                self.insertLocalImage(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                self.insertLocalImage(originalImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}

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

extension ViewController: AITextToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors = [
            UIColor.red,
            UIColor.orange,
            UIColor.yellow,
            UIColor.green,
            UIColor.blue,
            UIColor.purple
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func aiTextToolbarChangeTextColor(_ toolbar: AITextToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func aiTextToolbarChangeBackgroundColor(_ toolbar: AITextToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func aiTextToolbarInsertImage(_ toolbar: AITextToolbar) {
        let alertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        // 从相册选择
        let photoLibraryAction = UIAlertAction(title: "从相册选择", style: .default) { _ in
            self.presentImagePicker()
        }
        alertController.addAction(photoLibraryAction)
        
        // 输入在线图片URL
        let urlAction = UIAlertAction(title: "输入图片URL", style: .default) { _ in
            self.presentImageURLInput()
        }
        alertController.addAction(urlAction)
        
        // 取消
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        // 设置iPad的popover
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }

    func aiTextToolbarInsertLink(_ toolbar: AITextToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
//       if let hasSelection = toolbar.editor?.rangeSelectionExists(), hasSelection {
//           toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
//       }
    }
}
