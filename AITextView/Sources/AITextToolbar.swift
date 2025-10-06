//
//  AITextToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

// 导入 UIKit 框架，用于构建 iOS 用户界面
import UIKit

/// AITextToolbarDelegate是AITextToolbar的协议
/// 用于接收需要额外工作才能完成的操作（例如显示一些UI）
// 定义一个公开的协议 AITextToolbarDelegate，遵循 AnyObject 协议
@objc public protocol AITextToolbarDelegate: AnyObject {

    /// 当按下文本颜色工具栏项时调用
    // 当点击"改变文字颜色"按钮时调用
    @objc optional func aiTextToolbarChangeTextColor(_ toolbar: AITextToolbar)

    /// 当按下背景颜色工具栏项时调用
    // 当点击"改变背景颜色"按钮时调用
    @objc optional func aiTextToolbarChangeBackgroundColor(_ toolbar: AITextToolbar)

    /// 当按下插入图像工具栏项时调用
    // 当点击"插入图片"按钮时调用
    @objc optional func aiTextToolbarInsertImage(_ toolbar: AITextToolbar)

    /// 当按下插入链接工具栏项时调用
    // 当点击"插入链接"按钮时调用
    @objc optional func aiTextToolbarInsertLink(_ toolbar: AITextToolbar)
}

/// AITextBarButtonItem是UIBarButtonItem的子类，它接受回调而不是目标-动作模式
// 定义一个公开的类 AITextBarButtonItem，继承自 UIBarButtonItem
@objcMembers open class AITextBarButtonItem: UIBarButtonItem {
    /// 操作处理程序
    // 定义一个可选的闭包，用于处理按钮点击事件
    open var actionHandler: (() -> Void)?
    
    /// 使用图像初始化
    // 定义一个便利构造器，使用图片初始化
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        // 调用父类的构造器
        self.init(image: image, style: .plain, target: nil, action: nil)
        // 将 target 设置为自身
        target = self
        // 将 action 设置为 buttonWasTapped 方法
        action = #selector(AITextBarButtonItem.buttonWasTapped)
        // 设置 actionHandler
        actionHandler = handler
    }
    
    /// 使用标题初始化
    // 定义一个便利构造器，使用标题初始化
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        // 调用父类的构造器
        self.init(title: title, style: .plain, target: nil, action: nil)
        // 将 target 设置为自身
        target = self
        // 将 action 设置为 buttonWasTapped 方法
        action = #selector(AITextBarButtonItem.buttonWasTapped)
        // 设置 actionHandler
        actionHandler = handler
    }
    
    /// 按钮被点击时调用
    // 按钮被点击时调用的方法
    @objc func buttonWasTapped() {
        // 如果 actionHandler 存在，则执行它
        actionHandler?()
    }
}

/// AITextToolbar是包含可在AITextView上执行的操作的工具栏的UIView
// 定义一个公开的类 AITextToolbar，继承自 UIView
@objcMembers open class AITextToolbar: UIView {

    /// 接收无法自动完成的事件的委托
    // 定义一个弱引用的代理，用于处理需要特殊 UI 的操作
    open weak var delegate: AITextToolbarDelegate?

    /// 对应该执行操作的AITextView的引用
    // 定义一个弱引用的 editor，指向关联的 AITextView
    open weak var editor: AITextView?

    /// 要在工具栏上显示的选项列表
    // 定义一个数组，存储工具栏上要显示的选项
    open var options: [AITextOption] = [] {
        // 在属性值改变后执行
        didSet {
            // 更新工具栏的显示
            updateToolbar()
        }
    }

    /// 要应用于工具栏背景的色调颜色
    // 定义一个计算属性，用于设置或获取背景工具栏的 barTintColor
    open var barTintColor: UIColor? {
        // 获取值时，返回 backgroundToolbar 的 barTintColor
        get { return backgroundToolbar.barTintColor }
        // 设置值时，设置 backgroundToolbar 的 barTintColor
        set { backgroundToolbar.barTintColor = newValue }
    }

    /// 工具栏滚动视图
    // 定义一个私有的 UIScrollView，用于容纳工具栏，使其可以滚动
    private var toolbarScroll: UIScrollView
    /// 工具栏
    // 定义一个私有的 UIToolbar，用于显示按钮
    private var toolbar: UIToolbar
    /// 背景工具栏
    // 定义一个私有的 UIToolbar，用作背景，可以实现模糊效果等
    private var backgroundToolbar: UIToolbar
    
    /// 使用frame初始化
    // 覆盖 UIView 的 init(frame:) 方法
    public override init(frame: CGRect) {
        // 初始化各个视图组件
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        // 调用父类的初始化方法
        super.init(frame: frame)
        // 调用 setup 方法进行配置
        setup()
    }
    
    /// 从归档中初始化
    // 覆盖 UIView 的 init?(coder:) 方法，用于从 Storyboard 或 XIB 加载
    public required init?(coder aDecoder: NSCoder) {
        // 初始化各个视图组件
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        // 调用父类的初始化方法
        super.init(coder: aDecoder)
        // 调用 setup 方法进行配置
        setup()
    }
    
    /// 设置函数
    // 私有的 setup 方法，用于配置视图
    private func setup() {
        // 设置 autoresizingMask，使其宽度随父视图自动调整
        autoresizingMask = .flexibleWidth
        // 设置背景颜色为透明
        backgroundColor = .clear

        // 设置背景工具栏的 frame
        backgroundToolbar.frame = bounds
        // 设置背景工具栏的 autoresizingMask
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // 设置工具栏的 autoresizingMask
        toolbar.autoresizingMask = .flexibleWidth
        // 设置工具栏的背景颜色为透明
        toolbar.backgroundColor = .clear
        // 设置工具栏的背景图片为空，移除默认背景
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        // 再次设置，确保移除
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        // 移除工具栏的阴影线
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        // 设置滚动视图的 frame
        toolbarScroll.frame = bounds
        // 设置滚动视图的 autoresizingMask
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // 隐藏水平滚动指示器
        toolbarScroll.showsHorizontalScrollIndicator = false
        // 隐藏垂直滚动指示器
        toolbarScroll.showsVerticalScrollIndicator = false
        // 设置滚动视图的背景颜色为透明
        toolbarScroll.backgroundColor = .clear

        // 将工具栏添加到滚动视图中
        toolbarScroll.addSubview(toolbar)

        // 将背景工具栏和滚动视图添加到当前视图
        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        // 更新工具栏
        updateToolbar()
    }
    
    /// 更新工具栏
    // 私有方法，用于根据 options 数组更新工具栏的内容
    private func updateToolbar() {
        // 创建一个空的 UIBarButtonItem 数组
        var buttons = [UIBarButtonItem]()
        // 遍历 options 数组
        for option in options {
            // 创建一个闭包作为按钮的 action handler
            let handler = { [weak self] in
                // 使用 weak self 避免循环引用
                if let strongSelf = self {
                    // 调用 option 的 action
                    option.action(strongSelf)
                }
            }

            // 如果 option 有图片
            if let image = option.image {
                // 创建一个带图片的 AITextBarButtonItem
                let button = AITextBarButtonItem(image: image, handler: handler)
                // 添加到按钮数组
                buttons.append(button)
            } else {
                // 如果没有图片，使用标题
                let title = option.title
                // 创建一个带标题的 AITextBarButtonItem
                let button = AITextBarButtonItem(title: title, handler: handler)
                // 添加到按钮数组
                buttons.append(button)
            }
        }
        // 将创建好的按钮设置给工具栏
        toolbar.items = buttons

        // 定义默认图标宽度和按钮间距
        let defaultIconWidth: CGFloat = 28
        let barButtonItemMargin: CGFloat = 12
        // 使用 reduce 计算所有按钮的总宽度
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            // 通过 KVC 获取 UIBarButtonItem 对应的 view
            if let view = new.value(forKey: "view") as? UIView {
                // 如果能获取到 view，使用 view 的实际宽度
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                // 否则，使用默认宽度
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        // 如果总宽度小于视图宽度
        if width < frame.size.width {
            // 将工具栏宽度设置为视图宽度
            toolbar.frame.size.width = frame.size.width + barButtonItemMargin
        } else {
            // 否则，将工具栏宽度设置为计算出的总宽度
            toolbar.frame.size.width = width + barButtonItemMargin
        }
        // 设置工具栏高度为 44
        toolbar.frame.size.height = 44
        // 设置滚动视图的内容宽度
        toolbarScroll.contentSize.width = width
    }
    
}