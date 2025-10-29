//
//  AITextWebView.swift
//  AITextView
//
//  Created by C. Bess on 9/18/19.
//

// 导入 WebKit 框架，用于显示网页内容
import WebKit

// 定义一个公开的类 AITextWebView，继承自 WKWebView
public class AITextWebView: WKWebView {

    // 定义一个可选的 UIView，用作键盘附件视图
    public var accessoryView: UIView?
    
    // 重写 inputAccessoryView 计算属性
    public override var inputAccessoryView: UIView? {
        // 返回我们自定义的 accessoryView
        return accessoryView
    }
    
    // 自定义初始化方法，配置支持图片加载
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        // 配置允许加载图片和媒体内容
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsPictureInPictureMediaPlayback = true
        
        // 允许加载本地和网络资源
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        // 设置用户代理，确保兼容性
        configuration.applicationNameForUserAgent = "AITextView/1.0"
        
        super.init(frame: frame, configuration: configuration)
    }
    
    // 便利初始化方法
    public convenience init() {
        let config = WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
