/**
 * AITextView Stream Markdown Editor JavaScript
 * 完全模仿 RichEditorView 的架构设计
 * 集成纯JS Markdown渲染器
 */

"use strict";

// ==================== 纯JS Markdown渲染器 ====================

class BaseComponent {
  constructor(node, options = {}) {
    this.node = node
    this.options = options
    this.element = null
    this.children = []
  }

  render() {
    throw new Error('render() method must be implemented')
  }

  // 创建DOM元素
  createElement(tag, attributes = {}, children = []) {
    const element = document.createElement(tag)
    
    // 设置属性
    Object.entries(attributes).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value
      } else if (key === 'style' && typeof value === 'object') {
        Object.assign(element.style, value)
      } else if (key.startsWith('on')) {
        // 事件处理
        const eventName = key.slice(2).toLowerCase()
        element.addEventListener(eventName, value)
      } else {
        element.setAttribute(key, value)
      }
    })

    // 添加子元素
    children.forEach(child => {
      if (typeof child === 'string') {
        element.appendChild(document.createTextNode(child))
      } else if (child instanceof HTMLElement) {
        element.appendChild(child)
      }
    })

    return element
  }

  // 递归渲染子节点
  renderChildren() {
    if (!this.node.children) return []
    
    return this.node.children.map(childNode => {
      const Component = getNodeComponent(childNode.type)
      const component = new Component(childNode, this.options)
      return component.render()
    })
  }
}

// 具体组件实现
class TextComponent extends BaseComponent {
  render() {
    return this.createElement('span', {
      className: 'text-node'
    }, [this.node.value || ''])
  }
}

class ParagraphComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('p', {
      className: 'paragraph-node'
    }, children)
  }
}

class HeadingComponent extends BaseComponent {
  render() {
    const level = this.node.level || 1
    const tag = `h${Math.min(level, 6)}`
    const children = this.renderChildren()
    
    return this.createElement(tag, {
      className: `heading-node heading-${level}`,
      id: this.generateHeadingId()
    }, children)
  }

  generateHeadingId() {
    const text = this.node.children?.[0]?.value || ''
    return text.toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .trim()
  }
}

class CodeBlockComponent extends BaseComponent {
  render() {
    const language = this.node.language || ''
    const code = this.node.value || ''
    
    const container = this.createElement('div', {
      className: 'code-block-container'
    })

    if (language) {
      const langLabel = this.createElement('div', {
        className: 'code-block-language'
      }, [language])
      container.appendChild(langLabel)
    }

    const pre = this.createElement('pre', {
      className: 'code-block-pre'
    })
    
    const codeElement = this.createElement('code', {
      className: `language-${language}`,
      style: {
        fontFamily: 'Monaco, Consolas, "Courier New", monospace',
        fontSize: '14px',
        lineHeight: '1.5'
      }
    }, [code])
    
    pre.appendChild(codeElement)
    container.appendChild(pre)

    const copyButton = this.createElement('button', {
      className: 'code-block-copy',
      onClick: () => this.copyCode(code)
    }, ['复制'])
    container.appendChild(copyButton)

    return container
  }

  copyCode(code) {
    navigator.clipboard.writeText(code).then(() => {
      console.log('代码已复制到剪贴板')
    }).catch(err => {
      console.error('复制失败:', err)
    })
  }
}

class ListComponent extends BaseComponent {
  render() {
    const ordered = this.node.ordered || false
    const tag = ordered ? 'ol' : 'ul'
    const children = this.renderChildren()
    
    return this.createElement(tag, {
      className: `list-node ${ordered ? 'ordered-list' : 'unordered-list'}`
    }, children)
  }
}

class ListItemComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('li', {
      className: 'list-item-node'
    }, children)
  }
}

class BlockquoteComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('blockquote', {
      className: 'blockquote-node',
      style: {
        borderLeft: '4px solid #ddd',
        margin: '16px 0',
        padding: '0 16px',
        color: '#666',
        fontStyle: 'italic'
      }
    }, children)
  }
}

class LinkComponent extends BaseComponent {
  render() {
    const url = this.node.url || '#'
    const title = this.node.title || ''
    const children = this.renderChildren()
    
    return this.createElement('a', {
      className: 'link-node',
      href: url,
      title: title,
      target: this.isExternalLink(url) ? '_blank' : '_self',
      rel: this.isExternalLink(url) ? 'noopener noreferrer' : '',
      onClick: (e) => this.handleClick(e, url)
    }, children)
  }

  isExternalLink(url) {
    return url.startsWith('http://') || url.startsWith('https://')
  }

  handleClick(e, url) {
    if (this.options.onLinkClick) {
      this.options.onLinkClick(e, url)
    }
  }
}

class ImageComponent extends BaseComponent {
  render() {
    const src = this.node.url || ''
    const alt = this.node.alt || ''
    const title = this.node.title || ''
    
    const img = this.createElement('img', {
      className: 'image-node markdown-image',
      src: src,
      alt: alt,
      title: title,
      style: {
        maxWidth: '100%',
        height: 'auto',
        borderRadius: '4px'
      },
      onError: () => this.handleImageError(),
      onClick: () => this.handleImageClick(src)
    })

    const container = this.createElement('div', {
      className: 'image-container'
    }, [img])

    return container
  }

  handleImageError() {
    console.warn('图片加载失败:', this.node.url)
  }

  handleImageClick(src) {
    if (this.options.onImageClick) {
      this.options.onImageClick(src)
    }
  }
}

class StrongComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('strong', {
      className: 'strong-node'
    }, children)
  }
}

class EmphasisComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('em', {
      className: 'emphasis-node'
    }, children)
  }
}

class InlineCodeComponent extends BaseComponent {
  render() {
    return this.createElement('code', {
      className: 'inline-code-node',
      style: {
        fontFamily: 'Monaco, Consolas, "Courier New", monospace',
        backgroundColor: '#f5f5f5',
        padding: '2px 4px',
        borderRadius: '3px',
        fontSize: '0.9em'
      }
    }, [this.node.value || ''])
  }
}

class StrikethroughComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('del', {
      className: 'strikethrough-node'
    }, children)
  }
}

class HorizontalRuleComponent extends BaseComponent {
  render() {
    return this.createElement('hr', {
      className: 'horizontal-rule-node',
      style: {
        border: 'none',
        borderTop: '1px solid #ddd',
        margin: '20px 0'
      }
    })
  }
}

class TableComponent extends BaseComponent {
  render() {
    const headers = this.node.headers || []
    const rows = this.node.rows || []
    
    const table = this.createElement('table', {
      className: 'table-node markdown-table',
      style: {
        borderCollapse: 'collapse',
        width: '100%',
        margin: '16px 0'
      }
    })

    if (headers.length > 0) {
      const thead = this.createElement('thead')
      const headerRow = this.createElement('tr')
      
      headers.forEach(header => {
        const th = this.createElement('th', {
          style: {
            border: '1px solid #ddd',
            padding: '8px',
            backgroundColor: '#f5f5f5',
            fontWeight: 'bold'
          }
        }, [header])
        headerRow.appendChild(th)
      })
      
      thead.appendChild(headerRow)
      table.appendChild(thead)
    }

    const tbody = this.createElement('tbody')
    rows.forEach(row => {
      const tr = this.createElement('tr')
      row.forEach(cell => {
        const td = this.createElement('td', {
          style: {
            border: '1px solid #ddd',
            padding: '8px'
          }
        }, [cell])
        tr.appendChild(td)
      })
      tbody.appendChild(tr)
    })
    
    table.appendChild(tbody)
    return table
  }
}

// 节点类型到组件的映射
const NODE_COMPONENTS = {
  text: TextComponent,
  paragraph: ParagraphComponent,
  heading: HeadingComponent,
  code_block: CodeBlockComponent,
  code: InlineCodeComponent,
  list: ListComponent,
  list_item: ListItemComponent,
  blockquote: BlockquoteComponent,
  table: TableComponent,
  link: LinkComponent,
  image: ImageComponent,
  strong: StrongComponent,
  emphasis: EmphasisComponent,
  strikethrough: StrikethroughComponent,
  horizontal_rule: HorizontalRuleComponent,
}

// 获取节点对应的组件
function getNodeComponent(nodeType) {
  return NODE_COMPONENTS[nodeType] || TextComponent
}

// 纯JS Markdown渲染器
class PureJSMarkdownRenderer {
  constructor(options = {}) {
    this.options = {
      onLinkClick: null,
      onImageClick: null,
      customComponents: {},
      ...options
    }
  }

  // 渲染AST到DOM
  renderAST(ast, container) {
    if (!container) {
      throw new Error('Container element is required')
    }

    // 清空容器
    container.innerHTML = ''

    // 渲染每个根节点
    if (Array.isArray(ast)) {
      ast.forEach(node => this.renderNode(node, container))
    } else {
      this.renderNode(ast, container)
    }
  }

  // 渲染单个节点
  renderNode(node, container) {
    if (!node || !node.type) {
      console.warn('Invalid node:', node)
      return
    }

    const Component = getNodeComponent(node.type)
    const component = new Component(node, this.options)
    const element = component.render()
    
    container.appendChild(element)
  }

  // 流式渲染
  renderStreaming(ast, container, options = {}) {
    const {
      interval = 50,
      chunkSize = 1,
      onProgress = null,
      onComplete = null
    } = options

    let currentIndex = 0
    const totalNodes = Array.isArray(ast) ? ast.length : 1
    const nodes = Array.isArray(ast) ? ast : [ast]

    const renderNext = () => {
      if (currentIndex >= totalNodes) {
        if (onComplete) onComplete()
        return
      }

      this.renderNode(nodes[currentIndex], container)
      currentIndex++

      if (onProgress) {
        onProgress(currentIndex, totalNodes)
      }

      setTimeout(renderNext, interval)
    }

    renderNext()
  }
}

// ==================== 简单Markdown解析器 ====================

class SimpleMarkdownParser {
  constructor() {
    this.rules = {
      heading: /^(#{1,6})\s+(.+)$/gm,
      codeBlock: /^```(\w+)?\n([\s\S]*?)```$/gm,
      inlineCode: /`([^`]+)`/g,
      bold: /\*\*(.+?)\*\*/g,
      italic: /\*(.+?)\*/g,
      strikethrough: /~~(.+?)~~/g,
      link: /\[([^\]]+)\]\(([^)]+)\)/g,
      image: /!\[([^\]]*)\]\(([^)]+)\)/g,
      list: /^(\s*)([-*+]|\d+\.)\s+(.+)$/gm,
      blockquote: /^>\s*(.+)$/gm,
      horizontalRule: /^---$/gm,
      lineBreak: /\n\s*\n/g
    }
  }

  parse(markdown) {
    if (!markdown) return []
    
    let ast = []
    let lines = markdown.split('\n')
    let i = 0

    while (i < lines.length) {
      const line = lines[i]
      
      // 跳过空行
      if (line.trim() === '') {
        i++
        continue
      }

      // 解析标题
      if (line.match(/^#{1,6}\s+/)) {
        const match = line.match(/^(#{1,6})\s+(.+)$/)
        if (match) {
          ast.push({
            type: 'heading',
            level: match[1].length,
            children: [{ type: 'text', value: match[2] }]
          })
        }
        i++
        continue
      }

      // 解析代码块
      if (line.startsWith('```')) {
        const codeBlock = this.parseCodeBlock(lines, i)
        if (codeBlock) {
          ast.push(codeBlock.node)
          i = codeBlock.nextIndex
          continue
        }
      }

      // 解析列表
      if (line.match(/^(\s*)([-*+]|\d+\.)\s+/)) {
        const list = this.parseList(lines, i)
        if (list) {
          ast.push(list.node)
          i = list.nextIndex
          continue
        }
      }

      // 解析引用
      if (line.startsWith('>')) {
        const blockquote = this.parseBlockquote(lines, i)
        if (blockquote) {
          ast.push(blockquote.node)
          i = blockquote.nextIndex
          continue
        }
      }

      // 解析水平线
      if (line.match(/^---$/)) {
        ast.push({
          type: 'horizontal_rule'
        })
        i++
        continue
      }

      // 解析段落
      const paragraph = this.parseParagraph(lines, i)
      if (paragraph) {
        ast.push(paragraph.node)
        i = paragraph.nextIndex
        continue
      }

      i++
    }

    return ast
  }

  parseCodeBlock(lines, startIndex) {
    const line = lines[startIndex]
    const match = line.match(/^```(\w+)?$/)
    if (!match) return null

    const language = match[1] || ''
    let code = ''
    let i = startIndex + 1

    while (i < lines.length && !lines[i].startsWith('```')) {
      code += lines[i] + '\n'
      i++
    }

    if (i >= lines.length) return null

    return {
      node: {
        type: 'code_block',
        language: language,
        value: code.trim()
      },
      nextIndex: i + 1
    }
  }

  parseList(lines, startIndex) {
    const line = lines[startIndex]
    const match = line.match(/^(\s*)([-*+]|\d+\.)\s+(.+)$/)
    if (!match) return null

    const ordered = /\d+\./.test(match[2])
    const items = []
    let i = startIndex

    while (i < lines.length) {
      const currentLine = lines[i]
      const currentMatch = currentLine.match(/^(\s*)([-*+]|\d+\.)\s+(.+)$/)
      
      if (!currentMatch) break

      const content = this.parseInlineContent(currentMatch[3])
      items.push({
        type: 'list_item',
        children: content
      })

      i++
    }

    return {
      node: {
        type: 'list',
        ordered: ordered,
        children: items
      },
      nextIndex: i
    }
  }

  parseBlockquote(lines, startIndex) {
    let content = ''
    let i = startIndex

    while (i < lines.length && lines[i].startsWith('>')) {
      content += lines[i].replace(/^>\s*/, '') + '\n'
      i++
    }

    return {
      node: {
        type: 'blockquote',
        children: this.parseInlineContent(content.trim())
      },
      nextIndex: i
    }
  }

  parseParagraph(lines, startIndex) {
    let content = ''
    let i = startIndex

    while (i < lines.length && lines[i].trim() !== '' && !lines[i].match(/^#{1,6}\s+/) && !lines[i].startsWith('```') && !lines[i].match(/^(\s*)([-*+]|\d+\.)\s+/) && !lines[i].startsWith('>') && !lines[i].match(/^---$/)) {
      content += lines[i] + '\n'
      i++
    }

    if (content.trim() === '') return null

    return {
      node: {
        type: 'paragraph',
        children: this.parseInlineContent(content.trim())
      },
      nextIndex: i
    }
  }

  parseInlineContent(text) {
    if (!text) return [{ type: 'text', value: '' }]

    let content = text
    const nodes = []

    // 处理内联代码
    content = content.replace(/`([^`]+)`/g, (match, code) => {
      nodes.push({ type: 'text', value: content.substring(0, content.indexOf(match)) })
      nodes.push({ type: 'code', value: code })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 处理粗体
    content = content.replace(/\*\*(.+?)\*\*/g, (match, text) => {
      const before = content.substring(0, content.indexOf(match))
      if (before) nodes.push({ type: 'text', value: before })
      nodes.push({
        type: 'strong',
        children: [{ type: 'text', value: text }]
      })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 处理斜体
    content = content.replace(/\*(.+?)\*/g, (match, text) => {
      const before = content.substring(0, content.indexOf(match))
      if (before) nodes.push({ type: 'text', value: before })
      nodes.push({
        type: 'emphasis',
        children: [{ type: 'text', value: text }]
      })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 处理删除线
    content = content.replace(/~~(.+?)~~/g, (match, text) => {
      const before = content.substring(0, content.indexOf(match))
      if (before) nodes.push({ type: 'text', value: before })
      nodes.push({
        type: 'strikethrough',
        children: [{ type: 'text', value: text }]
      })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 处理链接
    content = content.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, text, url) => {
      const before = content.substring(0, content.indexOf(match))
      if (before) nodes.push({ type: 'text', value: before })
      nodes.push({
        type: 'link',
        url: url,
        children: [{ type: 'text', value: text }]
      })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 处理图片
    content = content.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (match, alt, src) => {
      const before = content.substring(0, content.indexOf(match))
      if (before) nodes.push({ type: 'text', value: before })
      nodes.push({
        type: 'image',
        url: src,
        alt: alt
      })
      content = content.substring(content.indexOf(match) + match.length)
      return ''
    })

    // 添加剩余文本
    if (content) {
      nodes.push({ type: 'text', value: content })
    }

    return nodes.length > 0 ? nodes : [{ type: 'text', value: text }]
  }
}

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
    parser: null,
    renderer: null,
    currentContent: '',
    isStreaming: false,
    
    init() {
        try {
            RE.callback('debug/初始化纯JS Markdown渲染器');
            
            // 初始化解析器和渲染器
            this.parser = new SimpleMarkdownParser();
            this.renderer = new PureJSMarkdownRenderer({
                onLinkClick: (e, url) => {
                    RE.callback('debug/链接点击: ' + url);
                },
                onImageClick: (src) => {
                    RE.callback('debug/图片点击: ' + src);
                }
            });
            
            RE.callback('debug/纯JS Markdown渲染器初始化完成');
            console.log('✅ 纯JS Markdown渲染器初始化完成');
        } catch (error) {
            RE.callback('debug/纯JS渲染器初始化错误: ' + error.message);
            console.error('❌ 纯JS Markdown渲染器初始化失败:', error);
        }
    },
    
    updateMarkdown(newContent, isComplete) {
        RE.callback('debug/updateMarkdown被调用:长度=' + newContent.length + ',完成=' + isComplete);
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
        
        // 更新当前内容
        this.currentContent = newContent;
        this.isStreaming = !isComplete;
        
        try {
            // 解析Markdown为AST
            const ast = this.parser.parse(newContent);
            RE.callback('debug/Markdown解析为AST完成:节点数=' + ast.length);
            
            // 渲染AST到DOM
            this.renderer.renderAST(ast, RE.editor);
            RE.callback('debug/AST渲染到DOM完成');
            
            // 添加代码复制功能
            this.addCodeCopyListeners();
            
            // 延迟滚动到底部，确保DOM更新完成
            setTimeout(() => {
                RE.scrollToBottom();
            }, 50);
            
            // 发送完成信号
            if (isComplete) {
                RE.callback('streamComplete');
            }
            
            // 触发内容更新回调
            RE.callback('contentUpdate');
        } catch (error) {
            RE.callback('debug/Markdown处理错误: ' + error.message);
            console.error('❌ Markdown处理失败:', error);
        }
    },
    
    reset() {
        console.log('🔄 重置流式处理器');
        this.currentContent = '';
        this.isStreaming = false;
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