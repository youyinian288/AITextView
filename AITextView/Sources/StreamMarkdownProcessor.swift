import Foundation
import WebKit

/// 流式 Markdown 处理器
/// 负责处理 AI 生成的 Markdown 内容，通过 JavaScript 调用 markdown-it 进行解析和渲染
public class StreamMarkdownProcessor {
    
    // MARK: - Properties
    
    private weak var webView: WKWebView?
    private var buffer: String = ""
    private var isStreaming: Bool = false
    
    // MARK: - Initialization
    
    /// 初始化流式 Markdown 处理器
    /// - Parameter webView: 用于渲染的 WebView 实例
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - Public Methods
    
    /// 流式更新 Markdown 内容
    /// - Parameters:
    ///   - markdown: 新的 Markdown 内容片段
    ///   - isComplete: 是否为完整内容（流式结束）
    public func updateMarkdownStream(_ markdown: String, isComplete: Bool = false) {
        print("📝 StreamMarkdownProcessor.updateMarkdownStream 被调用，片段长度: \(markdown.count), 是否完成: \(isComplete)")
        buffer += markdown
        isStreaming = !isComplete
        
        // 转义 JavaScript 字符串中的特殊字符
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        
        // 调用 JavaScript 进行 markdown-it 解析
        let jsCode = """
        if (window.streamMarkdownProcessor) {
            window.streamMarkdownProcessor.updateMarkdown('\(escapedMarkdown)', \(isComplete));
        }
        """
        
        print("🌐 执行JavaScript代码: \(jsCode)")
        webView?.evaluateJavaScript(jsCode) { [weak self] result, error in
            if let error = error {
                print("❌ Markdown streaming error: \(error)")
            } else {
                print("✅ JavaScript执行成功")
            }
            
            // 如果流式结束，只重置流式状态，不清空内容
            if isComplete {
                self?.isStreaming = false
                print("✅ 流式输出完成，保持内容显示")
            }
        }
    }
    
    /// 重置流式状态
    public func reset() {
        buffer = ""
        isStreaming = false
        
        // 调用 JavaScript 重置
        let jsCode = """
        if (window.streamMarkdownProcessor) {
            window.streamMarkdownProcessor.reset();
        }
        """
        
        webView?.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("Markdown reset error: \(error)")
            }
        }
    }
    
    /// 设置 Markdown 内容（非流式）
    /// - Parameter markdown: 完整的 Markdown 内容
    public func setMarkdown(_ markdown: String) {
        print("🔄 StreamMarkdownProcessor.setMarkdown 被调用，内容长度: \(markdown.count)")
        reset()
        updateMarkdownStream(markdown, isComplete: true)
    }
    
    /// 获取当前缓冲区内容
    public var currentContent: String {
        return buffer
    }
    
    /// 是否正在流式更新
    public var isCurrentlyStreaming: Bool {
        return isStreaming
    }
}

