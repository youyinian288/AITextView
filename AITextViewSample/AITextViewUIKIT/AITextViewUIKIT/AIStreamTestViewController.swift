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
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var inputTextView: UITextView!
    private var editorView: AITextView!
    private var sendButton: UIButton!
    private var stopButton: UIButton!
    private var clearButton: UIButton!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    
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
        
        // 创建滚动视图
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // 创建内容视图
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 创建输入文本框
        inputTextView = UITextView()
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 8.0
        inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        inputTextView.placeholder = "请输入您的问题..."
        inputTextView.text = "8月份的AI新闻有哪些"
        contentView.addSubview(inputTextView)
        
        // 创建输出编辑器
        editorView = AITextView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        editorView.editingEnabled = false
        editorView.layer.borderColor = UIColor.systemGray4.cgColor
        editorView.layer.borderWidth = 1.0
        editorView.layer.cornerRadius = 8.0
        editorView.html = "<p style='color: #666; font-style: italic;'>AI回复将在这里显示...</p>"
        contentView.addSubview(editorView)
        
        // 创建发送按钮
        sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("发送请求", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8.0
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        contentView.addSubview(sendButton)
        
        // 创建停止按钮
        stopButton = UIButton(type: .system)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.setTitle("停止生成", for: .normal)
        stopButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8.0
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        contentView.addSubview(stopButton)
        
        // 创建清除按钮
        clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("清除内容", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.backgroundColor = .systemGray
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8.0
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        contentView.addSubview(clearButton)
        
        // 创建状态标签
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        statusLabel.text = "准备就绪"
        statusLabel.textAlignment = .center
        contentView.addSubview(statusLabel)
        
        // 创建进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        contentView.addSubview(progressView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 输入文本框约束
            inputTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            inputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            inputTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // 按钮约束
            sendButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
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
            
            // 状态标签约束
            statusLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 进度条约束
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // 输出编辑器约束
            editorView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            editorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            editorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editorView.heightAnchor.constraint(equalToConstant: 400),
            editorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupInitialState() {
        updateUIState()
    }
    
    // MARK: - Actions
    
    @objc private func sendButtonTapped() {
        guard !isStreaming else { return }
        
        let prompt = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            showAlert(title: "提示", message: "请输入问题内容")
            return
        }
        
        startAIStream(prompt: prompt)
    }
    
    @objc private func stopButtonTapped() {
        stopAIStream()
    }
    
    @objc private func clearButtonTapped() {
        clearContent()
    }
    
    // MARK: - AI Stream Methods
    
    private func startAIStream(prompt: String) {
        isStreaming = true
        message = ""
        errorMessage = ""
        
        updateUIState()
        updateStatus("正在连接AI服务...")
        
        // 使用硬编码的API密钥
        let apiKey = "sk-0afb28dff5ff4381b57f804caf79dd1d"
        let service = OpenAIServiceFactory.service(
            apiKey: apiKey,
            overrideBaseURL: "https://api.deepseek.com"
        )
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text(prompt))],
            model: .custom("deepseek-chat")
        )
        
        currentStreamTask = Task {
            do {
                updateStatus("开始流式输出...")
                progressView.isHidden = false
                progressView.progress = 0.0
                
                let stream = try await service.startStreamedChat(parameters: parameters)
                var progress: Float = 0.0
                
                for try await result in stream {
                    await MainActor.run {
                        let content = result.choices?.first?.delta?.content ?? ""
                        self.message += content
                        
                        // 聊天模型不返回推理内容
                        
                        // 更新显示
                        self.updateOutputDisplay()
                        
                        // 更新进度
                        progress += 0.1
                        self.progressView.progress = min(progress, 0.9)
                    }
                }
                
                await MainActor.run {
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
        
        // 在消息末尾添加停止提示
        if !message.isEmpty {
            message += "\n\n[生成已停止]"
            updateOutputDisplay()
        }
    }
    
    private func updateOutputDisplay() {
        var htmlContent = ""
        
        if !message.isEmpty {
            htmlContent += """
            <div style="background-color: #f8f9fa; border-left: 4px solid #28a745; padding: 12px; margin: 8px 0; border-radius: 4px;">
                <h4 style="color: #28a745; margin: 0 0 8px 0;">💬 AI回复</h4>
                <p style="margin: 0; color: #333; line-height: 1.6;">\(message.replacingOccurrences(of: "\n", with: "<br>"))</p>
            </div>
            """
        }
        
        if !errorMessage.isEmpty {
            htmlContent += """
            <div style="background-color: #fff5f5; border-left: 4px solid #dc3545; padding: 12px; margin: 8px 0; border-radius: 4px;">
                <h4 style="color: #dc3545; margin: 0 0 8px 0;">❌ 错误信息</h4>
                <p style="margin: 0; color: #333;">\(errorMessage)</p>
            </div>
            """
        }
        
        if htmlContent.isEmpty {
            htmlContent = "<p style='color: #666; font-style: italic;'>AI回复将在这里显示...</p>"
        }
        
        editorView.html = htmlContent
    }
    
    private func clearContent() {
        message = ""
        errorMessage = ""
        editorView.html = "<p style='color: #666; font-style: italic;'>AI回复将在这里显示...</p>"
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
}

// MARK: - UITextView Extension for Placeholder

extension UITextView {
    var placeholder: String? {
        get {
            return self.viewWithTag(100)?.accessibilityLabel
        }
        set {
            let placeholderLabel = UILabel()
            placeholderLabel.text = newValue
            placeholderLabel.font = self.font
            placeholderLabel.textColor = UIColor.placeholderText
            placeholderLabel.tag = 100
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(placeholderLabel)
            
            NSLayoutConstraint.activate([
                placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: self.textContainerInset.top),
                placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.textContainerInset.left + self.textContainer.lineFragmentPadding),
                placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.textContainerInset.right)
            ])
            
            NotificationCenter.default.addObserver(
                forName: UITextView.textDidChangeNotification,
                object: self,
                queue: .main
            ) { _ in
                placeholderLabel.isHidden = !self.text.isEmpty
            }
        }
    }
}
