//
//  UIColor+Extensions.swift
//  Pods
//
//  Created by Caesar Wirth on 10/9/16.
//
//

// 导入 Foundation 框架，提供基础类型和功能
import Foundation
// 导入 UIKit 框架，提供 UIColor 类型
import UIKit

/// UIColor扩展
// 定义一个内部的 UIColor 扩展，为 UIColor 类型添加额外功能
internal extension UIColor {

    /// UIColor的十六进制表示
    /// 例如，UIColor.blackColor()变成"#000000"
    // 定义一个计算属性，将 UIColor 转换为十六进制字符串，用于在 JavaScript 中使用
    var hex: String {
        // 定义变量来存储红、绿、蓝色值
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        // 从 UIColor 中提取 RGB 色值（0.0-1.0 范围）
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        // 将 0.0-1.0 范围的色值转换为 0-255 范围的整数
        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        // 使用格式化字符串将 RGB 值转换为十六进制格式（如 #FF0000）
        // %02x 表示以两位十六进制格式显示，不足两位前面补0
        let str = String(format: "#%02x%02x%02x", r, g, b)
        // 返回十六进制颜色字符串
        return str
    }

}