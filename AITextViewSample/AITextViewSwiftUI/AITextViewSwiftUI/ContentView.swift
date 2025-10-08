//
//  ContentView.swift
//  RichEditorViewSwiftUI
//
//  Created by yunning you on 2025/8/25.
//

import SwiftUI
import AITextView

struct ContentView: View {
    
    // Rich text editor state management
    @StateObject private var editorState = AITextViewState(
        htmlContent:  """
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
    )
    
    // State variables for ColorPicker
    @State private var foregroundColor: Color = .black
    @State private var highlightColor: Color = .white
    
    // State variables to control color picker display
    @State private var showTextColorPicker: Bool = false
    @State private var showBackgroundColorPicker: Bool = false
    
    // Toolbar options configuration - using all available options
    private let toolbarOptions: [AITextDefaultOption] = AITextDefaultOption.all
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 上半部分：编辑器
                SwiftUIAITextView(
                    htmlContent: $editorState.htmlContent,
                    isEditing: $editorState.isEditing,
                    placeholder: "Edit here",
                    isScrollEnabled: true,
                    editingEnabled: true,
                    backgroundColor: .systemBackground,
                    showsKeyboardToolbar: true,
                    keyboardToolbarDoneButtonText: "Done",
                    onContentChange: { content in
                        print("Content changed: \(content)")
                    },
                    onHeightChange: { height in
                        editorState.editorHeight = CGFloat(height)
                    },
                    onEditorReady: { aiTextView in
                        editorState.editor = aiTextView
                    }
                )
                .padding(.horizontal, 8)
                .frame(height: geometry.size.height * 0.5 - 22)
                .background(Color(.systemBackground))
                .clipped()
                
                // 中间部分：工具栏
                SwiftUIAITextToolbar(
                    options: toolbarOptions,
                    barTintColor: .systemBackground,
                    editor: editorState.editor,
                    onTextColorChange: {
                        showTextColorPicker = true
                    },
                    onBackgroundColorChange: {
                        showBackgroundColorPicker = true
                    },
                    onImageInsert: {
                        print("Image insertion")
                    },
                    onLinkInsert: {
                        print("Link insertion")
                    }
                )
                .frame(height: 44)
                .background(Color(.systemBackground))
                
                // 下半部分：HTML预览
                VStack(alignment: .leading, spacing: 0) {
                    Text("HTML Preview")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                    
                    ScrollView {
                        Text(editorState.htmlContent)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .background(Color(.secondarySystemBackground))
                }
                .frame(height: geometry.size.height * 0.5)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: foregroundColor) { newColor in
            // Update editor text color when foregroundColor changes
            editorState.editor?.setTextColor(UIColor(newColor))
        }
        .onChange(of: highlightColor) { newColor in
            // Update editor text background color when highlightColor changes
            editorState.editor?.setTextBackgroundColor(UIColor(newColor))
        }
        .sheet(isPresented: $showTextColorPicker) {
            NavigationView {
                VStack {
                    ColorPicker("Select Text Color", selection: $foregroundColor)
                        .padding()
                    Spacer()
                }
                .navigationTitle("Text Color")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showTextColorPicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBackgroundColorPicker) {
            NavigationView {
                VStack {
                    ColorPicker("Select Background Color", selection: $highlightColor)
                        .padding()
                    Spacer()
                }
                .navigationTitle("Background Color")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showBackgroundColorPicker = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
