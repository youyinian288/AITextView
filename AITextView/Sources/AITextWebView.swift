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
}
