Copyright (c) 2015, Caesar Wirth
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

JavaScript事件触发
    ↓
RE.callback("methodName")  // 将方法名加入队列
    ↓
RE.runCallbackQueue()      // 检查队列
    ↓
window.location.href = "re-callback://"  // 触发URL跳转
    ↓
Swift WKNavigationDelegate 捕获URL
    ↓
runJS("RE.getCommandQueue()")  // 获取所有待执行命令
    ↓
JSON.parse(commands)           // 解析命令数组
    ↓
performCommand(method)         // 执行每个命令


加粗功能的数据流：
用户点击加粗按钮 → AITextToolbar 中的按钮被点击
调用 AITextOptionItem 的 action → 执行 toolbar.editor?.bold()
直接调用 AITextView.bold() 方法 → 执行 runJS("RE.setBold()")
JavaScript 执行 → RE.setBold() 调用 document.execCommand('bold', false, null)
触发 input 事件 → JavaScript 中的 input 事件监听器被触发
回调到 Swift → 通过 RE.callback("input") 回调到 Swift
经过 performCommand → 在 performCommand 方法中处理 input 命令


背景色功能的数据流：
用户点击背景色按钮 → 触发 aiTextToolbarChangeBackgroundColor 代理方法
生成随机颜色 → 调用 randomColor() 生成颜色
直接调用 setTextBackgroundColor → 执行 runJS("RE.setTextBackgroundColor('\(color.hex)')")
JavaScript 执行 → RE.setTextBackgroundColor() 调用 document.execCommand('hiliteColor', false, color)
触发 input 事件 → 同样会触发 input 事件
经过 performCommand → 在 performCommand 方法中处理 input 命令