/**
 * AITextView Stream Markdown Editor JavaScript
 * 完全模仿 RichEditorView 的架构设计
 */

"use strict";

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
    md: null,
    currentContent: '',
    isStreaming: false,
    
    init() {
        try {
            // 检查markdown-it是否可用
            if (typeof window.markdownit === 'undefined') {
                RE.callback('debug/错误:markdown-it库未加载，使用备用渲染器');
                this.initFallbackRenderer();
                return;
            }
            
            // 初始化 markdown-it 实例
            this.md = window.markdownit({
                html: true,
                linkify: true,
                typographer: true,
                breaks: true
            });
            
            RE.callback('debug/markdown-it实例创建成功');
            
            // 添加插件（安全地添加，如果插件不存在则跳过）
            try {
                if (typeof window.markdownItEmoji !== 'undefined') {
                    this.md.use(window.markdownItEmoji);
                    RE.callback('debug/emoji插件加载成功');
                } else {
                    RE.callback('debug/emoji插件未找到，跳过');
                }
            } catch (e) {
                RE.callback('debug/emoji插件加载失败: ' + e.message);
            }
            
            try {
                if (typeof window.markdownItCodeCopy !== 'undefined') {
                    this.md.use(window.markdownItCodeCopy, {
                        buttonClass: 'copy-code-button',
                        buttonText: '复制代码'
                    });
                    RE.callback('debug/code-copy插件加载成功');
                } else {
                    RE.callback('debug/code-copy插件未找到，跳过');
                }
            } catch (e) {
                RE.callback('debug/code-copy插件加载失败: ' + e.message);
            }
            
            try {
                if (typeof window.markdownItTable !== 'undefined') {
                    this.md.use(window.markdownItTable);
                    RE.callback('debug/table插件加载成功');
                } else {
                    RE.callback('debug/table插件未找到，跳过');
                }
            } catch (e) {
                RE.callback('debug/table插件加载失败: ' + e.message);
            }
            
            // 添加上标下标支持
            try {
                this.addSuperscriptSubscriptSupport();
                RE.callback('debug/上标下标支持添加成功');
            } catch (e) {
                RE.callback('debug/上标下标支持添加失败: ' + e.message);
            }
            
            try {
                if (typeof window.markdownItKatex !== 'undefined') {
                    this.md.use(window.markdownItKatex, {
                        throwOnError: false,
                        errorColor: '#cc0000'
                    });
                    RE.callback('debug/katex插件加载成功');
                } else {
                    RE.callback('debug/katex插件未找到，跳过');
                }
            } catch (e) {
                RE.callback('debug/katex插件加载失败: ' + e.message);
            }
            
            // 设置自定义渲染器
            try {
                this.setupCustomRenderers();
                RE.callback('debug/自定义渲染器设置成功');
            } catch (e) {
                RE.callback('debug/自定义渲染器设置失败: ' + e.message);
            }
            
            RE.callback('debug/Stream Markdown Processor 初始化完成');
            console.log('✅ Stream Markdown Processor 初始化完成');
        } catch (error) {
            RE.callback('debug/初始化错误: ' + error.message);
            console.error('❌ Stream Markdown Processor 初始化失败:', error);
            // 如果初始化失败，使用备用渲染器
            this.initFallbackRenderer();
        }
    },
    
    // 备用简单渲染器
    initFallbackRenderer() {
        RE.callback('debug/初始化备用渲染器');
        this.md = {
            render: (markdown) => {
                // 简单的markdown渲染，至少能显示基本格式
                let html = markdown
                    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
                    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
                    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
                    .replace(/^#### (.*$)/gim, '<h4>$1</h4>')
                    .replace(/^##### (.*$)/gim, '<h5>$1</h5>')
                    .replace(/^###### (.*$)/gim, '<h6>$1</h6>')
                    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                    .replace(/\*(.*?)\*/g, '<em>$1</em>')
                    .replace(/`(.*?)`/g, '<code>$1</code>')
                    .replace(/^\- (.*$)/gim, '<li>$1</li>')
                    .replace(/^(\d+)\. (.*$)/gim, '<li>$2</li>')
                    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
                    .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1">')
                    .replace(/^> (.*$)/gim, '<blockquote>$1</blockquote>')
                    .replace(/\n\n/g, '</p><p>')
                    .replace(/\n/g, '<br>');
                
                // 包装列表项
                html = html.replace(/(<li>.*<\/li>)/g, '<ul>$1</ul>');
                
                // 包装段落
                if (!html.startsWith('<')) {
                    html = '<p>' + html + '</p>';
                }
                
                RE.callback('debug/备用渲染器处理完成，HTML长度: ' + html.length);
                return html;
            }
        };
        RE.callback('debug/备用渲染器初始化完成');
    },
    
    addSuperscriptSubscriptSupport() {
        // 添加上标支持 (^text^)
        this.md.inline.ruler.before('emphasis', 'superscript', (state, silent) => {
            const start = state.pos;
            const marker = state.src.charCodeAt(start);
            
            if (marker !== 0x5E /* ^ */) return false;
            
            const max = state.posMax;
            let pos = start + 1;
            
            // 查找结束标记
            while (pos < max) {
                if (state.src.charCodeAt(pos) === 0x5E /* ^ */) {
                    break;
                }
                pos++;
            }
            
            if (pos >= max) return false;
            
            const content = state.src.slice(start + 1, pos);
            if (content.length === 0) return false;
            
            if (!silent) {
                const token = state.push('superscript_open', 'sup', 1);
                token.markup = '^';
                
                const textToken = state.push('text', '', 0);
                textToken.content = content;
                
                const closeToken = state.push('superscript_close', 'sup', -1);
                closeToken.markup = '^';
            }
            
            state.pos = pos + 1;
            return true;
        });
        
        // 添加下标支持 (~text~)
        this.md.inline.ruler.before('emphasis', 'subscript', (state, silent) => {
            const start = state.pos;
            const marker = state.src.charCodeAt(start);
            
            if (marker !== 0x7E /* ~ */) return false;
            
            const max = state.posMax;
            let pos = start + 1;
            
            // 查找结束标记
            while (pos < max) {
                if (state.src.charCodeAt(pos) === 0x7E /* ~ */) {
                    break;
                }
                pos++;
            }
            
            if (pos >= max) return false;
            
            const content = state.src.slice(start + 1, pos);
            if (content.length === 0) return false;
            
            if (!silent) {
                const token = state.push('subscript_open', 'sub', 1);
                token.markup = '~';
                
                const textToken = state.push('text', '', 0);
                textToken.content = content;
                
                const closeToken = state.push('subscript_close', 'sub', -1);
                closeToken.markup = '~';
            }
            
            state.pos = pos + 1;
            return true;
        });
    },
    
    setupCustomRenderers() {
        // 自定义代码块渲染
        this.md.renderer.rules.fence = (tokens, idx, options, env, renderer) => {
            const token = tokens[idx];
            const info = token.info ? this.md.utils.unescapeAll(token.info).trim() : '';
            const langName = info ? info.split(/\s+/g)[0] : '';
            const langClass = options.langPrefix + langName;
            
            return `<pre class="code-block"><code class="${langClass}">${token.content}</code></pre>`;
        };
        
        // 自定义表格渲染
        this.md.renderer.rules.table_open = () => '<div class="table-wrapper"><table class="markdown-table">';
        this.md.renderer.rules.table_close = () => '</table></div>';
        
        // 自定义链接渲染
        this.md.renderer.rules.link_open = (tokens, idx, options, env, renderer) => {
            const token = tokens[idx];
            const href = token.attrGet('href');
            if (href && href.startsWith('ai-callback://incomplete-link')) {
                return '<a href="#" class="incomplete-link">';
            }
            return renderer.renderToken(tokens, idx, options);
        };
    },
    
    updateMarkdown(newContent, isComplete) {
        RE.callback('debug/updateMarkdown被调用:长度=' + newContent.length + ',完成=' + isComplete);
        RE.callback('debug/更新Markdown:长度=' + newContent.length + ',完成=' + isComplete + ',编辑器=' + (!!RE.editor) + ',md=' + (!!this.md));
        
        if (!RE.editor) {
            RE.callback('debug/错误:RE.editor不存在，无法更新Markdown');
            return;
        }
        
        if (!this.md) {
            RE.callback('debug/错误:markdown-it实例不存在，存储待处理内容');
            // 如果markdown-it实例不存在，存储待处理的内容
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
        
        try {
            this.currentContent += newContent;
            this.isStreaming = !isComplete;
            
            // 处理不完整的 Markdown
            let processedContent = this.currentContent;
            if (!isComplete) {
                processedContent = this.handleIncompleteMarkdown(processedContent);
            }
            
            // 解析为 HTML
            const html = this.md.render(processedContent);
            RE.callback('debug/Markdown解析完成:HTML长度=' + html.length);
            
            // 更新显示
            this.updateDisplay(html, isComplete);
            
            // 如果是流式结束，触发完成回调
            if (isComplete) {
                RE.callback('streamComplete');
            }
            
            // 触发内容更新回调
            RE.callback('contentUpdate');
        } catch (error) {
            RE.callback('debug/Markdown更新错误: ' + error.message);
            console.error('❌ Markdown 更新失败:', error);
        }
    },
    
    handleIncompleteMarkdown(content) {
        // 处理不完整的粗体
        content = content.replace(/(\*\*)([^*]*?)$/g, (match, p1, p2) => {
            if (p2 && !/^[\s_~*`]*$/.test(p2)) {
                return p1 + p2 + '**';
            }
            return match;
        });
        
        // 处理不完整的斜体
        content = content.replace(/(\*)([^*]*?)$/g, (match, p1, p2) => {
            if (p2 && !/^[\s_~*`]*$/.test(p2)) {
                return p1 + p2 + '*';
            }
            return match;
        });
        
        // 处理不完整的代码块
        const backtickCount = (content.match(/```/g) || []).length;
        if (backtickCount % 2 === 1) {
            content += '```';
        }
        
        // 处理不完整的链接
        content = content.replace(/\[([^\]]*?)$/g, (match, p1) => {
            if (p1 && !/^[\s]*$/.test(p1)) {
                return match + '](ai-callback://incomplete-link)';
            }
            return match;
        });
        
        // 处理不完整的列表
        content = content.replace(/(\n|^)(\s*)([-*+]|\d+\.)\s*([^\n]*?)$/g, (match, p1, p2, p3, p4) => {
            if (p4 && !/^[\s]*$/.test(p4)) {
                return match;
            }
            return match;
        });
        
        // 处理不完整的上下标
        content = content.replace(/(\^)([^^]*?)$/g, (match, p1, p2) => {
            if (p2 && !/^[\s]*$/.test(p2)) {
                return p1 + p2 + '^';
            }
            return match;
        });
        
        content = content.replace(/(~)([^~]*?)$/g, (match, p1, p2) => {
            if (p2 && !/^[\s]*$/.test(p2)) {
                return p1 + p2 + '~';
            }
            return match;
        });
        
        return content;
    },
    
    updateDisplay(html, isComplete) {
        RE.callback('debug/更新显示:HTML长度=' + html.length + ',完成=' + isComplete + ',编辑器=' + (!!RE.editor));
        
        if (!RE.editor) {
            RE.callback('debug/错误:编辑器元素未找到');
            return;
        }
        
        try {
            // 添加流式更新样式
            if (!isComplete) {
                RE.editor.classList.add('streaming');
                // 添加流式动画效果
                this.addStreamingAnimation(RE.editor);
            } else {
                RE.editor.classList.remove('streaming');
            }
            
            RE.editor.innerHTML = html;
            RE.callback('debug/HTML内容已设置到编辑器');
            
            // 添加代码复制功能
            this.addCodeCopyListeners();
            
            // 延迟滚动到底部，确保DOM更新完成
            setTimeout(() => {
                RE.scrollToBottom();
            }, 50);
        } catch (error) {
            RE.callback('debug/显示更新错误: ' + error.message);
            console.error('❌ 显示更新失败:', error);
        }
    },
    
    // 添加流式渲染动画
    addStreamingAnimation(element) {
        element.classList.add('streaming-content');
        // 移除动画类，以便下次可以重新添加
        setTimeout(() => {
            element.classList.remove('streaming-content');
        }, 300);
    },
    
    reset() {
        console.log('🔄 重置流式处理器');
        this.currentContent = '';
        this.isStreaming = false;
        RE.editor.innerHTML = '';
        RE.callback('contentReset');
    },
    
    addCodeCopyListeners() {
        // 为所有代码块添加复制按钮事件监听
        const copyButtons = RE.editor.querySelectorAll('.copy-code-button');
        copyButtons.forEach(button => {
            if (!button.hasAttribute('data-listener-added')) {
                button.addEventListener('click', function() {
                    const codeBlock = this.parentElement.querySelector('code');
                    if (codeBlock) {
                        navigator.clipboard.writeText(codeBlock.textContent).then(() => {
                            showCopySuccess(this);
                        }).catch(() => {
                            fallbackCopyTextToClipboard(codeBlock.textContent);
                            showCopySuccess(this);
                        });
                    }
                });
                button.setAttribute('data-listener-added', 'true');
            }
        });
    }
};

// API 方法，模仿 RichEditorView
RE.setMarkdown = function(content) {
    RE.streamMarkdownProcessor.reset();
    RE.streamMarkdownProcessor.updateMarkdown(content, true);
};

RE.getMarkdown = function() {
    return RE.streamMarkdownProcessor.currentContent;
};

RE.getHtml = function() {
    return RE.editor.innerHTML;
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
    
    // 检查markdown-it是否可用
    if (typeof window.markdownit === 'undefined') {
        RE.callback('debug/错误:markdown-it库未加载');
        return;
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
    
    // 如果检查次数超过限制，强制初始化（使用备用渲染器）
    if (dependencyCheckCount >= maxDependencyChecks) {
        RE.callback('debug/依赖检查超时，强制初始化（将使用备用渲染器）');
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