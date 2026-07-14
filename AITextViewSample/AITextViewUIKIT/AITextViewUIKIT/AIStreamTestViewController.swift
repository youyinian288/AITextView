//
//  AIStreamTestViewController.swift
//  AITextViewUIKIT
//
//  Created by AI Assistant on 2025/01/27.
//  Copyright © 2025 Yitesi. All rights reserved.
//

import UIKit
import AIStreamingMarkdown
import SwiftOpenAI

class AIStreamTestViewController: UIViewController {
    
    // MARK: - UI Components
    
    private var contentView: UIView!
    private var inputTextView: UITextView!
    private var editorView: AIStreamingMarkdownView!
    private var sendButton: UIButton!
    private var stopButton: UIButton!
    private var clearButton: UIButton!
    private var mockAIButton: UIButton!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    private var autoScrollSwitch: UISwitch!
    private var autoScrollLabel: UILabel!
    
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
        
        // 创建输入文本框
        inputTextView = UITextView()
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 8.0
        inputTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        inputTextView.text = "8月份的AI新闻有哪些"
        view.addSubview(inputTextView)
        
        // 创建输出编辑器
        editorView = AIStreamingMarkdownView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        editorView.layer.borderColor = UIColor.systemGray4.cgColor
        editorView.layer.borderWidth = 1.0
        editorView.layer.cornerRadius = 8.0
        
        // 创建发送按钮
        sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("发送请求", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8.0
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        
        // 创建停止按钮
        stopButton = UIButton(type: .system)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.setTitle("停止生成", for: .normal)
        stopButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8.0
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        view.addSubview(stopButton)
        
        // 创建清除按钮
        clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("清除内容", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        clearButton.backgroundColor = .systemGray
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8.0
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        view.addSubview(clearButton)
        
        // 创建模拟AI按钮
        mockAIButton = UIButton(type: .system)
        mockAIButton.translatesAutoresizingMaskIntoConstraints = false
        mockAIButton.setTitle("模拟AI", for: .normal)
        mockAIButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        mockAIButton.backgroundColor = .systemGreen
        mockAIButton.setTitleColor(.white, for: .normal)
        mockAIButton.layer.cornerRadius = 8.0
        mockAIButton.addTarget(self, action: #selector(mockAIButtonTapped), for: .touchUpInside)
        view.addSubview(mockAIButton)
        
        // 创建状态标签
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        statusLabel.text = "准备就绪"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // 创建进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        view.addSubview(progressView)
        
        // 创建自动滚动标签
        autoScrollLabel = UILabel()
        autoScrollLabel.translatesAutoresizingMaskIntoConstraints = false
        autoScrollLabel.font = UIFont.systemFont(ofSize: 14)
        autoScrollLabel.textColor = .label
        autoScrollLabel.text = "自动滚动"
        view.addSubview(autoScrollLabel)
        
        // 创建自动滚动开关
        autoScrollSwitch = UISwitch()
        autoScrollSwitch.translatesAutoresizingMaskIntoConstraints = false
        autoScrollSwitch.isOn = true
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollSwitchChanged), for: .valueChanged)
        view.addSubview(autoScrollSwitch)
        
        // 创建内容容器视图
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true  // 确保内容不会超出边界
        view.addSubview(contentView)
        
        // 将编辑器添加到内容容器视图
        contentView.addSubview(editorView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // 输入文本框约束 - 固定在顶部
            inputTextView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // 按钮约束 - 固定在输入框下方
            sendButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
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
            
            mockAIButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            mockAIButton.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 8),
            mockAIButton.widthAnchor.constraint(equalToConstant: 100),
            mockAIButton.heightAnchor.constraint(equalToConstant: 44),
            
            // 状态标签约束 - 固定在按钮下方
            statusLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 进度条约束 - 固定在状态标签下方
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // 自动滚动标签约束
            autoScrollLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            autoScrollLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            autoScrollLabel.widthAnchor.constraint(equalToConstant: 80),
            autoScrollLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 自动滚动开关约束
            autoScrollSwitch.centerYAnchor.constraint(equalTo: autoScrollLabel.centerYAnchor),
            autoScrollSwitch.leadingAnchor.constraint(equalTo: autoScrollLabel.trailingAnchor, constant: 8),
            
            // 内容容器视图约束 - 约束到主视图
            contentView.topAnchor.constraint(equalTo: autoScrollLabel.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            
            // 编辑器约束 - 约束到内容容器视图
            editorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupInitialState() {
        updateUIState()
        
        // 设置初始内容 - 使用简单的 Markdown 测试
        let testMarkdown = #"""
<thinking>这是一段自定义解析处理的thinking组件</thinking>
>>>I'll create a simple Electron + Vue chat application demo. Here's the structure:


[Star on GitHub](https://github.com/Simon-He95/vue-markdown-render)


[【Author: Simon】](https://simonhe.me/)



![Vue Markdown Icon](/vue-markdown-icon.svg "Vue Markdown Icon")
*Figure: Vue Markdown Icon (served from /vue-markdown-icon.svg)*


这是 ~~已删除的文本~~，这是一个表情 :smile:。


- [ ] Star this repo
- [x] Fork this repo
- [ ] Create issues
- [x] Submit PRs


##  表格


| 姓名 | 年龄 | 职业 |
|------|------|------|
| 张三 | 25   | 工程师 |
| 李四 | 30   | 设计师 |
| 王五 | 28   | 产品经理 |


### 对齐表格
| 左对齐 | 居中对齐 | 右对齐 |
|:-------|:--------:|-------:|
| 内容1  |  内容2   |  内容3 |
| 内容4  |  内容5   |  内容6 |


我将为您输出泰勒公式的一般形式及其常见展开式。


---


## 1. 泰勒公式（Taylor's Formula）


### 一般形式（在点 \(x = a\) 处展开）：
\[
f(x) = f(a) + f'(a)(x-a) + \frac{f''(a)}{2!}(x-a)^2 + \frac{f'''(a)}{3!}(x-a)^3 + \cdots + \frac{f^{(n)}(a)}{n!}(x-a)^n + R_n(x)
\]


其中：
- \(f^{(k)}(a)\) 是 \(f(x)\) 在 \(x=a\) 处的 \(k\) 阶导数
- \(R_n(x)\) 是余项，常见形式有拉格朗日余项：
\[
R_n(x) = \frac{f^{(n+1)}(\xi)}{(n+1)!}(x-a)^{n+1}, \quad \xi \text{ 在 } a \text{ 和 } x \text{ 之间}
\]


---


## 2. 麦克劳林公式（Maclaurin's Formula，即 \(a=0\) 时的泰勒公式）：
\[
f(x) = f(0) + f'(0)x + \frac{f''(0)}{2!}x^2 + \frac{f'''(0)}{3!}x^3 + \cdots + \frac{f^{(n)}(0)}{n!}x^n + R_n(x)
\]


---


## 3. 常见函数的麦克劳林展开（前几项）


- **指数函数**：
\[
e^x = 1 + x + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots + \frac{x^n}{n!} + \cdots, \quad x \in \mathbb{R}
\]


- **正弦函数**：
\[
\sin x = x - \frac{x^3}{3!} + \frac{x^5}{5!} - \frac{x^7}{7!} + \cdots + (-1)^n \frac{x^{2n+1}}{(2n+1)!} + \cdots
\]


- **余弦函数**：
\[
\cos x = 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \frac{x^6}{6!} + \cdots + (-1)^n \frac{x^{2n}}{(2n)!} + \cdots
\]


- **自然对数**（在 \(x=0\) 附近）：
\[
\ln(1+x) = x - \frac{x^2}{2} + \frac{x^3}{3} - \frac{x^4}{4} + \cdots + (-1)^{n-1} \frac{x^n}{n} + \cdots, \quad -1 < x \le 1
\]


- **二项式展开**（\( (1+x)^m \)，\(m\) 为实数）：
\[
(1+x)^m = 1 + mx + \frac{m(m-1)}{2!}x^2 + \frac{m(m-1)(m-2)}{3!}x^3 + \cdots, \quad |x| < 1
\]


- **公式**



- **代入数据**
   \[
   \frac{363}{15,135} \times 100\% = 2.398\%
   \]


- **计算工具验证**
   通过数学计算工具确认结果：
   `363 ÷ 15,135 × 100 = 2.39841427...` 


- **差异说明**
   $$E=mc^2$$


---


如果您需要某个特定函数在特定点的泰勒展开，请告诉我，我可以为您详细写出。


::: warning
这是一个警告块。
:::


::: tip 提示标题
这是带标题的提示。
:::


::: error 错误块
这是一个错误块。
:::


مرحبا بكم في عالم اللغة العربية!
1. First, let's set up the project:


```shellscript
# Create Vue project
npm create vue@latest electron-vue-chat


# Navigate to project
cd electron-vue-chat


# Install dependencies
npm install
npm install electron electron-builder vue-router


# Install dev dependencies
npm install -D electron-dev-server concurrently wait-on
```


2. Create the main Electron file:


```javascript:electron/main.js
const { app, BrowserWindow } = require('electron');
const path = require('path');
const isDev = process.env.NODE_ENV === 'development';


let mainWindow;


function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 680,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });


  const url = isDev
    ? 'http://localhost:5173'
    : `file://${path.join(__dirname, '../dist/index.html')}`;


  mainWindow.loadURL(url);


  if (isDev) {
    mainWindow.webContents.openDevTools();
  }


  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}


app.on('ready', createWindow);


app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});


app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});
```


3. Update package.json:


```diff json:package.json
{
  "name": "vue-renderer-markdown",
  "type": "module",
- "version": "0.0.49",
+ "version": "0.0.54-beta.1",
  "packageManager": "pnpm@10.16.1",
  "description": "A Vue 3 component that renders Markdown string content as HTML, supporting custom components and advanced markdown features.",
  "author": "Simon He",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git + git@github.com:Simon-He95/vue-markdown-render.git"
  },
  "bugs": {
    "url": "https://github.com/Simon-He95/vue-markdown-render/issues"
  },
  "keywords": [
    "vue",
    "vue3",
    "markdown",
    "markdown-to-html",
    "markdown-renderer",
    "vue-markdown",
    "vue-component",
    "html",
    "renderer",
    "custom-component"
  ],
  "exports": {
    ".": {
      "types": "./dist/types/exports.d.ts",
      "import": "./dist/index.js",
      "require": "./dist/index.cjs"
    },
    "./index.css": "./dist/index.css",
    "./index.tailwind.css": "./dist/index.tailwind.css",
    "./tailwind": "./dist/tailwind.ts"
  },
  "main": "./dist/index.js",
  "module": "./dist/index.js",
  "types": "./dist/types/exports.d.ts",
  "files": [
    "dist"
  ],
}
```


4. Create chat components \(diversified languages\):


```python:src/server/app.py
from fastapi import FastAPI
from pydantic import BaseModel


app = FastAPI()


class Message(BaseModel):
    sender: str
    text: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/echo")
def echo(msg: Message):
    return {"reply": f"Echo: {msg.text}"}
```


5. Create a native module example \(C++\):


```cpp:src/native/compute.cpp
#include <bits/stdc++.h>
using namespace std;


int fibonacci(int n){
  if(n<=1) return n;
  int a=0,b=1;
  for(int i=2;i<=n;++i){ int c=a+b; a=b; b=c; }
  return b;
}


int main(){
  ios::sync_with_stdio(false);
  cin.tie(nullptr);
  cout << "fib(10)=" << fibonacci(10) << "\n";
  return 0;
}
```


6. Update the main App.vue:


```vue:src/App.vue
<template>
  <router-view />
</template>


<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}


body {
  font-family: Arial, sans-serif;
}
</style>
```


7. Set up the router:


```javascript:src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import ChatView from '../views/ChatView.vue';


const routes = [
  {
    path: '/',
    name: 'chat',
    component: ChatView
  }
];


const router = createRouter({
  history: createWebHistory(),
  routes
});


export default router;
```


8. Update main.js:


```javascript:src/main.js
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';


createApp(App).use(router).mount('#app');
```


9. Mermaid graphic:


```mermaid
graph TD
    Kira_Yamato[基拉·大和]
    Lacus_Clyne[拉克丝·克莱因]
    Athrun_Zala[阿斯兰·萨拉]
    Cagalli_Yula_Athha[卡嘉莉·尤拉·阿斯哈]
    Shinn_Asuka[真·飞鸟]
    Lunamaria_Hawke[露娜玛丽亚·霍克]
    COMPASS[世界和平监视组织COMPASS]
    Foundation[芬德申王国]
    Orphee_Lam_Tao[奥尔菲·拉姆·陶]
    %% 节点定义结束，开始定义边
    Kira_Yamato ---|恋人| Lacus_Clyne
    Kira_Yamato ---|挚友| Athrun_Zala
    Kira_Yamato -->|隶属| COMPASS
    Kira_Yamato -->|前辈| Shinn_Asuka
    Lacus_Clyne -->|初代总裁| COMPASS
    Athrun_Zala ---|恋人| Cagalli_Yula_Athha
    Athrun_Zala -.->|协力| COMPASS
    Shinn_Asuka ---|恋人| Lunamaria_Hawke
    Shinn_Asuka -->|隶属| COMPASS
    Lunamaria_Hawke -->|隶属| COMPASS
    COMPASS -->|对立| Foundation
    Orphee_Lam_Tao -->|隶属| Foundation
    Orphee_Lam_Tao -.->|追求| Lacus_Clyne
```


---
# 复杂数学公式


### 1. **理解 \(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 的含义**
   - \(\boldsymbol{\alpha}\) 和 \(\boldsymbol{\beta}\) 是三维列向量，因此 \(\boldsymbol{\alpha}^T \boldsymbol{\beta}\) 表示它们的点积（内积）。
   - \(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 意味着向量 \(\boldsymbol{\alpha}\) 和 \(\boldsymbol{\beta}\) 正交（即垂直），因为点积为零表示它们之间的夹角为 90 度。


### 2. **正交补空间的概念**
   - 在线性代数中，对于一个子空间 \(W\)，它的正交补空间（记为 \(W^\perp\)）定义为所有与 \(W\) 中每个向量正交的向量的集合。即：
     \[
     W^\perp = \{ \mathbf{v} \in \mathbb{R}^3 \mid \mathbf{v} \cdot \mathbf{w} = 0 \text{ 对于所有 } \mathbf{w} \in W \}
     \]
   - 例如，如果 \(W\) 是由一个向量 \(\boldsymbol{\alpha}\) 张成的一维子空间（即 \(W = \operatorname{span}\{\boldsymbol{\alpha}\}\)），那么 \(W^\perp\) 就是所有与 \(\boldsymbol{\alpha}\) 正交的向量构成的二维平面。


### 3. **\(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 与正交补空间的联系**
   - 当 \(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 时，这意味着：
     - \(\boldsymbol{\beta}\) 属于 \(\operatorname{span}\{\boldsymbol{\alpha}\}\) 的正交补空间，即 \(\boldsymbol{\beta} \in (\operatorname{span}\{\boldsymbol{\alpha}\})^\perp\)。
     - 同样，\(\boldsymbol{\alpha}\) 也属于 \(\operatorname{span}\{\boldsymbol{\beta}\}\) 的正交补空间，即 \(\boldsymbol{\alpha} \in (\operatorname{span}\{\boldsymbol{\beta}\})^\perp\)。
   - 换句话说，\(\boldsymbol{\beta}\) 与 \(\boldsymbol{\alpha}\) 张成的直线正交，因此 \(\boldsymbol{\beta}\) 位于该直线的垂直平面（即正交补空间）上。反之亦然。


### 4. **在三维空间中的几何意义**
   - 在三维空间中，如果 \(\boldsymbol{\alpha}\) 是一个非零向量，那么 \(\operatorname{span}\{\boldsymbol{\alpha}\}\) 是一条通过原点的直线，而它的正交补空间 \((\operatorname{span}\{\boldsymbol{\alpha}\})^\perp\) 是一个通过原点且与该直线垂直的平面。
   - \(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 表示 \(\boldsymbol{\beta}\) 位于这个垂直平面上。同样，如果 \(\boldsymbol{\beta}\) 非零，那么 \(\boldsymbol{\alpha}\) 也位于与 \(\boldsymbol{\beta}\) 垂直的平面上。


### 5. **推广到更一般的情况**
   - 如果考虑多个向量，正交补空间的概念可以扩展。例如，如果有一组向量 \(\{\boldsymbol{\alpha}_1, \boldsymbol{\alpha}_2, \ldots, \boldsymbol{\alpha}_k\}\)，那么它们的张成子空间 \(W = \operatorname{span}\{\boldsymbol{\alpha}_1, \ldots, \boldsymbol{\alpha}_k\}\) 的正交补空间 \(W^\perp\) 包含所有与这些向量正交的向量。
   - 在这种情况下，\(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 可以看作 \(\boldsymbol{\beta}\) 与 \(W\) 正交的一个特例（当 \(W\) 只由 \(\boldsymbol{\alpha}\) 张成时）。


总之，\(\boldsymbol{\alpha}^T \boldsymbol{\beta} = 0\) 直接体现了正交补空间的关系：它表明一个向量属于另一个向量张成子空间的正交补空间。如果你有更多向量或子空间，这种联系可以进一步深化。


**示例：** emm`1-(5)`、`3-(3)`、`3-(4)` complex test `1-(4)`“heiheihei”中，hello world。
"""#
        
        print("🎨 设置初始测试内容")
        editorView.setMarkdown(testMarkdown)
        print("✅ 初始内容设置完成")
    }
    
    // MARK: - Actions
    
    @objc private func sendButtonTapped() {
        print("🚀 发送按钮被点击")
        guard !isStreaming else { 
            print("⚠️ 正在流式输出中，忽略点击")
            return 
        }
        
        let prompt = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📝 用户输入: \(prompt)")
        guard !prompt.isEmpty else {
            print("❌ 输入为空")
            showAlert(title: "提示", message: "请输入问题内容")
            return
        }
        
        print("✅ 开始AI流式请求")
        startAIStream(prompt: prompt)
    }
    
    @objc private func stopButtonTapped() {
        stopAIStream()
    }
    
    @objc private func clearButtonTapped() {
        clearContent()
    }
    
    @objc private func mockAIButtonTapped() {
        print("🤖 模拟AI按钮被点击")
        guard !isStreaming else { 
            print("⚠️ 正在流式输出中，忽略点击")
            return 
        }
        
        print("✅ 开始模拟AI流式输出")
        startMockAIStream()
    }
    
    @objc private func autoScrollSwitchChanged() {
        editorView.isAutoScrollEnabled = autoScrollSwitch.isOn
        updateStatus(autoScrollSwitch.isOn ? "自动滚动已启用" : "自动滚动已禁用")
    }
    
    // MARK: - AI Stream Methods
    
    private func startAIStream(prompt: String) {
        print("🔄 开始AI流式处理")
        isStreaming = true
        message = ""
        errorMessage = ""
        
        updateUIState()
        updateStatus("正在连接AI服务...")
        print("📡 状态更新: 正在连接AI服务...")
        
        // 使用硬编码的API密钥
        let apiKey = "sk-0afb28dff5ff4381b57f804caf79dd1d"
        let service = OpenAIServiceFactory.service(
            apiKey: apiKey,
            overrideBaseURL: "https://api.deepseek.com"
        )
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .text("请用Markdown格式富文本返回内容问题答案：" + prompt))],
            model: .custom("deepseek-chat")
        )
        
        print("🌐 创建AI服务，API Key: \(String(apiKey.prefix(10)))...")
        print("📋 请求参数: \(parameters)")
        
        currentStreamTask = Task {
            do {
                updateStatus("开始流式输出...")
                print("📤 开始流式输出...")
                progressView.isHidden = false
                progressView.progress = 0.0
                
                let stream = try await service.startStreamedChat(parameters: parameters)
                print("✅ 流式连接建立成功")
                var progress: Float = 0.0
                
                for try await result in stream {
                    await MainActor.run {
                        let content = result.choices?.first?.delta?.content ?? ""
                        print("📨 收到内容片段: '\(content)'")
                        
                        // 直接使用流式输出更新，只发送新增的内容
                        if !content.isEmpty {
                            self.editorView.append(content)
                        }
                        
                        self.message += content
                        
                        // 更新进度
                        progress += 0.1
                        self.progressView.progress = min(progress, 0.9)
                    }
                }
                
                await MainActor.run {
                    print("✅ 流式输出完成，总消息长度: \(self.message.count)")

                    // 通知 JS 端流式输出已完成，触发 streamComplete 回调
                    self.editorView.finish()
                    
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
                    print("❌ API错误: \(statusCode) - \(description)")
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
                    print("❌ 未知错误: \(error.localizedDescription)")
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
            let stopMessage = "\n\n[生成已停止]"
            message += stopMessage
            editorView.append(stopMessage)
        }
    }
    
    private func updateOutputDisplay() {
        print("🎨 更新输出显示")
        
        if !message.isEmpty {
            print("📝 有消息内容，长度: \(message.count)")
            // 使用非流式方式一次性设置当前消息内容
            editorView.setMarkdown(message)
        } else if !errorMessage.isEmpty {
            print("❌ 有错误信息: \(errorMessage)")
            let errorMarkdown = """
            ### ❌ 错误信息
            
            > \(errorMessage)
            """
            editorView.setMarkdown(errorMarkdown)
        } else {
            print("📝 使用默认内容")
            let defaultMarkdown = """
            **Base64图片优势：**
            
            - ✅ 无需网络连接，离线可用
            - ✅ 图片数据直接嵌入Markdown，便于分享
            - ✅ 支持SVG矢量图形，缩放不失真
            - ✅ 适合小图标、简单图形等场景
            
            ---
            
            🚀 **开始测试 AITextView 的强大功能吧！**
            """
            // 使用非流式方式一次性设置当前消息内容
            editorView.setMarkdown(defaultMarkdown)
        }
        
        print("✅ 流式输出更新完成")
    }
    
    private func clearContent() {
        message = ""
        errorMessage = ""
        editorView.reset()
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
        
        mockAIButton.isEnabled = !isStreaming
        mockAIButton.alpha = isStreaming ? 0.6 : 1.0
        
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
    
    // MARK: - Mock AI Stream Methods
    
    private func startMockAIStream() {
        print("🤖 开始模拟AI流式处理")
        isStreaming = true
        message = ""
        errorMessage = ""
        
        updateUIState()
        updateStatus("正在模拟AI生成...")
        progressView.isHidden = false
        progressView.progress = 0.0
        
        // 获取预设的markdown内容
        let mockContent = getMockMarkdownContent()
        
        // 创建模拟流式输出任务
        currentStreamTask = Task {
            await simulateAIStream(content: mockContent)
        }
    }
    
    private func getMockMarkdownContent() -> String {
        // 返回预设的markdown内容用于测试
        return """
        # 🤖 模拟AI流式输出测试
        
        ## 📝 文本格式测试
        
        **粗体文本 Bold Text** | *斜体文本 Italic Text* | ~~删除线文本 Strikethrough Text~~
        
        ***粗体斜体 Bold Italic*** | **_粗体下划线 Bold Underlined_**
        
        上标: H~2~O | 下标: x^2^ + y^2^ = z^2^
        
        ## 📋 标题级别测试
        
        # 一级标题 H1
        ## 二级标题 H2
        ### 三级标题 H3
        #### 四级标题 H4
        ##### 五级标题 H5
        ###### 六级标题 H6

        ## 📝 列表测试

        ### 有序列表 Ordered List:
        
        1. 第一项 First Item
        2. 第二项 Second Item
        3. 第三项 Third Item
           1. 嵌套项 1 Nested Item 1
           2. 嵌套项 2 Nested Item 2

        ### 无序列表 Unordered List:
        
        - 项目 A Item A
        - 项目 B Item B
        - 项目 C Item C
          - 子项目 1 Sub Item 1
          - 子项目 2 Sub Item 2

        ## 🔗 链接测试
        
        访问 [AITextView GitHub 仓库](https://github.com/youyinian288/AITextView)
        
        查看 [Apple 官网](https://www.apple.com) 了解更多信息
        
        这是一个 [邮箱链接](mailto:test@example.com) 和 [电话链接](tel:+1234567890)
        
        ## 🖼️ 图片测试
        
        网络图片示例：
        ![随机网络图片](https://picsum.photos/200/150?random=1)
        
        Base64 图片示例（小图标）：
        ![Base64 SVG 图片](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iIzQyODVmNCIvPgogIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ3aGl0ZSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE4Ij5CYXNlNjQgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==)
        
        ## 💬 引用测试
        
        > "这是一个引用块，用于突出显示重要内容或引用他人的话语。"
        > 
        > — 作者名称
        
        ## 📊 表格测试
        
        | 功能 Feature | 支持 Support | 说明 Description |
        |-------------|-------------|------------------|
        | 粗体 Bold | ✅ | 支持粗体文本格式 |
        | 斜体 Italic | ✅ | 支持斜体文本格式 |
        | 列表 Lists | ✅ | 支持有序和无序列表 |
        | 链接 Links | ✅ | 支持各种链接格式 |
        | 图片 Images | ✅ | 支持网络和Base64图片 |
        
        ## 🔧 代码测试
        
        内联代码: `console.log("Hello World")`
        
        代码块示例：
        ```swift
        func fibonacci(_ n: Int) -> Int {
            if n <= 1 { return n }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }
        ```
        
        ```javascript
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        ```
        
        ## 🎯 特殊字符和符号
        
        数学符号: ∑ ∫ ∏ ∆ ∇ ∞ ≤ ≥ ≠ ≈ ± × ÷
        
        箭头符号: ← → ↑ ↓ ↔ ↕ ⇐ ⇒ ⇑ ⇓
        
        货币符号: $ € £ ¥ ₹ ₽
        
        其他符号: © ® ™ § ¶ † ‡ • ◦ ◊
        
        ## 📝 段落和换行测试
        
        这是第一个段落。包含多行文本，用于测试段落的显示效果。AITextView 应该能够正确处理段落间距和换行。
        
        这是第二个段落。用于测试多个段落之间的间距和格式。每个段落都应该有适当的间距。
        
        这是第三个段落。  
        这里有一个手动换行。  
        用于测试 Markdown 换行的效果。
        
        ## 🎨 混合格式测试
        
        ***粗体斜体 Bold Italic*** | ~~*删除线斜体 Strikethrough Italic*~~
        
        ## 🎉 测试完成
        
        这个模拟AI输出包含了 AITextView 支持的大部分功能。通过流式输出，您可以测试：
        
        - ✅ 文本格式（粗体、斜体、删除线）
        - ✅ 标题级别
        - ✅ 列表和缩进
        - ✅ 链接插入
        - ✅ 图片插入（网络图片、Base64图片）
        - ✅ 引用块
        - ✅ 表格
        - ✅ 代码块
        - ✅ 自动滚动功能
        
        ---
        
        🚀 **模拟AI流式输出测试完成！**
        
        💡 **提示**: 您可以调整自动滚动开关来测试滚动行为，使用"停止生成"按钮来中断流式输出。
        
        """
    }
    
    private func simulateAIStream(content: String) async {
        print("🔄 开始模拟流式输出")
        
        // 将内容分割成小块进行流式输出
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        let chunkSize = 3 // 每次输出3个词
        var currentIndex = 0
        var progress: Float = 0.0
        
        while currentIndex < words.count && !Task.isCancelled {
            await MainActor.run {
                // 获取当前块的内容
                let endIndex = min(currentIndex + chunkSize, words.count)
                let chunk = words[currentIndex..<endIndex].joined(separator: " ")
                
                // 添加适当的空格和换行
                let contentToAdd = currentIndex == 0 ? chunk : " " + chunk
                
                print("📨 模拟输出内容片段: '\(contentToAdd)'")
                
                // 使用流式输出更新
                if !contentToAdd.isEmpty {
                    self.editorView.append(contentToAdd)
                }
                
                self.message += contentToAdd
                
                // 更新进度
                progress = Float(currentIndex) / Float(words.count)
                self.progressView.progress = progress
                
                // 更新状态
                let percentage = Int(progress * 100)
                self.updateStatus("模拟AI生成中... \(percentage)%")
            }
            
            // 模拟网络延迟
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒延迟
            
            currentIndex += chunkSize
        }
        
        await MainActor.run {
            print("✅ 模拟流式输出完成，总消息长度: \(self.message.count)")
            
            // 标记流式输出完成
            self.editorView.finish()
            
            self.progressView.progress = 1.0
            self.updateStatus("模拟AI生成完成")
            self.isStreaming = false
            self.currentStreamTask = nil
            self.updateUIState()
            
            // 延迟隐藏进度条
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.progressView.isHidden = true
            }
        }
    }
}

