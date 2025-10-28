//
//  AIStreamTestViewController.swift
//  AITextViewUIKIT
//
//  Created by AI Assistant on 2025/01/27.
//  Copyright © 2025 Yitesi. All rights reserved.
//

import UIKit
import AITextView
import SwiftOpenAI

class AIStreamTestViewController: UIViewController {
    
    // MARK: - UI Components
    
    private var contentView: UIView!
    private var inputTextView: UITextView!
    private var editorView: AITextView!
    private var sendButton: UIButton!
    private var stopButton: UIButton!
    private var clearButton: UIButton!
    private var mockAIButton: UIButton!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    private var autoScrollSwitch: UISwitch!
    private var autoScrollLabel: UILabel!
    
    // MARK: - Properties
    
    private var message: String = ""
    private var errorMessage: String = ""
    private var isStreaming: Bool = false
    private var currentStreamTask: Task<Void, Never>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupInitialState()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "AI流式输出测试"
        view.backgroundColor = .systemBackground
        
        // 创建输入文本框
        inputTextView = UITextView()
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 8.0
        inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        inputTextView.text = "8月份的AI新闻有哪些"
        view.addSubview(inputTextView)
        
        // 创建输出编辑器
        editorView = AITextView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        editorView.layer.borderColor = UIColor.systemGray4.cgColor
        editorView.layer.borderWidth = 1.0
        editorView.layer.cornerRadius = 8.0
        editorView.markdown = """
        # 🎯 AITextView Markdown 富文本测试
        
        ## 📝 文本格式测试
        
        **粗体文本 Bold Text** | *斜体文本 Italic Text* | ~~删除线文本 Strikethrough Text~~
        
        ***粗体斜体 Bold Italic*** | **_粗体下划线 Bold Underlined_**
        
        上标: H~2~O | 下标: x^2^ + y^2^ = z^2^
        
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

        ## 🔗 链接测试
        
        访问 [AITextView GitHub 仓库](https://github.com/youyinian288/AITextView)
        
        查看 [Apple 官网](https://www.apple.com) 了解更多信息
        
        这是一个 [邮箱链接](mailto:test@example.com) 和 [电话链接](tel:+1234567890)
        
        ## 🖼️ 图片测试
        
        网络图片示例：
        ![随机网络图片](https://picsum.photos/200/150?random=1)
        
        Base64 图片示例（小图标）：
        ![Base64 SVG 图片](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==)
        
        Base64 图片示例（彩色渐变）：
        ![Base64 渐变图片](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZGVmcz4KICAgIDxsaW5lYXJHcmFkaWVudCBpZD0iZ3JhZGllbnQiIHgxPSIwJSIgeTE9IjAlIiB4Mj0iMTAwJSIgeTI9IjEwMCUiPgogICAgICA8c3RvcCBvZmZzZXQ9IjAlIiBzdG9wLWNvbG9yPSIjZmY2YjY5Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjNGZjM2Y0Ii8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3RvcC1jb2xvcj0iIzQyODVmNCIvPgogICAgPC9saW5lYXJHcmFkaWVudD4KICA8L2RlZnM+CiAgPHJlY3Qgd2lkdGg9IjMwMCIgaGVpZ2h0PSIxNTAiIGZpbGw9InVybCgjZ3JhZGllbnQpIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGRvbWluYW50LWJhc2VsaW5lPSJtaWRkbGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjQiIGZvbnQtd2VpZ2h0PSJib2xkIj5HcmFkaWVudCBJbWFnZTwvdGV4dD4KPC9zdmc+)
        
        Base64 图片示例（简单几何图形）：
        ![Base64 几何图形](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwIiBoZWlnaHQ9IjEyNSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI1MCIgZmlsbD0iI2ZmNjI2MiIvPgogIDxyZWN0IHg9IjEwMCIgeT0iMjAiIHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgZmlsbD0iIzQyODVmNCIvPgogIDxwb2x5Z29uIHBvaW50cz0iMjAwLDIwIDI0MCw2MCAyMDAsMTAwIDE2MCw2MCIgZmlsbD0iI2ZmYzEwNyIvPgogIDx0ZXh0IHg9IjEyNSIgeT0iMTEwIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0Ij5TaGFwZXM8L3RleHQ+Cjwvc3ZnPg==)

        ## 💬 引用测试
        
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
        
        ## 🔧 代码测试
        
        内联代码: `console.log("Hello World")`
        
        代码块示例：
        ```markdown
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        ```

        ## 📝 段落和换行测试
        
        这是第一个段落。包含多行文本，用于测试段落的显示效果。AITextView 应该能够正确处理段落间距和换行。
        
        这是第二个段落。用于测试多个段落之间的间距和格式。每个段落都应该有适当的间距。
        
        这是第三个段落。  
        这里有一个手动换行。  
        用于测试 Markdown 换行的效果。
        
        ## 🎨 混合格式测试
        
        ***粗体斜体 Bold Italic*** | ~~*删除线斜体 Strikethrough Italic*~~
        
        ## 🎉 测试完成
        
        这个 Markdown 包含了 AITextView 支持的大部分功能。请使用工具栏测试各种编辑功能，包括：
        
        - 文本格式（粗体、斜体、删除线）
        - 标题级别
        - 列表和缩进
        - 链接插入
        - 图片插入（网络图片、Base64图片）
        - 引用块
        - 表格
        - 代码块
        - 撤销重做
        - 键盘工具栏
        
        ### 📸 图片插入功能说明
        
        **支持的图片格式：**
        
        - 🌐 **网络图片**：通过URL直接插入在线图片
        - 📱 **本地图片**：从相册选择，自动转换为Base64格式
        - 🔧 **Base64图片**：直接插入Base64编码的图片数据
        
        **Base64图片优势：**

        - ✅ 无需网络连接，离线可用
        - ✅ 图片数据直接嵌入Markdown，便于分享
        - ✅ 支持SVG矢量图形，缩放不失真
        - ✅ 适合小图标、简单图形等场景

        ## 🎉 测试完成
        
        这个 Markdown 包含了 AITextView 支持的大部分功能。请使用工具栏测试各种编辑功能，包括：
        
        - 文本格式（粗体、斜体、删除线）
        - 标题级别
        - 列表和缩进
        - 链接插入
        - 图片插入（网络图片、Base64图片）
        - 代码块和行内代码
        - 表格和引用
        
        ---
        
        🚀 **开始测试 AITextView 的强大 Markdown 功能吧！**
        """
        
        // 创建发送按钮
        sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("发送请求", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8.0
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        
        // 创建停止按钮
        stopButton = UIButton(type: .system)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.setTitle("停止生成", for: .normal)
        stopButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8.0
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        view.addSubview(stopButton)
        
        // 创建清除按钮
        clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("清除内容", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.backgroundColor = .systemGray
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8.0
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 创建模拟AI按钮
        mockAIButton = UIButton(type: .system)
        mockAIButton.translatesAutoresizingMaskIntoConstraints = false
        mockAIButton.setTitle("模拟AI", for: .normal)
        mockAIButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        mockAIButton.backgroundColor = .systemGreen
        mockAIButton.setTitleColor(.white, for: .normal)
        mockAIButton.layer.cornerRadius = 8.0
        mockAIButton.addTarget(self, action: #selector(mockAIButtonTapped), for: .touchUpInside)
        view.addSubview(mockAIButton)
        
        // 创建状态标签
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        statusLabel.text = "准备就绪"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // 创建进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        view.addSubview(progressView)
        
        // 创建自动滚动标签
        autoScrollLabel = UILabel()
        autoScrollLabel.translatesAutoresizingMaskIntoConstraints = false
        autoScrollLabel.font = UIFont.systemFont(ofSize: 14)
        autoScrollLabel.textColor = .label
        autoScrollLabel.text = "自动滚动"
        view.addSubview(autoScrollLabel)
        
        // 创建自动滚动开关
        autoScrollSwitch = UISwitch()
        autoScrollSwitch.translatesAutoresizingMaskIntoConstraints = false
        autoScrollSwitch.isOn = true
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollSwitchChanged), for: .valueChanged)
        view.addSubview(autoScrollSwitch)
        
        // 创建内容容器视图
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true  // 确保内容不会超出边界
        view.addSubview(contentView)
        
        // 将编辑器添加到内容容器视图
        contentView.addSubview(editorView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // 输入文本框约束 - 固定在顶部
            inputTextView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // 按钮约束 - 固定在输入框下方
            sendButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            stopButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            stopButton.leadingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 8),
            stopButton.widthAnchor.constraint(equalToConstant: 100),
            stopButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            clearButton.leadingAnchor.constraint(equalTo: stopButton.trailingAnchor, constant: 8),
            clearButton.widthAnchor.constraint(equalToConstant: 100),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            
            mockAIButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            mockAIButton.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 8),
            mockAIButton.widthAnchor.constraint(equalToConstant: 100),
            mockAIButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 状态标签约束 - 固定在按钮下方
            statusLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 进度条约束 - 固定在状态标签下方
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // 自动滚动标签约束
            autoScrollLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            autoScrollLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            autoScrollLabel.widthAnchor.constraint(equalToConstant: 80),
            autoScrollLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 自动滚动开关约束
            autoScrollSwitch.centerYAnchor.constraint(equalTo: autoScrollLabel.centerYAnchor),
            autoScrollSwitch.leadingAnchor.constraint(equalTo: autoScrollLabel.trailingAnchor, constant: 8),
            
            // 内容容器视图约束 - 约束到主视图
            contentView.topAnchor.constraint(equalTo: autoScrollLabel.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            
            // 编辑器约束 - 约束到内容容器视图
            editorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupInitialState() {
        updateUIState()
        
        // 设置初始内容 - 使用简单的 Markdown 测试
        let testMarkdown = """
        # 🚀 AITextView 流式 Markdown 测试
        
        ## 功能特性
        
        - ✅ **实时流式渲染** - 支持 AI 流式输出的 Markdown 解析
        - ✅ **富文本显示** - 支持标题、列表、代码块等格式
        - ✅ **Base64 图片** - 支持内嵌图片显示
        - ✅ **响应式设计** - 自适应不同屏幕尺寸
        
        ## 测试说明
        
        点击 **发送** 按钮开始测试 AI 流式输出功能！
        
        > 💡 **提示**: 输入任何问题，AI 会以 Markdown 格式流式返回答案
        """
        
        print("🎨 设置初始测试内容")
        editorView.updateMarkdownStream(testMarkdown, isComplete: true)
        print("✅ 初始内容设置完成")
    }
    
    // MARK: - Actions
    
    @objc private func sendButtonTapped() {
        print("🚀 发送按钮被点击")
        guard !isStreaming else { 
            print("⚠️ 正在流式输出中，忽略点击")
            return 
        }
        
        let prompt = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📝 用户输入: \(prompt)")
        guard !prompt.isEmpty else {
            print("❌ 输入为空")
            showAlert(title: "提示", message: "请输入问题内容")
            return
        }
        
        print("✅ 开始AI流式请求")
        startAIStream(prompt: prompt)
    }
    
    @objc private func stopButtonTapped() {
        stopAIStream()
    }
    
    @objc private func clearButtonTapped() {
        clearContent()
    }
    
    @objc private func mockAIButtonTapped() {
        print("🤖 模拟AI按钮被点击")
        guard !isStreaming else { 
            print("⚠️ 正在流式输出中，忽略点击")
            return 
        }
        
        print("✅ 开始模拟AI流式输出")
        startMockAIStream()
    }
    
    @objc private func autoScrollSwitchChanged() {
        editorView.isAutoScrollEnabled = autoScrollSwitch.isOn
        updateStatus(autoScrollSwitch.isOn ? "自动滚动已启用" : "自动滚动已禁用")
    }
    
    // MARK: - AI Stream Methods
    
    private func startAIStream(prompt: String) {
        print("🔄 开始AI流式处理")
        isStreaming = true
        message = ""
        errorMessage = ""
        
        updateUIState()
        updateStatus("正在连接AI服务...")
        print("📡 状态更新: 正在连接AI服务...")
        
        // 使用硬编码的API密钥
        let apiKey = "sk-0afb28dff5ff4381b57f804caf79dd1d"
        let service = OpenAIServiceFactory.service(
            apiKey: apiKey,
            overrideBaseURL: "https://api.deepseek.com"
        )
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text("请用Markdown格式富文本返回内容问题答案：" + prompt))],
            model: .custom("deepseek-chat")
        )
        
        print("🌐 创建AI服务，API Key: \(String(apiKey.prefix(10)))...")
        print("📋 请求参数: \(parameters)")
        
        currentStreamTask = Task {
            do {
                updateStatus("开始流式输出...")
                print("📤 开始流式输出...")
                progressView.isHidden = false
                progressView.progress = 0.0
                
                let stream = try await service.startStreamedChat(parameters: parameters)
                print("✅ 流式连接建立成功")
                var progress: Float = 0.0
                
                for try await result in stream {
                    await MainActor.run {
                        let content = result.choices?.first?.delta?.content ?? ""
                        print("📨 收到内容片段: '\(content)'")
                        
                        // 直接使用流式输出更新，只发送新增的内容
                        if !content.isEmpty {
                            self.editorView.updateMarkdownStream(content, isComplete: false)
                        }
                        
                        self.message += content
                        
                        // 更新进度
                        progress += 0.1
                        self.progressView.progress = min(progress, 0.9)
                    }
                }
                
                await MainActor.run {
                    print("✅ 流式输出完成，总消息长度: \(self.message.count)")
                    
                    // 标记流式输出完成
                    self.editorView.updateMarkdownStream("", isComplete: true)
                    
                    self.progressView.progress = 1.0
                    self.updateStatus("流式输出完成")
                    self.isStreaming = false
                    self.currentStreamTask = nil
                    self.updateUIState()
                    
                    // 延迟隐藏进度条
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.progressView.isHidden = true
                    }
                }
                
            } catch APIError.responseUnsuccessful(let description, let statusCode) {
                await MainActor.run {
                    print("❌ API错误: \(statusCode) - \(description)")
                    self.errorMessage = "网络错误，状态码: \(statusCode)，描述: \(description)"
                    self.updateStatus("请求失败")
                    self.isStreaming = false
                    self.currentStreamTask = nil
                    self.updateUIState()
                    self.progressView.isHidden = true
                    self.showAlert(title: "错误", message: self.errorMessage)
                }
            } catch {
                await MainActor.run {
                    print("❌ 未知错误: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.updateStatus("请求失败")
                    self.isStreaming = false
                    self.currentStreamTask = nil
                    self.updateUIState()
                    self.progressView.isHidden = true
                    self.showAlert(title: "错误", message: self.errorMessage)
                }
            }
        }
    }
    
    private func stopAIStream() {
        guard isStreaming else { return }
        
        // 取消当前任务
        currentStreamTask?.cancel()
        currentStreamTask = nil
        
        // 更新状态
        isStreaming = false
        updateStatus("已停止生成")
        updateUIState()
        progressView.isHidden = true
        
        // 在消息末尾添加停止提示并标记完成
        if !message.isEmpty {
            let stopMessage = "\n\n[生成已停止]"
            message += stopMessage
            editorView.updateMarkdownStream(stopMessage, isComplete: true)
        }
    }
    
    private func updateOutputDisplay() {
        print("🎨 更新输出显示")
        
        if !message.isEmpty {
            print("📝 有消息内容，长度: \(message.count)")
            // 使用流式输出更新
            editorView.updateMarkdownStream(message, isComplete: !isStreaming)
        } else if !errorMessage.isEmpty {
            print("❌ 有错误信息: \(errorMessage)")
            let errorMarkdown = """
            ### ❌ 错误信息
            
            > \(errorMessage)
            """
            editorView.updateMarkdownStream(errorMarkdown, isComplete: true)
        } else {
            print("📝 使用默认内容")
            let defaultMarkdown = """
            **Base64图片优势：**
            
            - ✅ 无需网络连接，离线可用
            - ✅ 图片数据直接嵌入Markdown，便于分享
            - ✅ 支持SVG矢量图形，缩放不失真
            - ✅ 适合小图标、简单图形等场景
            
            ---
            
            🚀 **开始测试 AITextView 的强大功能吧！**
            """
            editorView.updateMarkdownStream(defaultMarkdown, isComplete: true)
        }
        
        print("✅ 流式输出更新完成")
    }
    
    private func clearContent() {
        message = ""
        errorMessage = ""
        editorView.resetMarkdown()
        updateStatus("内容已清除")
    }
    
    // MARK: - UI Updates
    
    private func updateUIState() {
        sendButton.isEnabled = !isStreaming
        sendButton.alpha = isStreaming ? 0.6 : 1.0
        
        stopButton.isEnabled = isStreaming
        stopButton.alpha = isStreaming ? 1.0 : 0.6
        
        clearButton.isEnabled = !isStreaming
        clearButton.alpha = isStreaming ? 0.6 : 1.0
        
        mockAIButton.isEnabled = !isStreaming
        mockAIButton.alpha = isStreaming ? 0.6 : 1.0
        
        inputTextView.isEditable = !isStreaming
    }
    
    private func updateStatus(_ status: String) {
        statusLabel.text = status
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Mock AI Stream Methods
    
    private func startMockAIStream() {
        print("🤖 开始模拟AI流式处理")
        isStreaming = true
        message = ""
        errorMessage = ""
        
        updateUIState()
        updateStatus("正在模拟AI生成...")
        progressView.isHidden = false
        progressView.progress = 0.0
        
        // 获取预设的markdown内容
        let mockContent = getMockMarkdownContent()
        
        // 创建模拟流式输出任务
        currentStreamTask = Task {
            await simulateAIStream(content: mockContent)
        }
    }
    
    private func getMockMarkdownContent() -> String {
        // 返回预设的markdown内容用于测试
        return """
        # 🤖 模拟AI流式输出测试
        
        ## 📝 文本格式测试
        
        **粗体文本 Bold Text** | *斜体文本 Italic Text* | ~~删除线文本 Strikethrough Text~~
        
        ***粗体斜体 Bold Italic*** | **_粗体下划线 Bold Underlined_**
        
        上标: H~2~O | 下标: x^2^ + y^2^ = z^2^
        
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

        ## 🔗 链接测试
        
        访问 [AITextView GitHub 仓库](https://github.com/youyinian288/AITextView)
        
        查看 [Apple 官网](https://www.apple.com) 了解更多信息
        
        这是一个 [邮箱链接](mailto:test@example.com) 和 [电话链接](tel:+1234567890)
        
        ## 🖼️ 图片测试
        
        网络图片示例：
        ![随机网络图片](https://picsum.photos/200/150?random=1)
        
        Base64 图片示例（小图标）：
        ![Base64 SVG 图片](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==)
        
        ## 💬 引用测试
        
        > "这是一个引用块，用于突出显示重要内容或引用他人的话语。"
        > 
        > — 作者名称
        
        ## 📊 表格测试
        
        | 功能 Feature | 支持 Support | 说明 Description |
        |-------------|-------------|------------------|
        | 粗体 Bold | ✅ | 支持粗体文本格式 |
        | 斜体 Italic | ✅ | 支持斜体文本格式 |
        | 列表 Lists | ✅ | 支持有序和无序列表 |
        | 链接 Links | ✅ | 支持各种链接格式 |
        | 图片 Images | ✅ | 支持网络和Base64图片 |
        
        ## 🔧 代码测试
        
        内联代码: `console.log("Hello World")`
        
        代码块示例：
        ```swift
        func fibonacci(_ n: Int) -> Int {
            if n <= 1 { return n }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }
        ```
        
        ```javascript
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        ```
        
        ## 🎯 特殊字符和符号
        
        数学符号: ∑ ∫ ∏ ∆ ∇ ∞ ≤ ≥ ≠ ≈ ± × ÷
        
        箭头符号: ← → ↑ ↓ ↔ ↕ ⇐ ⇒ ⇑ ⇓
        
        货币符号: $ € £ ¥ ₹ ₽
        
        其他符号: © ® ™ § ¶ † ‡ • ◦ ◊
        
        ## 📝 段落和换行测试
        
        这是第一个段落。包含多行文本，用于测试段落的显示效果。AITextView 应该能够正确处理段落间距和换行。
        
        这是第二个段落。用于测试多个段落之间的间距和格式。每个段落都应该有适当的间距。
        
        这是第三个段落。  
        这里有一个手动换行。  
        用于测试 Markdown 换行的效果。
        
        ## 🎨 混合格式测试
        
        ***粗体斜体 Bold Italic*** | ~~*删除线斜体 Strikethrough Italic*~~
        
        ## 🎉 测试完成
        
        这个模拟AI输出包含了 AITextView 支持的大部分功能。通过流式输出，您可以测试：
        
        - ✅ 文本格式（粗体、斜体、删除线）
        - ✅ 标题级别
        - ✅ 列表和缩进
        - ✅ 链接插入
        - ✅ 图片插入（网络图片、Base64图片）
        - ✅ 引用块
        - ✅ 表格
        - ✅ 代码块
        - ✅ 自动滚动功能
        
        ---
        
        🚀 **模拟AI流式输出测试完成！**
        
        💡 **提示**: 您可以调整自动滚动开关来测试滚动行为，使用"停止生成"按钮来中断流式输出。
        """
    }
    
    private func simulateAIStream(content: String) async {
        print("🔄 开始模拟流式输出")
        
        // 将内容分割成小块进行流式输出
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        let chunkSize = 3 // 每次输出3个词
        var currentIndex = 0
        var progress: Float = 0.0
        
        while currentIndex < words.count && !Task.isCancelled {
            await MainActor.run {
                // 获取当前块的内容
                let endIndex = min(currentIndex + chunkSize, words.count)
                let chunk = words[currentIndex..<endIndex].joined(separator: " ")
                
                // 添加适当的空格和换行
                let contentToAdd = currentIndex == 0 ? chunk : " " + chunk
                
                print("📨 模拟输出内容片段: '\(contentToAdd)'")
                
                // 使用流式输出更新
                if !contentToAdd.isEmpty {
                    self.editorView.updateMarkdownStream(contentToAdd, isComplete: false)
                }
                
                self.message += contentToAdd
                
                // 更新进度
                progress = Float(currentIndex) / Float(words.count)
                self.progressView.progress = progress
                
                // 更新状态
                let percentage = Int(progress * 100)
                self.updateStatus("模拟AI生成中... \(percentage)%")
            }
            
            // 模拟网络延迟
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒延迟
            
            currentIndex += chunkSize
        }
        
        await MainActor.run {
            print("✅ 模拟流式输出完成，总消息长度: \(self.message.count)")
            
            // 标记流式输出完成
            self.editorView.updateMarkdownStream("", isComplete: true)
            
            self.progressView.progress = 1.0
            self.updateStatus("模拟AI生成完成")
            self.isStreaming = false
            self.currentStreamTask = nil
            self.updateUIState()
            
            // 延迟隐藏进度条
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.progressView.isHidden = true
            }
        }
    }
}

