    //
//  AITextView.swift
//
//  Created by Caesar Wirth on 4/1/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

// 导入 UIKit 框架，用于构建 iOS 用户界面
import UIKit
// 导入 WebKit 框架，用于在应用中显示网页内容
import WebKit


    
    
/// AITextViewDelegate定义了AITextView代理的回调方法
// 定义一个公开的协议 AITextViewDelegate，遵循 AnyObject 协议，意味着只有类可以实现它
@objc public protocol AITextViewDelegate: AnyObject {
    
    /// 当AITextView准备接收输入时调用
    /// 更具体地说，当内部WKWebView首次加载且contentHTML被设置时调用
    // 当编辑器加载完成时，会调用这个可选方法
    @objc optional func aiTextViewDidLoad(_ editor: AITextView)
    @objc optional func aiTextView(_ editor: AITextView, markdownDidChange markdown: String)
}

/// AITextView是一个UIView，用于显示AI流式输出的HTML内容
// 定义一个公开的类 AITextView，继承自 UIView，并遵循多个协议
@objcMembers open class AITextView: UIView, WKNavigationDelegate, UIScrollViewDelegate {
    /// 将接收回调的代理，当某些操作完成时
    // 定义一个弱引用的代理，用于接收 AITextViewDelegate 的回调
    open weak var delegate: AITextViewDelegate?
    

    
    
    /// 用于显示文本的内部WKWebView
    // 定义一个内部的 AITextWebView，用于显示编辑器
    open private(set) var webView: AITextWebView
    
    
    
    
    
    /// 编辑器是否已完成加载
    // 定义一个私有布尔值，标记编辑器是否已加载
    private var isEditorLoaded = false
    
    /// 当前 Markdown 内容缓冲区
    private var markdownBuffer: String = "" {
        didSet {
            delegate?.aiTextView?(self, markdownDidChange: markdownBuffer)
        }
    }
    /// 是否正在流式更新
    private var isStreaming: Bool = false
    
    /// 是否启用自动滚动（流式输出时）
    public var isAutoScrollEnabled: Bool = true

        open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
        
    /// 当前 Markdown 内容
    // 定义一个字符串，用于设置或获取编辑器的 Markdown 内容
    public var markdown: String = "" {
        // 在属性值改变后执行
        didSet {
            // 调用 setMarkdown 方法来更新内容
            setMarkdown(markdown)
        }
    }
    
    
    // MARK: - 初始化
    // MARK: Initialization
    
    // 覆盖 UIView 的 init(frame:) 方法
    public override init(frame: CGRect) {
        // 初始化 webView
        webView = AITextWebView()
        // 调用父类的初始化方法
        super.init(frame: frame)
        // 调用 setup 方法进行配置
        setup()
    }
    
    // 覆盖 UIView 的 init?(coder:) 方法，用于从 Storyboard 或 XIB 加载
    required public init?(coder aDecoder: NSCoder) {
        // 初始化 webView
        webView = AITextWebView()
        // 调用父类的初始化方法
        super.init(coder: aDecoder)
        // 调用 setup 方法进行配置
        setup()
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !isScrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }
    // 私有的 setup 方法，用于配置视图
    private func setup() {
        // configure webview
        // 设置 webView 的 frame 为当前视图的 bounds
        webView.frame = bounds
        // 设置 webView 的导航代理为 self
        webView.navigationDelegate = self
        // 设置 webView 的 autoresizingMask，使其随父视图大小变化而自动调整
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // 如果系统版本是 iOS 10.0 或更高
        if #available(iOS 10.0, *) {
            // 禁用 webView 的数据检测类型（如电话号码、链接）
            webView.configuration.dataDetectorTypes = WKDataDetectorTypes()
        }
        // 启用 scrollView 的弹簧效果
        webView.scrollView.bounces = true
        // 允许 scrollView 的内容超出其边界
        webView.scrollView.clipsToBounds = false
        // 将 webView 添加到当前视图
        addSubview(webView)
        // 加载流式 Markdown 编辑器 HTML 文件
        loadRichEditorView()
    }

    // 私有方法，用于加载流式 Markdown 编辑器视图
    private func loadRichEditorView() {
        // 声明一个 Bundle 对象
        let bundle: Bundle
    // 如果是 Swift Package Manager 环境
    #if SWIFT_PACKAGE
        // 使用 Bundle.module 获取当前的 package bundle
        bundle = Bundle.module
    #else
        // 否则，获取包含 AITextView 类的 bundle
        bundle = Bundle(for: AITextView.self)
    #endif
        // 获取 stream_markdown_editor.html 文件的路径
        if let filePath = bundle.path(forResource: "stream_markdown_editor", ofType: "html") {
            // 创建一个文件 URL
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            // 让 webView 加载这个文件 URL，并允许访问其所在目录
            webView.loadFileURL(
                url, 
                allowingReadAccessTo: url.deletingLastPathComponent()
            )
            // 加载成功，返回
            return
        }
        // 如果找不到文件，则抛出致命错误
        fatalError("Failed to load stream_markdown_editor.html, check your dependency configuration")
    }
    
    // MARK: - AI流式输出
    
    /// 流式更新 Markdown 内容
    /// - Parameter markdown: 新的 Markdown 内容片段
    public func updateMarkdownStream(_ markdown: String) {
        print("📝 AITextView.updateMarkdownStream 被调用，片段长度: \(markdown.count)")
        
        // 转义 JavaScript 字符串中的特殊字符（使用 JSONEncoder）
        let escapedMarkdown = escapeJavaScriptString(markdown)
        
        // 调用 JavaScript 进行 markdown-it 解析
        let jsCode = "RE.streamMarkdownProcessor.updateMarkdown(\"\(escapedMarkdown)\", false);"
        
        print("🌐 执行JavaScript代码: \(jsCode)")
        runJS(jsCode)
        
        // 如果启用自动滚动，在流式更新时自动滚动到底部
        if isAutoScrollEnabled && !markdown.isEmpty {
            scrollToBottom(animated: true)
        }
    }

    /// 结束当前的 Markdown 流式输出（不再区分完整与否，由上层逻辑控制）
    public func finishMarkdownStream() {
        print("✅ AITextView.finishMarkdownStream 被调用")
        let jsCode = "RE.streamMarkdownProcessor.updateMarkdown(\"\", true);"
        print("🌐 执行JavaScript代码: \(jsCode)")
        runJS(jsCode)
    }
    
    /// 设置 Markdown 内容（非流式）
    /// - Parameter markdown: 完整的 Markdown 内容
    @objc(setMarkdownContent:)
    public func setMarkdown(_ markdown: String) {
        print("📝 AITextView.setMarkdown 被调用，内容长度: \(markdown.count), WebView已加载: \(isEditorLoaded)")
        
        if isEditorLoaded {
            print("✅ WebView已加载，直接设置内容")
          // resetMarkdown()
            // 对于一次性完整内容，直接作为当前内容并标记完成
            let escapedMarkdown = escapeJavaScriptString(markdown)
            let jsCode = "RE.streamMarkdownProcessor.updateMarkdown(\"\(escapedMarkdown)\", true);"
            print("🌐 执行JavaScript代码: \(jsCode)")
            runJS(jsCode)
        } 
    }
    
    /// 重置流式状态
    public func resetMarkdown() {
        markdownBuffer = ""
        isStreaming = false
        
        // 调用 JavaScript 重置
        let jsCode = """
        if (window.RE && window.RE.streamMarkdownProcessor) {
            window.RE.streamMarkdownProcessor.reset();
        }
        """
        
        runJS(jsCode) { result in
            print("🔄 Markdown 重置完成")
        }
    }
    
    /// 获取当前 Markdown 内容
    public var currentMarkdownContent: String {
        return markdownBuffer
    }
    
    /// 是否正在流式更新
    public var isCurrentlyStreaming: Bool {
        return isStreaming
    }
    
    /// 使用 JSONEncoder 转义 JavaScript 字符串
    /// - Parameter string: 需要转义的字符串
    /// - Returns: 转义后的字符串（去掉 JSON 编码后的首尾引号）
    private func escapeJavaScriptString(_ string: String) -> String {
        // 使用 JSONEncoder 编码字符串
        // JSONEncoder 需要 Codable 对象，所以我们将字符串包装在数组中
        struct StringArray: Codable {
            let value: String
        }
        
        let wrapper = StringArray(value: string)
        let jsonEncoder = JSONEncoder()
        
        guard let jsonData = try? jsonEncoder.encode(wrapper),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            // 如果编码失败，使用 JSONSerialization 作为备用方案
            return escapeJavaScriptStringWithJSONSerialization(string)
        }
        
        // JSONEncoder 编码后会生成类似 "{\"value\":\"hello\\nworld\"}" 的格式
        // 我们需要提取 value 字段的值部分（去掉首尾的双引号）
        // 查找 "value":" 的位置，然后找到对应的结束引号
        if let prefixRange = jsonString.range(of: "\"value\":\""),
           prefixRange.upperBound < jsonString.endIndex {
            let valueStartIndex = prefixRange.upperBound
            // 从 valueStartIndex 开始查找第一个未转义的双引号
            var searchIndex = valueStartIndex
            var escaped = false
            var foundEnd = false
            
            while searchIndex < jsonString.endIndex {
                let char = jsonString[searchIndex]
                if escaped {
                    escaped = false
                } else if char == "\\" {
                    escaped = true
                } else if char == "\"" {
                    foundEnd = true
                    break
                }
                searchIndex = jsonString.index(after: searchIndex)
            }
            
            if foundEnd && searchIndex > valueStartIndex {
                let escapedValue = String(jsonString[valueStartIndex..<searchIndex])
                return escapedValue
            }
        }
        
        // 如果解析失败，使用备用方案
        return escapeJavaScriptStringWithJSONSerialization(string)
    }
    
    /// 使用 JSONSerialization 转义 JavaScript 字符串（备用方案）
    private func escapeJavaScriptStringWithJSONSerialization(_ string: String) -> String {
        // 使用 JSONSerialization 将字符串编码为 JSON 数组
        // 格式会是 ["escaped_string"]，我们提取 escaped_string 部分
        let jsonArray: [String] = [string]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return string
        }
        
        // 去掉首尾的 [" 和 "]
        // 格式: ["escaped_content"]
        if jsonString.hasPrefix("[\"") && jsonString.hasSuffix("\"]") {
            let startIndex = jsonString.index(jsonString.startIndex, offsetBy: 2)
            let endIndex = jsonString.index(jsonString.endIndex, offsetBy: -2)
            return String(jsonString[startIndex..<endIndex])
        }
        
        return string
    }
    
    /// 测试Base64图片渲染
    public func testBase64Image() {
        let testMarkdown = """
        # Base64图片测试
        
        ## 简单圆形
        ![Test Circle](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSI0MCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIiBmaWxsPSJyZWQiIC8+Cjwvc3ZnPgo=)
        
        ## 彩色矩形
        ![Test Rectangle](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==)
        
        ## 1x1像素图片
        ![Test Pixel](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==)
        
        测试完成！
        """
        
        print("🧪 开始Base64图片测试")
        setMarkdown(testMarkdown)
    }
    
    
    
    
    
    // MARK: - AI流式输出方法
    // MARK: AI Streaming Output Methods
    
    /// Runs some JavaScript on the WKWebView and returns the result
    /// If there is no result, returns an empty string
    /// - parameter js: The JavaScript string to be run
    /// - returns: The result of the JavaScript that was run
    // 执行 JavaScript 并通过闭包异步返回结果
    public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
        // 在 webView 上执行 JavaScript
        webView.evaluateJavaScript(js) { (result, error) in
            // 如果有错误
            if let error = error {
                // 打印错误信息
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                // 调用闭包并传入空字符串
                handler?("")
                return
            }
            
            // 确保 handler 存在
            guard let handler = handler else {
                return
            }
            
            // 如果结果是整数
            if let resultInt = result as? Int {
                // 将整数转为字符串并返回
                handler("\(resultInt)")
                return
            }
            
            // 如果结果是布尔值
            if let resultBool = result as? Bool {
                // 将布尔值转为 "true" 或 "false" 字符串并返回
                handler(resultBool ? "true" : "false")
                return
            }
            
            // 如果结果是字符串
            if let resultStr = result as? String {
                // 直接返回字符串
                handler(resultStr)
                return
            }
            
            // no result
            // 如果没有结果或结果是其他类型，返回空字符串
            handler("")
        }
    }
    
   
    
    // MARK: - 代理方法
    // MARK: - Delegate Methods
    
    
    // MARK: WKWebViewDelegate
    
    // 当 webView 完成加载时调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🌐 WebView 加载完成")
        isEditorLoaded = true
        delegate?.aiTextViewDidLoad?(self)
        
        // 如果有待设置的 Markdown 内容，现在设置它
        if !markdown.isEmpty {
            print("📝 设置待处理的 Markdown 内容")
            setMarkdown(markdown)
        }
    }
    
    // 在 webView 决定是否处理导航操作之前调用
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle pre-defined editor actions
        // 定义一个回调前缀
        let callbackPrefix = "ai-callback://"
        // 如果请求的 URL 以回调前缀开头
        if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            // 执行 JavaScript 获取命令队列
            runJS("RE.getCommandQueue()") { commands in
                // 如果能将命令字符串转为 UTF8 数据
                if let data = commands.data(using: .utf8) {
                    
                    // 定义一个字符串数组用于存储 JSON 命令
                    let jsonCommands: [String]
                    do {
                        // 尝试将 JSON 数据序列化为字符串数组
                        jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                    } catch {
                        // 如果解析失败
                        jsonCommands = []
                        NSLog("AITextView: Failed to parse JSON Commands")
                    }
                    
                    // 遍历并执行每个命令
                    jsonCommands.forEach(self.performCommand)
                }
            }
            // 取消这个导航操作，因为它只是一个回调
            return decisionHandler(WKNavigationActionPolicy.cancel);
        }
        
        // 默认允许导航
        return decisionHandler(WKNavigationActionPolicy.allow);
    }
    
    
    // MARK: - 私有实现细节
    // MARK: - Private Implementation Details
    
    
    
    
    
    /// 滚动到编辑器底部（用于AI内容生成时）
    /// 智能滚动：只有在用户接近底部时才自动滚动，避免打断用户阅读
    /// - Parameter animated: 是否使用动画滚动，默认为true
    public func scrollToBottom(animated: Bool = true) {
        print("📜 开始智能滚动到底部，动画: \(animated)")
        
        let scrollView = webView.scrollView
        let contentHeight = scrollView.contentSize.height
        let viewHeight = scrollView.bounds.height
        let currentOffset = scrollView.contentOffset.y
        
        // 计算距离底部的距离
        let distanceFromBottom = contentHeight - currentOffset - viewHeight
        
        // 如果用户已经滚动到接近底部（距离底部 < 100pt），才自动滚动
        let threshold: CGFloat = 100.0
        if distanceFromBottom < threshold {
            print("✅ 用户在底部附近（距离: \(distanceFromBottom)pt），执行自动滚动")
            // 使用JavaScript进行平滑滚动
            let jsCode = """
            if (window.RE && window.RE.scrollToBottom) {
                window.RE.scrollToBottom();
            } else {
                console.log('RE.scrollToBottom 不存在');
            }
            """
            
            webView.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("❌ JavaScript滚动失败: \(error)")
                    // 备用方案：使用原生滚动
                    DispatchQueue.main.async {
                        let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
                        let offset = CGPoint(x: 0, y: maxOffsetY)
                        print("📜 使用原生滚动，目标位置: \(offset)")
                        scrollView.setContentOffset(offset, animated: animated)
                    }
                } else {
                    print("✅ JavaScript滚动执行成功")
                }
            }
        } else {
            print("⏸️ 用户正在查看上方内容（距离底部: \(distanceFromBottom)pt），不自动滚动")
            // 可以在这里添加"新内容"提示功能
        }
    }
    
   
    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    // 执行从 JavaScript 收到的命令
    private func performCommand(_ method: String) {
        print("🔔 收到 JavaScript 命令: \(method)")
        
        // 如果命令以 "ready" 开头
        if method.hasPrefix("ready") {
            // If loading for the first time, we have to set the content Markdown to be displayed
            // 如果是第一次加载
            if !isEditorLoaded {
                // 标记编辑器已加载
                isEditorLoaded = true
                // 设置初始 Markdown 内容
                setMarkdown(markdown)
                
                // 调用代理的 didLoad 方法
                delegate?.aiTextViewDidLoad?(self)
            }
        }
        else if method.hasPrefix("contentUpdate") {
            // 内容更新回调
            print("📝 内容已更新")
            isStreaming = true
            runJS("RE.getMarkdown()") { [weak self] content in
                self?.markdownBuffer = content
            }
        }
        else if method.hasPrefix("streamComplete") {
            // 流式输出完成
            print("✅ 流式输出完成")
            isStreaming = false
            runJS("RE.getMarkdown()") { [weak self] content in
                self?.markdownBuffer = content
            }
        }
        else if method.hasPrefix("contentReset") {
            // 内容重置
            print("🔄 内容已重置")
        }
        else if method.hasPrefix("heightChange/") {
            // 高度变化
            let heightString = method.replacingOccurrences(of: "heightChange/", with: "")
            if let height = Int(heightString) {
                print("📏 高度变化: \(height)")
                // 可以在这里处理高度变化
            }
        }
        else if method.hasPrefix("themeChange/") {
            // 主题变化
            let theme = method.replacingOccurrences(of: "themeChange/", with: "")
            print("🎨 主题变化: \(theme)")
        }
        else if method.hasPrefix("debug/") {
            // 调试信息
            let debugInfo = method.replacingOccurrences(of: "debug/", with: "")
            print("🐛 JavaScript 调试: \(debugInfo)")
        }
    }
    
    
    
}
