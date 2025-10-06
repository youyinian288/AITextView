//
//  String+Extensions.swift
//  Pods
//
//  Created by Caesar Wirth on 10/9/16.
//
//

// 导入 Foundation 框架，提供基础类型和功能
import Foundation

/// 字符串扩展
// 定义一个内部的 String 扩展，为 String 类型添加额外功能
internal extension String {

    /// 带有转义字符'的字符串
    /// 用于将字符串传递到JavaScript时，避免字符串过早结束
    // 定义一个计算属性，返回转义后的字符串，用于安全地传递给 JavaScript
    var escaped: String {
        // 获取字符串的 Unicode 标量集合
        let unicode = self.unicodeScalars
        // 创建一个空字符串用于存储转义后的结果
        var newString = ""
        // 遍历每个 Unicode 字符
        for char in unicode {
            // 检查是否需要转义的字符
            if char.value == 39 || // 39 == ' (单引号) in ASCII
                char.value < 9 ||  // 9 == horizontal tab (水平制表符) in ASCII - 小于此值的都是控制字符
                (char.value > 9 && char.value < 32) // < 32 == special characters (特殊字符) in ASCII
            {
                // 如果需要转义，将字符转义为 ASCII 格式
                let escaped = char.escaped(asASCII: true)
                // 将转义后的字符添加到结果字符串
                newString.append(escaped)
            } else {
                // 如果不需要转义，直接将字符转换为字符串并添加
                newString.append(String(char))
            }
        }
        // 返回转义后的字符串
        return newString
    }

}