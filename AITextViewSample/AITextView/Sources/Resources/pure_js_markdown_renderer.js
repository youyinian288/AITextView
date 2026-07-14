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

// 重型渲染任务队列（用于 Mermaid、KaTeX 等延迟分批渲染）
const HeavyRenderQueue = {
  tasks: [],
  scheduled: false,

  enqueue(task) {
    if (typeof task !== 'function') return
    this.tasks.push(task)
    if (this.scheduled) return
    this.scheduled = true

    const run = () => {
      let count = 0
      const maxPerFrame = 5

      while (this.tasks.length > 0 && count < maxPerFrame) {
        const t = this.tasks.shift()
        try {
          t()
        } catch (e) {
          console.error('HeavyRenderQueue task error:', e)
        }
        count++
      }

      if (this.tasks.length > 0) {
        if (typeof window !== 'undefined' && typeof window.requestAnimationFrame === 'function') {
          window.requestAnimationFrame(run)
        } else {
          setTimeout(run, 16)
        }
      } else {
        this.scheduled = false
      }
    }

    if (typeof window !== 'undefined' && typeof window.requestAnimationFrame === 'function') {
      window.requestAnimationFrame(run)
    } else {
      setTimeout(run, 16)
    }
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
  constructor(node) {
    super(node)
    this.copyButton = null
  }
  
  render() {
    const language = this.node.language || ''
    // 确保从 code 元素获取实际显示的文本，而不是从 node.value
    let code = this.node.value || ''
    
    // Mermaid 特殊处理：```mermaid``` 代码块渲染为流程图
    if (language === 'mermaid' && typeof window.mermaid !== 'undefined') {
      const mermaidContainer = this.createElement('div', {
        className: 'mermaid'
      }, [code])

      HeavyRenderQueue.enqueue(() => {
        try {
          if (typeof window.mermaid.initialize === 'function') {
            window.mermaid.initialize({ startOnLoad: false })
          }
          if (typeof window.mermaid.init === 'function') {
            window.mermaid.init(undefined, [mermaidContainer])
          } else if (typeof window.mermaid.run === 'function') {
            window.mermaid.run({ nodes: [mermaidContainer] })
          }
        } catch (e) {
          console.error('Mermaid 渲染失败:', e)
        }
      })

      return mermaidContainer
    }

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

    // 存储代码内容的引用，以便复制时使用
    this.codeContent = code
    this.codeElement = codeElement // 保存引用，以便后续从 DOM 获取
    this.container = container // 保存容器引用
    
    this.copyButton = this.createElement('button', {
      className: 'code-block-copy',
      onClick: (e) => {
        e.preventDefault()
        e.stopPropagation()
        
        // 优先使用存储的代码内容，如果为空则从 DOM 中获取
        let codeToCopy = this.codeContent
        
        // 如果代码为空，尝试从 DOM 元素中获取
        if (!codeToCopy || codeToCopy.trim() === '') {
          if (this.codeElement) {
            codeToCopy = this.codeElement.textContent || this.codeElement.innerText || ''
          }
          // 如果还是为空，尝试从整个 pre 元素获取
          if ((!codeToCopy || codeToCopy.trim() === '') && this.container) {
            const preElement = this.container.querySelector('pre')
            if (preElement) {
              codeToCopy = preElement.textContent || preElement.innerText || ''
            }
          }
        }
        
        console.log('复制按钮点击，代码内容:', codeToCopy ? `长度 ${codeToCopy.length}` : '空')
        if (codeToCopy) {
          console.log('代码预览（前100字符）:', codeToCopy.substring(0, 100))
        }
        this.copyCode(codeToCopy, this.copyButton)
      }
    }, ['复制'])
    container.appendChild(this.copyButton)

    return container
  }

  copyCode(code, button) {
    // 验证代码内容
    if (!code || code.trim() === '') {
      console.error('代码内容为空，无法复制')
      this.showCopyError(button)
      return
    }
    
    console.log('准备复制代码，长度:', code.length, '内容预览:', code.substring(0, 50))
    
    // 优先使用现代 Clipboard API
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(code).then(() => {
        console.log('代码已复制到剪贴板（Clipboard API）')
        this.showCopyFeedback(button)
      }).catch(err => {
        console.error('Clipboard API 复制失败，尝试备用方案:', err)
        this.fallbackCopyCode(code, button)
      })
    } else {
      // 使用备用方案
      console.log('Clipboard API 不可用，使用 execCommand')
      this.fallbackCopyCode(code, button)
    }
  }
  
  fallbackCopyCode(code, button) {
    // 创建一个临时的 textarea 元素
    const textarea = document.createElement('textarea')
    
    // 设置样式，确保元素可以被选中（即使在屏幕外）
    textarea.value = code
    textarea.style.position = 'fixed'
    textarea.style.left = '0'
    textarea.style.top = '0'
    textarea.style.width = '2em'
    textarea.style.height = '2em'
    textarea.style.padding = '0'
    textarea.style.border = 'none'
    textarea.style.outline = 'none'
    textarea.style.boxShadow = 'none'
    textarea.style.background = 'transparent'
    textarea.style.opacity = '0'
    textarea.style.zIndex = '-9999'
    textarea.setAttribute('readonly', '')
    textarea.setAttribute('aria-hidden', 'true')
    
    // 添加到 DOM
    document.body.appendChild(textarea)
    
    // 立即尝试选择（在某些浏览器中需要这样）
    textarea.focus()
    
    // 使用 setTimeout 确保元素已经渲染并可以获得焦点
    setTimeout(() => {
      try {
        // 选择文本
        if (document.activeElement === textarea || textarea === document.activeElement) {
          textarea.select()
          textarea.setSelectionRange(0, code.length)
        } else {
          // 如果焦点不在 textarea 上，重新尝试
          textarea.focus()
          textarea.select()
          textarea.setSelectionRange(0, code.length)
        }
        
        // 再次确保选中所有文本
        textarea.select()
        
        // 执行复制命令
        const successful = document.execCommand('copy')
        
        if (successful) {
          console.log('代码已复制到剪贴板（使用 execCommand），长度:', code.length)
          this.showCopyFeedback(button)
        } else {
          console.error('execCommand 复制失败，返回 false')
          this.showCopyError(button)
        }
      } catch (err) {
        console.error('复制操作出错:', err)
        this.showCopyError(button)
      } finally {
        // 清理：移除临时元素
        try {
          if (textarea && textarea.parentNode) {
            document.body.removeChild(textarea)
          }
        } catch (e) {
          console.error('清理 textarea 时出错:', e)
        }
      }
    }, 10) // 给一个很小的延迟确保 DOM 更新
  }
  
  showCopyFeedback(button) {
    if (!button) return
    
    const originalText = button.textContent
    button.textContent = '已复制 ✓'
    button.style.opacity = '0.7'
    
    // 2秒后恢复原文本
    setTimeout(() => {
      button.textContent = originalText
      button.style.opacity = '1'
    }, 2000)
  }
  
  showCopyError(button) {
    if (!button) return
    
    const originalText = button.textContent
    button.textContent = '复制失败'
    button.style.opacity = '0.7'
    
    // 2秒后恢复原文本
    setTimeout(() => {
      button.textContent = originalText
      button.style.opacity = '1'
    }, 2000)
    
    console.error('无法复制代码到剪贴板，请手动复制')
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

    // 支持 GFM 任务列表语法 - [ ] / - [x]
    if (this.node.task) {
      const checkboxAttrs = {
        type: 'checkbox',
        className: 'task-list-item-checkbox',
        disabled: 'disabled'
      }
      if (this.node.checked) {
        checkboxAttrs.checked = 'checked'
      }

      const checkbox = this.createElement('input', checkboxAttrs)
      const label = this.createElement('span', {
        className: 'task-list-item-label'
      }, children)

      return this.createElement('li', {
        className: 'list-item-node task-list-item'
      }, [checkbox, label])
    }

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

class SubscriptComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('sub', {
      className: 'subscript-node'
    }, children)
  }
}

class SuperscriptComponent extends BaseComponent {
  render() {
    const children = this.renderChildren()
    return this.createElement('sup', {
      className: 'superscript-node'
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

class MathBlockComponent extends BaseComponent {
  render() {
    const content = this.node.content || ''
    const container = this.createElement('div', {
      className: 'math-block-node',
      style: {
        margin: '16px 0',
        textAlign: 'center',
        overflowX: 'auto'
      }
    })
    
    if (typeof window.katex !== 'undefined') {
      HeavyRenderQueue.enqueue(() => {
        try {
          window.katex.render(content, container, {
            throwOnError: false,
            displayMode: true
          })
        } catch (error) {
          console.warn('KaTeX 渲染失败:', error)
          container.textContent = content
        }
      })
    } else {
      container.textContent = content
    }
    
    return container
  }
}

class MathInlineComponent extends BaseComponent {
  render() {
    const content = this.node.content || ''
    const container = this.createElement('span', {
      className: 'math-inline-node',
      style: {
        display: 'inline-block'
      }
    })
    
    if (typeof window.katex !== 'undefined') {
      HeavyRenderQueue.enqueue(() => {
        try {
          window.katex.render(content, container, {
            throwOnError: false,
            displayMode: false
          })
        } catch (error) {
          console.warn('KaTeX 渲染失败:', error)
          container.textContent = content
        }
      })
    } else {
      container.textContent = content
    }
    
    return container
  }
}

class HtmlBlockComponent extends BaseComponent {
  render() {
    const content = this.node.content || ''
    const container = this.createElement('div', {
      className: 'html-block-node'
    })
    
    // 直接插入 HTML 内容（已经通过 markdown-it 的 html: true 选项处理）
    container.innerHTML = content
    
    return container
  }
}

class HtmlInlineComponent extends BaseComponent {
  render() {
    const content = this.node.content || ''
    const container = this.createElement('span', {
      className: 'html-inline-node'
    })
    
    // 直接插入 HTML 内容
    container.innerHTML = content
    
    return container
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
  subscript: SubscriptComponent,
  superscript: SuperscriptComponent,
  horizontal_rule: HorizontalRuleComponent,
  math_block: MathBlockComponent,
  math_inline: MathInlineComponent,
  html_block: HtmlBlockComponent,
  html_inline: HtmlInlineComponent,
}

// 获取节点对应的组件
function getNodeComponent(nodeType) {
  return NODE_COMPONENTS[nodeType] || TextComponent
}

class PureJSMarkdownRenderer {
  constructor(options = {}) {
    this.options = {
      onLinkClick: null,
      onImageClick: null,
      customComponents: {},
      ...options
    }
    // 保存上次渲染的AST，用于增量更新
    this.lastRenderedAST = null
    // DOM节点映射：AST索引 -> DOM元素
    this.astToDOM = new Map()
  }

  // 渲染AST到DOM（完整渲染）
  renderAST(ast, container, useIncremental = true) {
    if (!container) {
      throw new Error('Container element is required')
    }

    // 标准化AST为数组
    const normalizedAST = Array.isArray(ast) ? ast : [ast]

    // 如果启用增量渲染且已有上次的AST，使用增量渲染
    if (useIncremental && this.lastRenderedAST && this.lastRenderedAST.length > 0) {
      this.renderIncremental(normalizedAST, container)
    } else {
      // 完整渲染
      container.innerHTML = ''
      this.astToDOM.clear()
      normalizedAST.forEach((node, index) => {
        const element = this.renderNode(node, container)
        this.astToDOM.set(index, element)
      })
      this.lastRenderedAST = normalizedAST
    }
  }

  // 增量渲染：只更新变化的部分
  renderIncremental(newAST, container) {
    const oldAST = this.lastRenderedAST || []
    const diff = this.astDiff(oldAST, newAST)

    // 优化：如果是纯追加场景（只有新增节点，没有修改和删除），快速处理
    if (diff.added.length > 0 && diff.modified.length === 0 && diff.removed.length === 0) {
      // 直接追加新节点，无需复杂的DOM操作
      diff.added.forEach(({ node, index }) => {
        const element = this.renderNode(node, container)
        this.astToDOM.set(index, element)
      })
      this.lastRenderedAST = newAST
      return
    }

    // 完整更新路径：处理删除、修改和新增

    // 处理删除的节点（先删除，避免索引问题）
    // 从后往前删除，保持索引稳定
    diff.removed.sort((a, b) => b.index - a.index)
    diff.removed.forEach(({ index }) => {
      const element = this.astToDOM.get(index)
      if (element && element.parentNode) {
        element.remove()
      }
      this.astToDOM.delete(index)
    })

    // 处理修改的节点
    diff.modified.forEach(({ oldNode, newNode, index }) => {
      const oldElement = this.astToDOM.get(index)
      if (oldElement && oldElement.parentNode) {
        const newElement = this.renderNode(newNode, null)
        oldElement.replaceWith(newElement)
        this.astToDOM.set(index, newElement)
      } else {
        // 如果找不到旧元素，直接添加
        const newElement = this.renderNode(newNode, container)
        this.astToDOM.set(index, newElement)
      }
    })

    // 处理新增的节点（在最后添加）
    diff.added.forEach(({ node, index }) => {
      const element = this.renderNode(node, container)
      this.astToDOM.set(index, element)
    })

    // 重新建立完整的AST到DOM映射（确保索引一致性）
    const newASTToDOM = new Map()
    const domElements = Array.from(container.children)
    newAST.forEach((node, index) => {
      if (index < domElements.length) {
        newASTToDOM.set(index, domElements[index])
      } else {
        // 如果DOM元素不存在，说明是新节点，从映射中获取
        const element = this.astToDOM.get(index)
        if (element) {
          newASTToDOM.set(index, element)
        }
      }
    })
    this.astToDOM = newASTToDOM

    // 保存新的AST
    this.lastRenderedAST = newAST
  }

  // AST差异比较算法
  astDiff(oldAST, newAST) {
    const diff = {
      added: [],      // {node, index}
      modified: [],   // {oldNode, newNode, index}
      removed: []     // {index}
    }

    const oldLength = oldAST.length
    const newLength = newAST.length

    // 快速路径：流式更新通常只是追加新节点
    // 如果新AST包含所有旧节点且只是追加，可以快速处理
    if (newLength >= oldLength && oldLength > 0) {
      // 检查前面的节点是否都相同（流式更新通常不会修改已存在的节点）
      let allPreviousNodesEqual = true
      const minLength = Math.min(oldLength, newLength)
      
      for (let i = 0; i < minLength; i++) {
        if (!this.astNodeEqual(oldAST[i], newAST[i])) {
          allPreviousNodesEqual = false
          break
        }
      }

      // 如果前面的节点都相同，只需要添加新增的节点
      if (allPreviousNodesEqual && newLength > oldLength) {
        for (let i = oldLength; i < newLength; i++) {
          diff.added.push({
            node: newAST[i],
            index: i
          })
        }
        return diff
      }
    }

    // 完整比较路径
    const minLength = Math.min(oldLength, newLength)

    // 比较共同长度的部分
    for (let i = 0; i < minLength; i++) {
      if (this.astNodeEqual(oldAST[i], newAST[i])) {
        // 节点相同，无需更新
        continue
      } else {
        // 节点不同，标记为修改
        diff.modified.push({
          oldNode: oldAST[i],
          newNode: newAST[i],
          index: i
        })
      }
    }

    // 新增的节点
    if (newLength > oldLength) {
      for (let i = oldLength; i < newLength; i++) {
        diff.added.push({
          node: newAST[i],
          index: i
        })
      }
    }

    // 删除的节点（只有在完整更新时才处理，流式更新通常只追加）
    // 注意：流式更新时，删除操作较少，这里简化处理
    if (oldLength > newLength) {
      for (let i = newLength; i < oldLength; i++) {
        diff.removed.push({ index: i })
      }
    }

    return diff
  }

  // 比较两个AST节点是否相等
  astNodeEqual(node1, node2) {
    if (!node1 || !node2) return node1 === node2
    if (node1.type !== node2.type) return false

    // 比较关键属性
    const keys1 = Object.keys(node1).sort()
    const keys2 = Object.keys(node2).sort()

    if (keys1.length !== keys2.length) return false

    for (const key of keys1) {
      if (key === 'children') {
        // 递归比较子节点
        if (!this.astChildrenEqual(node1.children, node2.children)) {
          return false
        }
      } else if (node1[key] !== node2[key]) {
        return false
      }
    }

    return true
  }

  // 比较子节点数组
  astChildrenEqual(children1, children2) {
    if (!children1 && !children2) return true
    if (!children1 || !children2) return false
    if (children1.length !== children2.length) return false

    for (let i = 0; i < children1.length; i++) {
      if (!this.astNodeEqual(children1[i], children2[i])) {
        return false
      }
    }

    return true
  }

  // 渲染单个节点
  renderNode(node, container) {
    if (!node || !node.type) {
      console.warn('Invalid node:', node)
      return null
    }

    const Component = getNodeComponent(node.type)
    const component = new Component(node, this.options)
    const element = component.render()
    
    if (container && element) {
      container.appendChild(element)
    }
    
    return element
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
