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
    public var accessoryView: UIView?
    
    public override var inputAccessoryView: UIView? {
        return accessoryView
    }
}
