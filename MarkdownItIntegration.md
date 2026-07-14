# AITextView


## 项目简介

AITextView 是一个为 iOS 设计的高性能 Markdown 流式渲染组件，适用于 AI 生成内容实时可视化展示。项目采用 Swift + WebKit 融合架构，集成开源 markdown-it 解析引擎，主打流畅的“流式输出”与高度可定制化的富文本渲染体验。

- 开源地址：[https://github.com/youyinian288/AITextView](https://github.com/youyinian288/AITextView)

## 主要功能

- 🚀 **流式渲染**：支持 AI 内容的实时片段化/流式 Markdown 渲染
- 🎨 **Markdown 实时预览**：完整支持表格、数学公式、代码高亮、emoji、图像等丰富格式
- 🧩 **混合架构**：Swift 管理内容，Web 前端负责高性能渲染，组件化 AST 节点构建
- 🔄 **低延迟体验**：适用于对实时反馈友好的富文本场景，自动滚动、无闪烁
- ⚡ **易于扩展**：支持自定义样式、主题切换与二次开发
- 📦 **开箱即用**：简洁 API，快速集成

## 架构概览
Swift (AITextView) --内容和流控--> WKWebView --JS Bridge--> markdown-it 引擎 --HTML/CSS--> UI 渲染