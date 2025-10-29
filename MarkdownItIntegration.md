# Markdown-it 集成说明

## 概述

本项目已成功将手写的 `SimpleMarkdownParser` 替换为基于 `markdown-it` 的 `MarkdownItParser`，提供了更强大和标准的 Markdown 解析能力。

## 主要改进

### 1. 使用 markdown-it 作为核心解析器
- 替换了手写的正则表达式解析器
- 提供更准确和完整的 Markdown 标准支持
- 更好的错误处理和边界情况处理

### 2. 插件支持
集成了以下 markdown-it 插件：
- **表格支持**: `markdown-it-table`
- **表情符号**: `markdown-it-emoji`
- **代码复制**: `markdownItCodeCopy`
- **数学公式**: `markdown-it-katex` (KaTeX)

### 3. 回退机制
- 如果 markdown-it 库未加载，自动回退到原有的 `SimpleMarkdownParser`
- 确保向后兼容性和稳定性

## 文件结构

```
AITextView/Sources/Resources/
├── stream_markdown_editor.js    # 主要文件，包含新的 MarkdownItParser
└── test_markdown_it.html        # 测试文件，用于验证解析器功能
```

## 核心类

### MarkdownItParser
```javascript
class MarkdownItParser {
  constructor(options = {})
  parse(markdown) // 返回 AST
  setupPlugins() // 配置插件
  tokensToAST(tokens) // 转换 tokens 为 AST
}
```

### 支持的节点类型
- `heading` - 标题 (h1-h6)
- `paragraph` - 段落
- `code_block` - 代码块
- `code` - 内联代码
- `list` - 列表 (有序/无序)
- `list_item` - 列表项
- `blockquote` - 引用
- `table` - 表格
- `link` - 链接
- `image` - 图片
- `strong` - 粗体
- `emphasis` - 斜体
- `strikethrough` - 删除线
- `horizontal_rule` - 水平线

## 使用方法

### 1. 在 HTML 中加载 markdown-it 库
```html
<script src="https://cdn.jsdelivr.net/npm/markdown-it@14.0.0/dist/markdown-it.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/markdown-it-table@4.0.0/dist/markdown-it-table.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/markdown-it-emoji@2.0.2/dist/markdown-it-emoji.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/markdown-it-katex@2.0.3/dist/markdown-it-katex.min.js"></script>
```

### 2. 自动初始化
解析器会在页面加载时自动初始化，优先使用 markdown-it，如果不可用则回退到简单解析器。

### 3. 测试
打开 `test_markdown_it.html` 文件可以在浏览器中测试解析器功能。

## 配置选项

### MarkdownItParser 选项
```javascript
const parser = new MarkdownItParser({
  html: true,        // 允许 HTML 标签
  linkify: true,     // 自动转换 URL 为链接
  typographer: true, // 启用排版替换
  breaks: false      // 不将换行符转换为 <br>
})
```

## 性能优化

1. **按需加载**: 只有在 markdown-it 可用时才使用
2. **插件检测**: 自动检测可用的插件，避免错误
3. **错误处理**: 完善的错误处理和回退机制
4. **内存管理**: 避免内存泄漏，及时清理资源

## 兼容性

- 与现有的 `PureJSMarkdownRenderer` 完全兼容
- 保持相同的 AST 格式
- 支持所有现有的组件类型
- 向后兼容原有的 API

## 测试

运行测试文件验证功能：
```bash
# 在浏览器中打开
open test_markdown_it.html
```

测试内容包括：
- 基本 Markdown 语法
- 表格渲染
- 代码块高亮
- 数学公式
- 链接和图片
- 列表和引用

## 故障排除

### 1. markdown-it 未加载
- 检查 CDN 链接是否可访问
- 确认网络连接正常
- 系统会自动回退到简单解析器

### 2. 插件错误
- 插件加载失败不会影响基本功能
- 检查插件版本兼容性
- 查看浏览器控制台错误信息

### 3. 解析错误
- 检查 Markdown 语法是否正确
- 查看控制台错误信息
- 尝试使用简单解析器进行对比

## 未来扩展

1. **更多插件支持**: 可以轻松添加更多 markdown-it 插件
2. **自定义渲染规则**: 可以自定义特定节点的渲染方式
3. **性能监控**: 可以添加解析性能监控
4. **缓存机制**: 可以添加解析结果缓存

## 总结

通过集成 markdown-it，我们获得了：
- ✅ 更准确的 Markdown 解析
- ✅ 标准化的插件生态
- ✅ 更好的错误处理
- ✅ 向后兼容性
- ✅ 易于扩展和维护

这个改进大大提升了 Markdown 解析的可靠性和功能完整性，同时保持了与现有代码的完全兼容。
