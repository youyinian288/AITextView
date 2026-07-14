"use strict";

// ==================== 原有代码 ====================

// 全局调试信息
if (typeof window !== 'undefined') {
    window.jsLoaded = true;
    // 立即发送调试信息
    if (typeof window.RE === 'undefined') {
        window.RE = {};
    }
    window.RE.callbackQueue = [];
    window.RE.runCallbackQueue = function() {
        if (window.RE.callbackQueue.length === 0) {
            return;
        }
        setTimeout(function() {
            window.location.href = "ai-callback://";
        }, 0);
    };
    window.RE.callback = function(method) {
        if (!window.RE.callbackQueue) {
            window.RE.callbackQueue = [];
        }
        window.RE.callbackQueue.push(method);
        window.RE.runCallbackQueue();
    };
    
    // 发送 JavaScript 加载成功的调试信息
    window.RE.callback('debug/JavaScript文件加载成功');
}

// 全局 RE 对象，完全模仿 RichEditorView
const RE = window.RE || {};

// 待处理的Markdown内容
RE.pendingMarkdownContent = null;

RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

RE.callback = function(method) {
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

// 获取编辑器元素
RE.editor = document.getElementById('editor');
RE.callback('debug/RE.editor获取结果:' + (RE.editor ? '成功' : '失败'));

// 流式 Markdown 处理器
RE.streamMarkdownProcessor = {
    parser: null,            // Markdown 解析器实例（优先 MarkdownItParser，失败时可回退到简单解析器）
    renderer: null,          // AST → DOM 渲染器实例（PureJSMarkdownRenderer）
    currentContent: '',      // 当前累积的 Markdown 文本（包含已接收的所有流式内容）
    isStreaming: false,      // 是否处于流式更新过程中（收到增量内容但尚未结束）
    useMarkdownIt: false,    // 是否成功启用 markdown-it 作为解析器
    renderScheduled: false,  // 是否已经安排了一次渲染任务（用于防抖，避免重复 scheduleRender）
    pendingComplete: false,  // 是否在本次渲染完成后需要触发 streamComplete 回调
    
    init() {
        try {
            RE.callback('debug/初始化Markdown渲染器');
            
            // 初始化 markdown-it 解析器（默认可用）
            try {
                this.parser = new MarkdownItParser({
                    html: true,
                    linkify: true,
                    typographer: true,
                    breaks: false
                });
                this.useMarkdownIt = true;
                RE.callback('debug/使用 markdown-it 解析器');
                console.log('✅ 使用 markdown-it 解析器');
            } catch (markdownItError) {
                this.useMarkdownIt = false;
                throw markdownItError;
            }
            
            // 初始化渲染器
            this.renderer = new PureJSMarkdownRenderer({
                onLinkClick: (e, url) => {
                    RE.callback('debug/链接点击: ' + url);
                },
                onImageClick: (src) => {
                    RE.callback('debug/图片点击: ' + src);
                }
            });
            
            RE.callback('debug/Markdown渲染器初始化完成，使用解析器: markdown-it');
            console.log('✅ Markdown渲染器初始化完成');
        } catch (error) {
            RE.callback('debug/渲染器初始化错误: ' + error.message);
            console.error('❌ Markdown渲染器初始化失败:', error);
        }
    },
    
    updateMarkdown(newContent, isComplete) {        RE.callback('debug/updateMarkdown被调用:长度=' + newContent.length + ',完成=' + isComplete);
        RE.callback('debug/更新Markdown:长度=' + newContent.length + ',完成=' + isComplete + ',编辑器=' + (!!RE.editor) + ',parser=' + (!!this.parser) + ',renderer=' + (!!this.renderer));
        
        if (!RE.editor) {
            RE.callback('debug/错误:RE.editor不存在，无法更新Markdown');
            return;
        }
        
        if (!this.parser || !this.renderer) {
            RE.callback('debug/错误:解析器或渲染器不存在，存储待处理内容');
            // 如果解析器或渲染器不存在，存储待处理的内容
            if (isComplete) {
                RE.pendingMarkdownContent = newContent;
                RE.callback('debug/已存储待处理内容，长度: ' + newContent.length);
            } else {
                // 对于流式内容，累积到待处理内容中
                RE.pendingMarkdownContent = (RE.pendingMarkdownContent || '') + newContent;
                RE.callback('debug/已累积待处理内容，总长度: ' + (RE.pendingMarkdownContent ? RE.pendingMarkdownContent.length : 0));
            }
            return;
        }
        
        if (isComplete) {
            this.currentContent = newContent;
        } else {
            this.currentContent += newContent;
        }
        this.isStreaming = !isComplete;

        this.scheduleRender(isComplete);
    },

    scheduleRender(isComplete) {
        if (isComplete) {
            this.pendingComplete = true;
        }

        if (this.renderScheduled) {
            return;
        }
        this.renderScheduled = true;

        const doRender = () => {
            this.renderScheduled = false;

            try {
                const ast = this.parser.parse(this.currentContent);
                const nodeCount = Array.isArray(ast) ? ast.length : (ast ? 1 : 0);
                RE.callback('debug/Markdown解析为AST完成:节点数=' + nodeCount + ',内容长度=' + this.currentContent.length);

                this.renderer.renderAST(ast, RE.editor);
                RE.callback('debug/AST渲染到DOM完成');

                this.addCodeCopyListeners();

                setTimeout(() => {
                    RE.scrollToBottom();
                }, 50);

                if (this.pendingComplete) {
                    RE.callback('streamComplete');
                    this.pendingComplete = false;
                }

                RE.callback('contentUpdate');
            } catch (error) {
                RE.callback('debug/Markdown处理错误: ' + error.message);
                console.error('❌ Markdown处理失败:', error);
            }
        };

        if (typeof window !== 'undefined' && typeof window.requestAnimationFrame === 'function') {
            window.requestAnimationFrame(doRender);
        } else {
            setTimeout(doRender, 16);
        }
    },
    
    reset() {
        console.log('🔄 重置流式处理器');
        this.currentContent = '';
        this.isStreaming = false;
        
        // 重置渲染器的增量渲染状态
        if (this.renderer) {
            this.renderer.lastRenderedAST = null;
            this.renderer.astToDOM.clear();
        }
        
        if (RE.editor) {
            RE.editor.innerHTML = '';
        }
        RE.callback('contentReset');
    },
    
    addCodeCopyListeners() {
        // 为所有代码块添加复制按钮事件监听
        const copyButtons = RE.editor.querySelectorAll('.code-block-copy');
        copyButtons.forEach(button => {
            if (!button.hasAttribute('data-listener-added')) {
                button.addEventListener('click', function() {
                    const codeBlock = this.parentElement.querySelector('code');
                    if (codeBlock) {
                        navigator.clipboard.writeText(codeBlock.textContent).then(() => {
                            console.log('代码已复制到剪贴板');
                        }).catch(() => {
                            console.error('复制失败');
                        });
                    }
                });
                button.setAttribute('data-listener-added', 'true');
            }
        });
    }
};

RE.setMarkdown = function(content) {
    RE.streamMarkdownProcessor.reset();
    RE.streamMarkdownProcessor.updateMarkdown(content, true);
};

RE.getMarkdown = function() {
    return RE.streamMarkdownProcessor.currentContent;
};



RE.clear = function() {
    RE.streamMarkdownProcessor.reset();
};

// 滚动控制方法
RE.scrollToBottom = function() {
    RE.callback('debug/开始滚动到底部');
    
    // 在WebView环境中，我们需要滚动整个页面
    // 使用多种方法确保滚动成功
    try {
        // 方法1: 滚动到页面底部
        window.scrollTo({
            top: document.body.scrollHeight,
            behavior: 'smooth'
        });
        
        // 方法2: 使用document.documentElement
        document.documentElement.scrollTop = document.documentElement.scrollHeight;
        
        // 方法3: 滚动到编辑器底部
        if (RE.editor) {
            RE.editor.scrollIntoView({ 
                behavior: 'smooth', 
                block: 'end' 
            });
        }
        
        RE.callback('debug/滚动到底部完成');
    } catch (error) {
        RE.callback('debug/滚动失败: ' + error.message);
        console.error('❌ 滚动失败:', error);
    }
};

RE.scrollToTop = function() {
    const scrollContainer = RE.editor.parentElement;
    if (scrollContainer) {
        scrollContainer.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    } else {
        RE.editor.scrollTop = 0;
    }
};

// 高度管理
RE.updateHeight = function() {
    const height = RE.editor.clientHeight;
    RE.callback('heightChange/' + height);
};

RE.getHeight = function() {
    return RE.editor.clientHeight;
};

// 焦点管理
RE.focus = function() {
    RE.editor.focus();
    RE.callback('focus');
};

RE.blur = function() {
    RE.editor.blur();
    RE.callback('blur');
};

// 主题切换支持
RE.setTheme = function(theme) {
    document.body.className = theme;
    RE.callback('themeChange/' + theme);
};

// 初始化方法
RE.init = function() {
    RE.callback('debug/RE对象初始化开始');
    RE.callback('debug/RE.editor在初始化时:' + (RE.editor ? '存在' : '不存在'));
    
    if (!RE.editor) {
        RE.callback('debug/错误:RE.editor为空，无法初始化');
        return;
    }
    
    // 检查markdown-it是否可用（可选）
    if (typeof window.markdownit === 'undefined') {
        RE.callback('debug/警告:markdown-it库未加载，将使用简单解析器');
    }
    
    try {
        // 初始化流式 Markdown 处理器
        RE.streamMarkdownProcessor.init();
        
        // 监听窗口大小变化
        window.addEventListener('resize', function() {
            RE.updateHeight();
        });
        
        // 监听内容变化
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList' || mutation.type === 'characterData') {
                    RE.updateHeight();
                }
            });
        });
        
        observer.observe(RE.editor, {
            childList: true,
            subtree: true,
            characterData: true
        });
        
        RE.callback('debug/RE对象初始化完成');
        
        // 初始化完成后，处理任何待处理的Markdown内容
        if (RE.pendingMarkdownContent) {
            RE.callback('debug/处理待处理的Markdown内容，长度: ' + RE.pendingMarkdownContent.length);
            RE.streamMarkdownProcessor.updateMarkdown(RE.pendingMarkdownContent, true);
            RE.pendingMarkdownContent = null;
        }
    } catch (error) {
        RE.callback('debug/RE初始化错误: ' + error.message);
        console.error('❌ RE初始化失败:', error);
    }
};

// 等待所有依赖加载完成
let dependencyCheckCount = 0;
const maxDependencyChecks = 50; // 最多检查50次，避免无限循环

function waitForDependencies() {
    dependencyCheckCount++;
    
    // 详细检查每个依赖的加载状态
    const dependencies = {
        markdownit: typeof window.markdownit !== 'undefined',
        markdownItEmoji: typeof window.markdownItEmoji !== 'undefined',
        markdownItCodeCopy: typeof window.markdownItCodeCopy !== 'undefined',
        markdownItKatex: typeof window.markdownItKatex !== 'undefined',
        markdownItTable: typeof window.markdownItTable !== 'undefined'
    };
    
    RE.callback('debug/依赖检查(' + dependencyCheckCount + '/' + maxDependencyChecks + '): markdownit=' + dependencies.markdownit + 
                ', emoji=' + dependencies.markdownItEmoji + 
                ', codeCopy=' + dependencies.markdownItCodeCopy + 
                ', katex=' + dependencies.markdownItKatex + 
                ', table=' + dependencies.markdownItTable);
    
    // 如果检查次数超过限制，强制初始化（使用简单解析器）
    if (dependencyCheckCount >= maxDependencyChecks) {
        RE.callback('debug/依赖检查超时，强制初始化（将使用简单解析器）');
        RE.init();
        return;
    }
    
    // 检查核心依赖markdown-it是否已加载
    if (!dependencies.markdownit) {
        // 如果核心依赖未加载，等待100ms后重试
        setTimeout(waitForDependencies, 100);
        return;
    }
    
    // markdown-it已加载，即使插件没有加载也继续初始化
    RE.callback('debug/markdown-it核心库已加载，开始初始化（插件可选）');
    RE.init();
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 延迟初始化，确保 DOM 完全加载
    setTimeout(waitForDependencies, 100);
});

// 如果 DOM 已经加载完成，立即初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        setTimeout(waitForDependencies, 100);
    });
} else {
    setTimeout(waitForDependencies, 100);
}

// 窗口完全加载后发送 ready 信号（完全模仿 RichEditorView）
window.onload = function() {
    RE.callback("ready");
};

// 全局函数，用于代码复制
function copyCode(button) {
    const codeBlock = button.parentElement.querySelector('code');
    if (codeBlock) {
        navigator.clipboard.writeText(codeBlock.textContent).then(() => {
            showCopySuccess(button);
        }).catch(() => {
            fallbackCopyTextToClipboard(codeBlock.textContent);
            showCopySuccess(button);
        });
    }
}

function fallbackCopyTextToClipboard(text, button) {
    const textArea = document.createElement("textarea");
    textArea.value = text;
    textArea.style.position = "fixed";
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
        const successful = document.execCommand('copy');
        if (successful) {
            showCopySuccess(button);
        } else {
            showCopyError(button);
        }
    } catch (err) {
        showCopyError(button);
    }
    
    document.body.removeChild(textArea);
}

function showCopySuccess(button) {
    const originalText = button.textContent;
    button.textContent = '已复制!';
    button.style.backgroundColor = '#4CAF50';
    button.style.color = 'white';
    
    setTimeout(() => {
        button.textContent = originalText;
        button.style.backgroundColor = '';
        button.style.color = '';
    }, 2000);
}

function showCopyError(button) {
    const originalText = button.textContent;
    button.textContent = '复制失败';
    button.style.backgroundColor = '#f44336';
    button.style.color = 'white';
    
    setTimeout(() => {
        button.textContent = originalText;
        button.style.backgroundColor = '';
        button.style.color = '';
    }, 2000);
}