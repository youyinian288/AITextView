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

/// JavaScript 执行错误类型
public enum JSError: Error, CustomStringConvertible {
    case javaScriptError(Error)
    case unexpectedResult(Any?)
    case noResult

    public var description: String {
        switch self {
        case .javaScriptError(let error):
            return "JavaScript execution failed: \(error.localizedDescription)"
        case .unexpectedResult(let result):
            return "Received an unexpected result type: \(String(describing: result))"
        case .noResult:
            return "JavaScript returned no result (null or undefined)."
        }
    }
}
    
    
/// AITextViewDelegate定义了AITextView代理的回调方法
// 定义一个公开的协议 AITextViewDelegate，遵循 AnyObject 协议，意味着只有类可以实现它
@objc public protocol AITextViewDelegate: AnyObject {
    
    /// 当AITextView准备接收输入时调用
    /// 更具体地说，当内部WKWebView首次加载且contentHTML被设置时调用
    // 当编辑器加载完成时，会调用这个可选方法
    @objc optional func aiTextViewDidLoad(_ editor: AITextView)
}

/// AITextView是一个UIView，用于显示AI流式输出的HTML内容
// 定义一个公开的类 AITextView，继承自 UIView，并遵循多个协议
@objcMembers open class AITextView: UIView, WKNavigationDelegate {
    /// 将接收回调的代理，当某些操作完成时
    // 定义一个弱引用的代理，用于接收 AITextViewDelegate 的回调
    open weak var delegate: AITextViewDelegate?
    

    
    
    /// 用于显示文本的内部WKWebView
    // 定义一个内部的 AITextWebView，用于显示编辑器
    open private(set) var webView: AITextWebView
    
    
    
    
    
    /// 编辑器是否已完成加载
    // 定义一个私有布尔值，标记编辑器是否已加载
    private var isEditorLoaded = false
    
    /// 流式 Markdown 处理器
    private var streamMarkdownProcessor: StreamMarkdownProcessor?
    
    /// 是否启用自动滚动（流式输出时）
    public var isAutoScrollEnabled: Bool = true
        
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
        // 初始化流式 Markdown 处理器
        streamMarkdownProcessor = StreamMarkdownProcessor(webView: webView)
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
    // MARK: - AI Streaming Output
    
    
    
    // MARK: - 流式 Markdown 方法
    // MARK: Stream Markdown Methods
    
    /// 流式更新 Markdown 内容
    /// - Parameters:
    ///   - markdown: 新的 Markdown 内容片段
    ///   - isComplete: 是否为完整内容（流式结束）
    public func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
        streamMarkdownProcessor?.updateMarkdownStream(markdown, isComplete: isComplete)
        
        // 如果启用自动滚动，在流式更新时自动滚动到底部
        if isAutoScrollEnabled && !markdown.isEmpty {
            scrollToBottom(animated: true)
        }
    }
    
    /// 设置 Markdown 内容（非流式）
    /// - Parameter markdown: 完整的 Markdown 内容
    @objc(setMarkdownContent:)
    public func setMarkdown(_ markdown: String) {
        print("📝 AITextView.setMarkdown 被调用，内容长度: \(markdown.count), WebView已加载: \(isEditorLoaded)")
        
        if isEditorLoaded {
            print("✅ WebView已加载，直接设置内容")
            streamMarkdownProcessor?.setMarkdown(markdown)
        } else {
            print("⏳ WebView未加载，等待加载完成后设置")
            // WebView 未加载完成时，内容会在 didFinish 中设置
        }
    }
    
    /// 重置流式状态
    public func resetMarkdown() {
        streamMarkdownProcessor?.reset()
    }
    
    /// 获取当前 Markdown 内容
    public var currentMarkdownContent: String {
        return streamMarkdownProcessor?.currentContent ?? ""
    }
    
    /// 是否正在流式更新
    public var isCurrentlyStreaming: Bool {
        return streamMarkdownProcessor?.isCurrentlyStreaming ?? false
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
        let callbackPrefix = "re-callback://"
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
                        NSLog("RichEditorView: Failed to parse JSON Commands")
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
    /// - Parameter animated: 是否使用动画滚动，默认为true
    public func scrollToBottom(animated: Bool = true) {
        // 使用JavaScript进行平滑滚动，这样更准确
        let jsCode = """
        const editor = document.getElementById('editor');
        const scrollView = editor.parentElement;
        
        if (scrollView) {
            scrollView.scrollTo({
                top: scrollView.scrollHeight,
                behavior: 'smooth'
            });
        } else {
            editor.scrollTop = editor.scrollHeight;
        }
        """
        
        webView.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("❌ 滚动失败: \(error)")
                // 备用方案：使用原生滚动
                DispatchQueue.main.async {
                    let scrollView = self.webView.scrollView
                    let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
                    let offset = CGPoint(x: 0, y: maxOffsetY)
                    scrollView.setContentOffset(offset, animated: animated)
                }
            }
        }
    }
    
   
    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    // 执行从 JavaScript 收到的命令
    private func performCommand(_ method: String) {
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
    }
    
    
    
}
