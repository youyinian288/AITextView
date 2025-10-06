//
//  AITextOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

// 导入 UIKit 框架，用于构建 iOS 用户界面
import UIKit

/// AITextOption对象是可以显示在AITextToolbar中的对象
/// 此协议用于允许在AITextOptions枚举中未提供的自定义操作
// 定义一个公开的协议 AITextOption，用于定义工具栏选项的接口
public protocol AITextOption {

    /// 要在AITextToolbar中显示的图像
    // 定义一个可选的 UIImage 属性，用于在工具栏中显示图标
    var image: UIImage? { get }

    /// 项目的标题
    /// 如果`image`为nil，则这将用于在AITextToolbar中显示
    // 定义一个字符串属性，用于显示选项的标题（如果没有图片的话）
    var title: String { get }

    /// 被点击时调用的操作
    /// - parameter editor: 在点击时显示AITextOption的AITextToolbar
    ///                     包含对执行操作的`editor` AITextView的引用
    // 定义一个方法，当选项被点击时调用
    func action(_ editor: AITextToolbar)
}

/// AITextOptionItem是AITextOption的具体实现
/// 它可以用作要在AITextToolbar上显示的自定义对象的配置对象
// 定义一个公开的结构体 AITextOptionItem，实现 AITextOption 协议
public struct AITextOptionItem: AITextOption {

    /// 在AITextToolbar中显示时应显示的图像
    // 定义一个可选的 UIImage 属性，用于存储选项的图标
    public var image: UIImage?

    /// 如果未指定`itemImage`，则用于显示
    // 定义一个字符串属性，用于存储选项的标题
    public var title: String

    /// 被点击时要执行的操作
    // 定义一个闭包属性，用于存储点击时要执行的操作
    public var handler: ((AITextToolbar) -> Void)

    /// 初始化
    // 定义一个初始化器
    public init(image: UIImage?, title: String, action: @escaping ((AITextToolbar) -> Void)) {
        // 设置图标
        self.image = image
        // 设置标题
        self.title = title
        // 设置操作处理器
        self.handler = action
    }
    
    // MARK: AITextOption
    
    /// 实现AITextOption协议的action方法
    // 实现协议中的 action 方法
    public func action(_ toolbar: AITextToolbar) {
        // 调用存储的处理器闭包
        handler(toolbar)
    }
}

/// AITextOptions是标准编辑器操作的枚举
// 定义一个公开的枚举 AITextDefaultOption，实现 AITextOption 协议，包含所有预定义的编辑器操作
public enum AITextDefaultOption: AITextOption {

    /// 清除格式
    // 清除文本的所有格式（如粗体、斜体等）
    case clear
    /// 撤销
    // 撤销上一步操作
    case undo
    /// 重做
    // 重做上一步被撤销的操作
    case redo
    /// 粗体
    // 设置文本为粗体
    case bold
    /// 斜体
    // 设置文本为斜体
    case italic
    /// 下标
    // 设置文本为下标格式（如 H₂O 中的 ₂）
    case `subscript`
    /// 上标
    // 设置文本为上标格式（如 x² 中的 ²）
    case superscript
    /// 删除线
    // 给文本添加删除线
    case strike
    /// 下划线
    // 给文本添加下划线
    case underline
    /// 文本颜色
    // 改变文本颜色
    case textColor
    /// 文本背景颜色
    // 改变文本的背景颜色
    case textBackgroundColor
    /// 标题
    // 设置标题级别（1-6），关联值表示标题级别
    case header(Int)
    /// 增加缩进
    // 增加文本的缩进
    case indent
    /// 减少缩进
    // 减少文本的缩进
    case outdent
    /// 有序列表
    // 创建有序列表（1, 2, 3...）
    case orderedList
    /// 无序列表
    // 创建无序列表（• • •）
    case unorderedList
    /// 左对齐
    // 设置文本左对齐
    case alignLeft
    /// 居中对齐
    // 设置文本居中对齐
    case alignCenter
    /// 右对齐
    // 设置文本右对齐
    case alignRight
    /// 插入图像
    // 插入图片
    case image
    /// 插入链接
    // 插入超链接
    case link
    
    /// 所有默认选项
    // 定义一个静态常量数组，包含所有预定义的编辑器选项
    public static let all: [AITextDefaultOption] = [
        //.clear,  // 清除格式选项（被注释掉）
        // 撤销和重做
        .undo, .redo, 
        // 基本文本格式
        .bold, .italic,
        // 特殊文本格式
        .subscript, .superscript, .strike, .underline,
        // 颜色选项
        .textColor, .textBackgroundColor,
        // 标题选项（H1-H6）
        .header(1), .header(2), .header(3), .header(4), .header(5), .header(6),
        // 缩进和列表
        .indent, outdent, orderedList, unorderedList,
        // 对齐选项
        .alignLeft, .alignCenter, .alignRight, 
        // 插入选项
        .image, .link
    ]

    // MARK: AITextOption

    /// 图像
    // 计算属性：根据选项类型返回相应的图标
    public var image: UIImage? {
        // 定义一个字符串变量来存储图片名称
        var name = ""
        // 根据当前选项类型确定对应的图片名称
        switch self {
        case .clear: name = "clear"                    // 清除格式图标
        case .undo: name = "undo"                      // 撤销图标
        case .redo: name = "redo"                      // 重做图标
        case .bold: name = "bold"                      // 粗体图标
        case .italic: name = "italic"                  // 斜体图标
        case .subscript: name = "subscript"            // 下标图标
        case .superscript: name = "superscript"        // 上标图标
        case .strike: name = "strikethrough"           // 删除线图标
        case .underline: name = "underline"            // 下划线图标
        case .textColor: name = "text_color"           // 文字颜色图标
        case .textBackgroundColor: name = "bg_color"   // 背景颜色图标
        case .header(let h): name = "h\(h)"            // 标题图标（h1, h2, etc.）
        case .indent: name = "indent"                  // 增加缩进图标
        case .outdent: name = "outdent"                // 减少缩进图标
        case .orderedList: name = "ordered_list"       // 有序列表图标
        case .unorderedList: name = "unordered_list"   // 无序列表图标
        case .alignLeft: name = "justify_left"         // 左对齐图标
        case .alignCenter: name = "justify_center"     // 居中对齐图标
        case .alignRight: name = "justify_right"       // 右对齐图标
        case .image: name = "insert_image"             // 插入图片图标
        case .link: name = "insert_link"               // 插入链接图标
        }

        // 获取包含图片资源的 Bundle
        let bundle: Bundle
    // 如果是 Swift Package Manager 环境
    #if SWIFT_PACKAGE
        // 使用 Bundle.module 获取当前的 package bundle
        bundle = Bundle.module
    #else
        // 否则，获取包含 AITextToolbar 类的 bundle
        bundle = Bundle(for: AITextToolbar.self)
    #endif
        // 从 bundle 中加载指定名称的图片并返回
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    /// 标题
    // 计算属性：根据选项类型返回相应的本地化标题
    public var title: String {
        // 根据当前选项类型返回对应的本地化字符串
        switch self {
        case .clear: return NSLocalizedString("Clear", comment: "")                       // "清除"
        case .undo: return NSLocalizedString("Undo", comment: "")                        // "撤销"
        case .redo: return NSLocalizedString("Redo", comment: "")                        // "重做"
        case .bold: return NSLocalizedString("Bold", comment: "")                        // "粗体"
        case .italic: return NSLocalizedString("Italic", comment: "")                    // "斜体"
        case .subscript: return NSLocalizedString("Sub", comment: "")                    // "下标"
        case .superscript: return NSLocalizedString("Super", comment: "")                // "上标"
        case .strike: return NSLocalizedString("Strike", comment: "")                    // "删除线"
        case .underline: return NSLocalizedString("Underline", comment: "")              // "下划线"
        case .textColor: return NSLocalizedString("Color", comment: "")                  // "颜色"
        case .textBackgroundColor: return NSLocalizedString("BG Color", comment: "")     // "背景颜色"
        case .header(let h): return NSLocalizedString("H\(h)", comment: "")              // "H1", "H2", etc.
        case .indent: return NSLocalizedString("Indent", comment: "")                    // "增加缩进"
        case .outdent: return NSLocalizedString("Outdent", comment: "")                  // "减少缩进"
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")         // "有序列表"
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")     // "无序列表"
        case .alignLeft: return NSLocalizedString("Left", comment: "")                   // "左对齐"
        case .alignCenter: return NSLocalizedString("Center", comment: "")               // "居中"
        case .alignRight: return NSLocalizedString("Right", comment: "")                 // "右对齐"
        case .image: return NSLocalizedString("Image", comment: "")                      // "图片"
        case .link: return NSLocalizedString("Link", comment: "")                        // "链接"
        }
    }
    
    /// 操作
    // 实现协议的 action 方法：根据选项类型执行相应的编辑器操作
    public func action(_ toolbar: AITextToolbar) {
        // 根据当前选项类型执行相应的操作
        switch self {
        case .clear: toolbar.editor?.removeFormat()                                               // 清除格式
        case .undo: toolbar.editor?.undo()                                                        // 撤销
        case .redo: toolbar.editor?.redo()                                                        // 重做
        case .bold: toolbar.editor?.bold()                                                        // 设置粗体
        case .italic: toolbar.editor?.italic()                                                    // 设置斜体
        case .subscript: toolbar.editor?.subscriptText()                                          // 设置下标
        case .superscript: toolbar.editor?.superscript()                                          // 设置上标
        case .strike: toolbar.editor?.strikethrough()                                             // 设置删除线
        case .underline: toolbar.editor?.underline()                                              // 设置下划线
        case .textColor: toolbar.delegate?.aiTextToolbarChangeTextColor?(toolbar)             // 改变文字颜色（需要代理处理）
        case .textBackgroundColor: toolbar.delegate?.aiTextToolbarChangeBackgroundColor?(toolbar) // 改变背景颜色（需要代理处理）
        case .header(let h): toolbar.editor?.header(h)                                            // 设置标题级别
        case .indent: toolbar.editor?.indent()                                                    // 增加缩进
        case .outdent: toolbar.editor?.outdent()                                                  // 减少缩进
        case .orderedList: toolbar.editor?.orderedList()                                          // 创建有序列表
        case .unorderedList: toolbar.editor?.unorderedList()                                      // 创建无序列表
        case .alignLeft: toolbar.editor?.alignLeft()                                              // 左对齐
        case .alignCenter: toolbar.editor?.alignCenter()                                          // 居中对齐
        case .alignRight: toolbar.editor?.alignRight()                                            // 右对齐
        case .image: toolbar.delegate?.aiTextToolbarInsertImage?(toolbar)                     // 插入图片（需要代理处理）
        case .link: toolbar.delegate?.aiTextToolbarInsertLink?(toolbar)                       // 插入链接（需要代理处理）
        }
    }
}
