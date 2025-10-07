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
    
/// 在JS完全加载之前，我们保存的行高值
// 定义一个私有常量，作为默认的行高，值为 21
private let DefaultInnerLineHeight: Int = 21
    
/// AITextViewDelegate定义了AITextView代理的回调方法
// 定义一个公开的协议 AITextViewDelegate，遵循 AnyObject 协议，意味着只有类可以实现它
@objc public protocol AITextViewDelegate: AnyObject {
    /// 当显示的文本内部高度发生变化时调用
    /// 可用于更新UI
    // 当编辑器高度变化时，会调用这个可选方法
    @objc optional func aiTextView(_ editor: AITextView, heightDidChange height: Int)
    
    /// 每当视图内的内容发生变化时调用
    // 当编辑器内容变化时，会调用这个可选方法
    @objc optional func aiTextView(_ editor: AITextView, contentDidChange content: String)
    
    /// 当富编辑器开始编辑时调用
    // 当编辑器在特定点获取焦点时，会调用这个可选方法
    @objc optional func aiTextViewTookFocusAt(_ editor: AITextView, at: CGPoint)
  
    /// 当富编辑器开始编辑时调用
    // 当编辑器获取焦点时，会调用这个可选方法
    @objc optional func aiTextViewTookFocus(_ editor: AITextView)
    
    /// 当富编辑器停止编辑或失去焦点时调用
    // 当编辑器失去焦点时，会调用这个可选方法
    @objc optional func aiTextViewLostFocus(_ editor: AITextView)
    
    /// 当AITextView准备接收输入时调用
    /// 更具体地说，当内部WKWebView首次加载且contentHTML被设置时调用
    // 当编辑器加载完成时，会调用这个可选方法
    @objc optional func aiTextViewDidLoad(_ editor: AITextView)
    
    /// 当内部WKWebView开始加载它不知道如何响应的URL时调用
    /// 例如，如果有外部链接，用户点击它时调用
    // 当用户与一个 URL 交互时（例如点击链接），会调用这个可选方法，返回一个布尔值决定是否处理该 URL
    @objc optional func aiTextView(_ editor: AITextView, shouldInteractWith url: URL) -> Bool
    
    /// 当自定义操作被JS中的回调调用时调用
    /// 默认情况下，除非被一些自定义JS调用，否则不会使用此方法
    // 当 JavaScript 调用一个自定义操作时，会调用这个可选方法
    @objc optional func aiTextView(_ editor: AITextView, handle action: String)
}

/// AITextView是一个UIView，用于显示富文本样式，并允许以所见即所得的方式进行编辑
// 定义一个公开的类 AITextView，继承自 UIView，并遵循多个协议
@objcMembers open class AITextView: UIView, UIScrollViewDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    /// 将接收回调的代理，当某些操作完成时
    // 定义一个弱引用的代理，用于接收 AITextViewDelegate 的回调
    open weak var delegate: AITextViewDelegate?
    
    /// 显示在键盘上方的输入附件视图
    /// 默认为nil
    // 重写 inputAccessoryView 属性，用于自定义键盘上方的视图
    open override var inputAccessoryView: UIView? {
        // 获取值时，返回 webView 的 accessoryView
        get { return webView.accessoryView }
        // 设置值时，设置 webView 的 accessoryView
        set { webView.accessoryView = newValue }
    }
    
    /// 是否显示默认的键盘工具栏
    /// 包含一个"完成"按钮用于隐藏键盘
    open var showsKeyboardToolbar: Bool = false {
        didSet {
            updateKeyboardToolbar()
        }
    }
    
    /// 键盘工具栏中"完成"按钮的文本
    /// 默认为"完成"
    open var keyboardToolbarDoneButtonText: String = "Done" {
        didSet {
            if showsKeyboardToolbar {
                updateKeyboardToolbar()
            }
        }
    }
    
    /// 用于显示文本的内部WKWebView
    // 定义一个内部的 AITextWebView，用于显示编辑器
    open private(set) var webView: AITextWebView
    
    /// 视图上的滚动是否启用
    // 定义一个布尔值，控制是否允许滚动
    open var isScrollEnabled: Bool = true {
        // 在属性值改变后执行
        didSet {
            // 将 webView 的 scrollView 的 isScrollEnabled 设置为新值
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    /// 是否允许用户在视图中输入
    // 定义一个布尔值，控制是否允许编辑
    open var editingEnabled: Bool = false {
        // 在属性值改变后执行
        didSet {
            // 将 contentEditable 设置为新值
            contentEditable = editingEnabled
        }
    }
    
    /// 正在显示的文本的内容HTML
    /// 随着文本被编辑而持续更新
    // 定义一个字符串，用于存储编辑器的 HTML 内容
    open private(set) var contentHTML: String = "" {
        // 在属性值改变后执行
        didSet {
            // 调用代理的 contentDidChange 方法
            delegate?.aiTextView?(self, contentDidChange: contentHTML)
        }
    }
    
    /// 正在显示的文本的内部高度
    /// 随着文本编辑而持续更新
    // 定义一个整数，用于存储编辑器的高度
    open private(set) var editorHeight: Int = 0 {
        // 在属性值改变后执行
        didSet {
            // 调用代理的 heightDidChange 方法
            delegate?.aiTextView?(self, heightDidChange: editorHeight)
        }
    }
    
    /// 编辑器的行高。默认为21
    // 定义一个整数，用于存储编辑器的行高
    open private(set) var lineHeight: Int = DefaultInnerLineHeight {
        // 在属性值改变后执行
        didSet {
            // 执行 JavaScript 来设置行高
            runJS("RE.setLineHeight('\(lineHeight)px')")
        }
    }
    
    /// 编辑器是否已完成加载
    // 定义一个私有布尔值，标记编辑器是否已加载
    private var isEditorLoaded = false
    
    /// 存储编辑器加载后内容是否应该可编辑的值
    /// 基本上是编辑器加载前的"isEditingEnabled"
    // 定义一个私有布尔值，在编辑器加载前保存 editingEnabled 的状态
    private var editingEnabledVar = true
        
    /// 当前加载在编辑器视图中的HTML，如果已加载。如果尚未加载，则是编辑器视图初始化完成后要加载的HTML
    // 定义一个字符串，用于设置或获取编辑器的 HTML 内容
    public var html: String = "" {
        // 在属性值改变后执行
        didSet {
            // 调用 setHTML 方法来更新内容
            setHTML(html)
        }
    }
    
    /// 私有变量，用于保存占位符文本，因此你可以在编辑器加载之前设置占位符
    // 定义一个私有字符串，用于存储占位符文本
    private var placeholderText: String = ""
    /// 当没有用户输入时要显示的占位符文本
    // 定义一个公开的计算属性，用于设置或获取占位符
    open var placeholder: String {
        // 获取值时，返回私有变量 placeholderText
        get { return placeholderText }
        // 设置值时
        set {
            // 更新私有变量
            placeholderText = newValue
            // 如果编辑器已加载
            if isEditorLoaded {
                // 执行 JavaScript 来设置占位符，注意对特殊字符进行转义
                runJS("RE.setPlaceholderText('\(newValue.escaped)')")
            }
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
        // 设置 webView 的 scrollView 的滚动属性
        webView.scrollView.isScrollEnabled = isScrollEnabled
        // 启用 scrollView 的弹簧效果
        webView.scrollView.bounces = true
        // 设置 scrollView 的代理为 self
        webView.scrollView.delegate = self
        // 允许 scrollView 的内容超出其边界
        webView.scrollView.clipsToBounds = false
        // 将 webView 添加到当前视图
        addSubview(webView)
        // 加载编辑器 HTML 文件
        loadRichEditorView()
    }

    // 私有方法，用于加载编辑器视图
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
        // 获取 rich_editor.html 文件的路径
        if let filePath = bundle.path(forResource: "rich_editor", ofType: "html") {
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
        fatalError("Failed to load rich_editor.html, check your dependency configuration")
    }
    
    // MARK: - 富文本编辑
    // MARK: - Rich Text Editing
    
    // 检查编辑器是否可编辑，并通过闭包异步返回结果
    open func isEditingEnabled(handler: @escaping (Bool) -> Void) {
        isContentEditable(handler: handler)
    }
    
    // 获取行高，并通过闭包异步返回结果
    private func getLineHeight(handler: @escaping (Int) -> Void) {
        // 如果编辑器已加载
        if isEditorLoaded {
            // 执行 JavaScript 获取行高
            runJS("RE.getLineHeight()") { r in
                // 如果能将返回结果转为整数
                if let r = Int(r) {
                    // 调用闭包并传入整数值
                    handler(r)
                } else {
                    // 否则，传入默认行高
                    handler(DefaultInnerLineHeight)
                }
            }
        } else {
            // 如果编辑器未加载，直接传入默认行高
            handler(DefaultInnerLineHeight)
        }
    }
    
    // 设置编辑器的 HTML 内容
    private func setHTML(_ value: String) {
        // 如果编辑器已加载
        if isEditorLoaded {
            // 执行 JavaScript 设置 HTML 内容，注意转义
            runJS("RE.setHtml('\(value.escaped)')") { _ in
                // 设置完后更新编辑器高度
                self.updateHeight()
            }
        }
    }
    
    /// The inner height of the editor div.
    /// Fetches it from JS every time, so might be slow!
    // 获取编辑器内部 div 的高度，并通过闭包异步返回结果
    private func getClientHeight(handler: @escaping (Int) -> Void) {
        // 执行 JavaScript 获取高度
        runJS("document.getElementById('editor').clientHeight") { r in
            // 如果能将返回结果转为整数
            if let r = Int(r) {
                // 调用闭包并传入整数值
                handler(r)
            } else {
                // 否则，传入 0
                handler(0)
            }
        }
    }
    
    // 获取编辑器的 HTML 内容，并通过闭包异步返回结果
    public func getHtml(handler: @escaping (String) -> Void) {
        runJS("RE.getHtml()") { r in
            handler(r)
        }
    }
    
    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    // 获取编辑器的纯文本内容，并通过闭包异步返回结果
    public func getText(handler: @escaping (String) -> Void) {
        runJS("RE.getText()") { r in
            handler(r)
        }
    }
    
    /// The href of the current selection, if the current selection's parent is an anchor tag.
    /// Will be nil if there is no href, or it is an empty string.
    // 获取当前选中链接的 href，并通过闭包异步返回结果
    public func getSelectedHref(handler: @escaping (String?) -> Void) {
        // 检查是否有范围选择
        hasRangeSelection(handler: { r in
            // 如果没有范围选择
            if !r {
                // 返回 nil
                handler(nil)
                return
            }
            // 执行 JavaScript 获取选中的 href
            self.runJS("RE.getSelectedHref()") { r in
                // 如果返回结果为空字符串
                if r == "" {
                    // 返回 nil
                    handler(nil)
                } else {
                    // 否则，返回结果
                    handler(r)
                }
            }
        })
    }
    
    /// Whether or not the selection has a type specifically of "Range".
    // 检查当前选择是否是范围选择（即选中了一段文本），并通过闭包异步返回结果
    public func hasRangeSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }
    
    /// Whether or not the selection has a type specifically of "Range" or "Caret".
    // 检查当前是否有选择（范围选择或光标），并通过闭包异步返回结果
    public func hasRangeOrCaretSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeOrCaretSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }
    
    // MARK: - 方法
    // MARK: Methods
    
    // 移除格式
    public func removeFormat() {
        runJS("RE.removeFormat()")
    }
    
    // 设置字体大小
    public func setFontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px')")
    }
    
    // 设置编辑器背景颜色
    public func setEditorBackgroundColor(_ color: UIColor) {
        // 使用 color.hex 将 UIColor 转为十六进制字符串
        runJS("RE.setBackgroundColor('\(color.hex)')")
    }
    
    // 撤销
    public func undo() {
        runJS("RE.undo()")
    }
    
    // 重做
    public func redo() {
        runJS("RE.redo()")
    }
    
    // 设置粗体
    public func bold() {
        runJS("RE.setBold()")
    }
    
    // 设置斜体
    public func italic() {
        runJS("RE.setItalic()")
    }
    
    // "superscript" is a keyword
    // 设置下标
    public func subscriptText() {
        runJS("RE.setSubscript()")
    }
    
    // 设置上标
    public func superscript() {
        runJS("RE.setSuperscript()")
    }
    
    // 设置删除线
    public func strikethrough() {
        runJS("RE.setStrikeThrough()")
    }
    
    // 设置下划线
    public func underline() {
        runJS("RE.setUnderline()")
    }
    
    // 设置文字颜色
    public func setTextColor(_ color: UIColor) {
        // 准备插入，这可能会恢复之前的选择
        runJS("RE.prepareInsert()")
        // 设置颜色
        runJS("RE.setTextColor('\(color.hex)')")
    }
    
    // 设置编辑器默认字体颜色
    public func setEditorFontColor(_ color: UIColor) {
        runJS("RE.setBaseTextColor('\(color.hex)')")
    }
    
    // 设置文字背景颜色
    public func setTextBackgroundColor(_ color: UIColor) {
        // 准备插入
        runJS("RE.prepareInsert()")
        // 设置背景颜色
        runJS("RE.setTextBackgroundColor('\(color.hex)')")
    }
    
    // 设置标题 (h1, h2, etc.)
    public func header(_ h: Int) {
        runJS("RE.setHeading('\(h)')")
    }
    
    // 增加缩进
    public func indent() {
        runJS("RE.setIndent()")
    }
    
    // 减少缩进
    public func outdent() {
        runJS("RE.setOutdent()")
    }
    
    // 设置有序列表
    public func orderedList() {
        runJS("RE.setOrderedList()")
    }
    
    // 设置无序列表
    public func unorderedList() {
        runJS("RE.setUnorderedList()")
    }
    
    // 设置引用块
    public func blockquote() {
        runJS("RE.setBlockquote()");
    }
    
    // 左对齐
    public func alignLeft() {
        runJS("RE.setJustifyLeft()")
    }
    
    // 居中对齐
    public func alignCenter() {
        runJS("RE.setJustifyCenter()")
    }
    
    // 右对齐
    public func alignRight() {
        runJS("RE.setJustifyRight()")
    }
    
    // 插入图片
    public func insertImage(_ url: String, alt: String) {
        // 准备插入
        runJS("RE.prepareInsert()")
        // 插入图片，注意对 url 和 alt 进行转义
        runJS("RE.insertImage('\(url.escaped)', '\(alt.escaped)')")
    }
    
    // 插入链接
    public func insertLink(_ href: String, title: String) {
        // 准备插入
        runJS("RE.prepareInsert()")
        // 插入链接，注意对 href 和 title 进行转义
        runJS("RE.insertLink('\(href.escaped)', '\(title.escaped)')")
    }
    
    // 让编辑器获取焦点
    public func focus() {
        runJS("RE.focus()")
    }
    
    // 让编辑器在特定点获取焦点
    public func focus(at: CGPoint) {
        // 调用代理方法
        delegate?.aiTextViewTookFocusAt?(self, at: at)
        // 执行 JavaScript 在特定点聚焦
        runJS("RE.focusAtPoint(\(at.x), \(at.y))")
    }
    
    // 让编辑器失去焦点
    public func blur() {
        runJS("RE.blurFocus()")
    }
    
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
    
    // MARK: - Async/Await 版本
    @available(iOS 13.0, *)
    @MainActor // 确保在主线程调用，因为 WKWebView 只能在主线程操作
    public func runJS(_ js: String) async throws -> String {
        // 使用 withCheckedThrowingContinuation 包装闭包回调
        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(js) { (result, error) in
                // 1. 处理错误
                if let error = error {
                    // 如果 JS 执行出错，就抛出自定义错误
                    continuation.resume(throwing: JSError.javaScriptError(error))
                    return
                }

                // 2. 处理各种成功的结果类型
                if let resultInt = result as? Int {
                    continuation.resume(returning: "\(resultInt)")
                } else if let resultDouble = result as? Double {
                    // 处理浮点数，包括 NaN 和无穷大
                    if resultDouble.isNaN {
                        continuation.resume(returning: "0") // NaN 转换为 0
                    } else if resultDouble.isInfinite {
                        continuation.resume(returning: "0") // 无穷大转换为 0
                    } else {
                        continuation.resume(returning: "\(Int(resultDouble.rounded()))") // 四舍五入为整数
                    }
                } else if let resultBool = result as? Bool {
                    continuation.resume(returning: resultBool ? "true" : "false")
                } else if let resultStr = result as? String {
                    continuation.resume(returning: resultStr)
                } else if result == nil { // 明确处理 JS 的 null 或 undefined
                    continuation.resume(returning: "")
                } else {
                    // 如果是其他无法处理的类型，可以返回空字符串或抛出错误
                    // 这里我们选择抛出一个更具体的错误
                    continuation.resume(throwing: JSError.unexpectedResult(result))
                }
            }
        }
    }
    
    // MARK: - 代理方法
    // MARK: - Delegate Methods
    
    // MARK: UIScrollViewDelegate
    
    // 当 scrollView 滚动时调用
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        // 如果禁止滚动
        if !isScrollEnabled {
            // 将 scrollView 的 bounds 设置为 webView 的 bounds，防止键盘弹出时偏移
            scrollView.bounds = webView.bounds
        }
    }
    
    // MARK: WKWebViewDelegate
    
    // 当 webView 完成加载时调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // empy
        // 空实现
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
        
        // User is tapping on a link, so we should react accordingly
        // 如果导航类型是点击链接
        if navigationAction.navigationType == .linkActivated {
            // 如果请求的 URL 存在
            if let url = navigationAction.request.url {
                // 调用代理方法，询问是否应该处理这个 URL
                if delegate?.aiTextView?(self, shouldInteractWith: url) ?? false {
                    // 如果代理返回 true，允许导航
                    return decisionHandler(WKNavigationActionPolicy.allow);
                }
            }
        }
        
        // 默认允许导航
        return decisionHandler(WKNavigationActionPolicy.allow);
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    /// Delegate method for our UITapGestureDelegate.
    /// Since the internal web view also has gesture recognizers, we have to make sure that we actually receive our taps.
    // 决定两个手势识别器是否可以同时识别
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 返回 true，允许同时识别，确保我们能接收到点击事件
        return true
    }
    
    // MARK: - 私有实现细节
    // MARK: - Private Implementation Details
    
    // 定义一个私有计算属性，用于控制编辑器是否可编辑
    private var contentEditable: Bool = false {
        // 在属性值改变后执行
        didSet {
            // 更新 editingEnabledVar
            editingEnabledVar = contentEditable
            // 如果编辑器已加载
            if isEditorLoaded {
                // 根据 contentEditable 的值设置 JavaScript 中的 contentEditable 属性
                let value = (contentEditable ? "true" : "false")
                runJS("RE.editor.contentEditable = \(value)")
            }
        }
    }
    // 异步检查内容是否可编辑
    private func isContentEditable(handler: @escaping (Bool) -> Void) {
        if isEditorLoaded {				
            // to get the "editable" value is a different property, than to disable it
            // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/contentEditable
            // 执行 JavaScript 获取 isContentEditable 属性值
            runJS("RE.editor.isContentEditable") { value in
                // 更新 editingEnabledVar
                self.editingEnabledVar = Bool(value) ?? false
            }
        }
    }
    
    /// The position of the caret relative to the currently shown content.
    /// For example, if the cursor is directly at the top of what is visible, it will return 0.
    /// This also means that it will be negative if it is above what is currently visible.
    /// Can also return 0 if some sort of error occurs between JS and here.
    // 获取光标相对于可见区域的 Y 坐标，并通过闭包异步返回
    private func relativeCaretYPosition(handler: @escaping (Int) -> Void) {
        runJS("RE.getRelativeCaretYPosition()") { r in
            handler(Int(r) ?? 0)
        }
    }
    
    // MARK: - Async/Await 版本的辅助函数
    @available(iOS 13.0, *)
    private func getLineHeight() async -> Int {
        if isEditorLoaded {
            do {
                let result = try await runJS("RE.getLineHeight()")
                return Int(result) ?? DefaultInnerLineHeight
            } catch {
                print("Error getting line height: \(error)")
                return DefaultInnerLineHeight
            }
        } else {
            return DefaultInnerLineHeight
        }
    }
    
    @available(iOS 13.0, *)
    private func getClientHeight() async -> Int {
        do {
            let result = try await runJS("document.getElementById('editor').clientHeight")
            return Int(result) ?? 0
        } catch {
            print("Error getting client height: \(error)")
            return 0
        }
    }
    
    @available(iOS 13.0, *)
    private func relativeCaretYPosition() async -> Int {
        do {
            let result = try await runJS("RE.getRelativeCaretYPosition()")
            return Int(result) ?? 0
        } catch {
            print("Error getting relative caret position: \(error)")
            return 0
        }
    }
    
    // 更新编辑器高度
    private func updateHeight() {
        // 执行 JavaScript 获取编辑器 div 的 clientHeight
        runJS("document.getElementById('editor').clientHeight") { heightString in
            // 将返回的高度字符串转为整数
            let height = Int(heightString) ?? 0
            // 如果获取到的高度与当前存储的高度不同
            if self.editorHeight != height {
                // 更新编辑器高度
                self.editorHeight = height
            }
        }
    }
    
    /// Scrolls the editor to a position where the caret is visible.
    /// Called repeatedly to make sure the caret is always visible when inputting text.
    /// Works only if the `lineHeight` of the editor is available.
    // 滚动编辑器，确保光标可见
    private func scrollCaretToVisible() {
        // 获取 webView 的 scrollView
        let scrollView = self.webView.scrollView
        
        // 获取编辑器客户端高度
        getClientHeight(handler: { clientHeight in
            // 计算内容高度
            let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
            // 设置 scrollView 的 contentSize
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
            
            // XXX: Maybe find a better way to get the cursor height
            // 获取行高
            self.getLineHeight(handler: { lh in
                // 计算光标高度
                let lineHeight = CGFloat(lh)
                let cursorHeight = lineHeight - 4
                // 获取光标相对位置
                self.relativeCaretYPosition(handler: { r in
                    // 可见位置
                    let visiblePosition = CGFloat(r)
                    // 定义一个可选的偏移量
                    var offset: CGPoint?
                    
                    // 如果光标在可见区域下方
                    if visiblePosition + cursorHeight > scrollView.bounds.size.height {
                        // Visible caret position goes further than our bounds
                        // 计算新的偏移量，使光标滚动到可见区域
                        offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
                    // 如果光标在可见区域上方
                    } else if visiblePosition < 0 {
                        // Visible caret position is above what is currently visible
                        // 计算新的偏移量
                        var amount = scrollView.contentOffset.y + visiblePosition
                        // 确保偏移量不小于 0
                        amount = amount < 0 ? 0 : amount
                        offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
                    }
                    
                    // 如果计算出了新的偏移量
                    if let offset = offset {
                        // 带动画地设置 scrollView 的 contentOffset
                        scrollView.setContentOffset(offset, animated: true)
                    }
                })
            })
        })
    }
    
    /// Scrolls the editor to a position where the caret is visible (Async/Await version).
    /// Called repeatedly to make sure the caret is always visible when inputting text.
    /// Works only if the `lineHeight` of the editor is available.
    /// 
    /// Usage example:
    /// ```swift
    /// Task {
    ///     await scrollCaretToVisible()
    /// }
    /// ```
    // 滚动编辑器，确保光标可见 (Async/Await 版本)
    @available(iOS 13.0, *)
    private func scrollCaretToVisible() async {
        // 获取 webView 的 scrollView
        let scrollView = self.webView.scrollView
        
        // 获取编辑器客户端高度
        let clientHeight = await getClientHeight()
        // 计算内容高度
        let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
        // 设置 scrollView 的 contentSize
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
        
        // XXX: Maybe find a better way to get the cursor height
        // 获取行高
        let lineHeightInt = await getLineHeight()
        // 计算光标高度
        let lineHeight = CGFloat(lineHeightInt)
        let cursorHeight = lineHeight - 4
        
        // 获取光标相对位置
        let relativePosition = await relativeCaretYPosition()
        // 可见位置
        let visiblePosition = CGFloat(relativePosition)
        // 定义一个可选的偏移量
        var offset: CGPoint?
        
        // 如果光标在可见区域下方
        if visiblePosition + cursorHeight > scrollView.bounds.size.height {
            // Visible caret position goes further than our bounds
            // 计算新的偏移量，使光标滚动到可见区域
            offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
        // 如果光标在可见区域上方
        } else if visiblePosition < 0 {
            // Visible caret position is above what is currently visible
            // 计算新的偏移量
            var amount = scrollView.contentOffset.y + visiblePosition
            // 确保偏移量不小于 0
            amount = amount < 0 ? 0 : amount
            offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
        }
        
        // 如果计算出了新的偏移量
        if let offset = offset {
            // 带动画地设置 scrollView 的 contentOffset
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    /// Public async version of scrollCaretToVisible for external use
    /// 公开的异步版本，供外部调用
    @available(iOS 13.0, *)
    public func scrollCaretToVisibleAsync() async {
        await scrollCaretToVisible()
    }
    
    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    // 执行从 JavaScript 收到的命令
    private func performCommand(_ method: String) {
        // 如果命令以 "ready" 开头
        if method.hasPrefix("ready") {
            // If loading for the first time, we have to set the content HTML to be displayed
            // 如果是第一次加载
            if !isEditorLoaded {
                // 标记编辑器已加载
                isEditorLoaded = true
                // 设置初始 HTML 内容
                setHTML(html)
                // 更新 contentHTML 属性
                contentHTML = html
                // 设置可编辑状态
                contentEditable = editingEnabledVar
                // 设置占位符
                placeholder = placeholderText
                // 设置行高
                lineHeight = DefaultInnerLineHeight
                
                // 调用代理的 didLoad 方法
                delegate?.aiTextViewDidLoad?(self)
            }
            // 更新高度
            updateHeight()
        }
        // 如果命令以 "input" 开头
        else if method.hasPrefix("input") {
            // 滚动以确保光标可见
            if #available(iOS 13.0, *) {
                Task {
                    await scrollCaretToVisible()
                }
            } else {
                scrollCaretToVisible()
            }
            // 获取最新的 HTML 内容
            runJS("RE.getHtml()") { content in
                // 更新 contentHTML
                self.contentHTML = content
                // 更新高度
                self.updateHeight()
            }
        }
        // 如果命令以 "updateHeight" 开头
        else if method.hasPrefix("updateHeight") {
            // 更新高度
            updateHeight()
        }
        // 如果命令以 "focus" 开头
        else if method.hasPrefix("focus") {
            // 调用代理的 tookFocus 方法
            delegate?.aiTextViewTookFocus?(self)
        }
        // 如果命令以 "blur" 开头
        else if method.hasPrefix("blur") {
            // 调用代理的 lostFocus 方法
            delegate?.aiTextViewLostFocus?(self)
        }
        // 如果命令以 "action/" 开头
        else if method.hasPrefix("action/") {
            // 获取最新的 HTML 内容
            runJS("RE.getHtml()") { content in
                // 更新 contentHTML
                self.contentHTML = content
                
                // If there are any custom actions being called
                // We need to tell the delegate about it
                // 定义动作前缀
                let actionPrefix = "action/"
                // 获取前缀的范围
                let range = method.range(of: actionPrefix)!
                // 提取动作名称
                let action = method.replacingCharacters(in: range, with: "")
                
                // 调用代理的 handle action 方法
                self.delegate?.aiTextView?(self, handle: action)
            }
        }
    }
    
    // MARK: - 响应者处理
    // MARK: - Responder Handling
    
    // 覆盖 becomeFirstResponder 方法，使其成为第一响应者
    override open func becomeFirstResponder() -> Bool {
        // 如果 webView 还不是第一响应者
        if !webView.isFirstResponder {
            // 让编辑器获取焦点
            focus()
            // 返回 true 表示成功
            return true
        } else {
            // 否则返回 false
            return false
        }
    }
    
    // 覆盖 resignFirstResponder 方法，使其辞去第一响应者
    open override func resignFirstResponder() -> Bool {
        // 让编辑器失去焦点
        blur()
        // 返回 true
        return true
    }
    
    // MARK: - 键盘工具栏
    // MARK: - Keyboard Toolbar
    
    /// 更新键盘工具栏
    private func updateKeyboardToolbar() {
        if showsKeyboardToolbar {
            inputAccessoryView = createKeyboardToolbar()
        } else {
            inputAccessoryView = nil
        }
    }
    
    /// 创建键盘工具栏
    private func createKeyboardToolbar() -> UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.barStyle = .default
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: keyboardToolbarDoneButtonText, style: .done, target: self, action: #selector(keyboardToolbarDoneButtonTapped))
        ]
        keyboardToolbar.sizeToFit()
        return keyboardToolbar
    }
    
    /// 键盘工具栏Done按钮点击处理
    @objc private func keyboardToolbarDoneButtonTapped() {
        resignFirstResponder()
    }
    
}
