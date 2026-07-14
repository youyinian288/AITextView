// ==================== Markdown-it 解析器 ====================
class MarkdownItParser {
  constructor(options = {}) {
    this.options = {
      html: true,        // 是否允许解析 Markdown 中的原始 HTML 标签
      linkify: true,     // 是否自动把类似 URL 的文本识别成超链接
      typographer: true, // 是否启用一些排版优化（例如智能引号）
      breaks: false,     // 是否将单个换行符视为 <br>（true 时更像聊天应用的换行）
      ...options
    }
    
    // 检查 markdown-it 是否可用
    if (typeof window.markdownit === 'undefined') {
      throw new Error('markdown-it library is not loaded')
    }
    
    // 创建 markdown-it 实例
    this.md = new window.markdownit(this.options)
    
    // 添加常用插件
    this.setupPlugins()
  }

  setupPlugins() {
    // 添加表格支持
    if (typeof window.markdownItTable !== 'undefined') {
      this.md.use(window.markdownItTable)
    }
    
    // 添加代码复制支持
    if (typeof window.markdownItCodeCopy !== 'undefined') {
      this.md.use(window.markdownItCodeCopy)
    }
    
    // 添加表情符号支持
    if (typeof window.markdownItEmoji !== 'undefined') {
      this.md.use(window.markdownItEmoji)
    }
    
    // 添加自定义数学公式支持（生成 token 而不是直接渲染 HTML）
    this.setupMathPlugin()
    
    // 添加上标和下标支持
    this.setupSubSupPlugin()
  }
  
  setupMathPlugin() {
    const md = this.md
    
    // 内联数学公式规则：$...$ 和 \(...\)
    // 注意：$$...$$ 应该作为块级数学处理，不在内联中处理
    const mathInline = (state, silent) => {
      const src = state.src
      let pos = state.pos
      
      // 检查是否是 $ 或 \( 开始
      if (src[pos] !== '$' && !(src[pos] === '\\' && src[pos + 1] === '(')) {
        return false
      }
      
      // 如果是 $$，跳过（应该由块级规则处理）
      if (src[pos] === '$' && src[pos + 1] === '$') {
        return false
      }
      
      let end = -1
      let delimiter = ''
      
      // 处理 $...$（单美元符号）
      if (src[pos] === '$') {
        delimiter = '$'
        pos += 1
        end = src.indexOf('$', pos)
        if (end === -1) return false
      }
      // 处理 \(...\)
      else if (src[pos] === '\\' && src[pos + 1] === '(') {
        delimiter = '\\('
        pos += 2
        end = src.indexOf('\\)', pos)
        if (end === -1) return false
      } else {
        return false
      }
      
      const content = src.slice(pos, end)
      
      if (!silent) {
        const token = state.push('math_inline', 'math', 0)
        token.content = content
        token.markup = delimiter
        token.raw = delimiter + content + (delimiter === '$' ? '$' : '\\)')
      }
      
      state.pos = end + (delimiter === '$' ? 1 : 2)
      return true
    }
    
    // 块级数学公式规则：$$...$$ 和 \[...\] 以及 ...$$（行尾 $$）
    const mathBlock = (state, startLine, endLine, silent) => {
      const src = state.src
      const startPos = state.bMarks[startLine] + state.tShift[startLine]
      const lineText = src.slice(startPos, state.eMarks[startLine])
      const trimmedLineText = lineText.trim()
      
      let openDelim = ''
      let closeDelim = ''
      let content = ''
      let nextLine = startLine
      let found = false
      
      // 情况1：行首有 $$（传统格式：$$...$$）
      if (trimmedLineText.startsWith('$$')) {
        openDelim = '$$'
        closeDelim = '$$'
        
        // 检查同一行是否有结束分隔符
        const endIndex = trimmedLineText.indexOf('$$', 2)
        if (endIndex !== -1 && endIndex > 2) {
          // 同一行开始和结束
          content = trimmedLineText.slice(2, endIndex)
          found = true
          nextLine = startLine
        } else {
          // 多行处理
          content = trimmedLineText.slice(2)
          
          for (nextLine = startLine + 1; nextLine < endLine; nextLine++) {
            const lineStart = state.bMarks[nextLine] + state.tShift[nextLine]
            const lineEnd = state.eMarks[nextLine]
            const currentLine = src.slice(lineStart, lineEnd).trim()
            
            if (currentLine.endsWith('$$')) {
              content += (content ? '\n' : '') + currentLine.slice(0, -2)
              found = true
              break
            } else if (currentLine === '$$') {
              found = true
              break
            }
            content += (content ? '\n' : '') + currentLine
          }
        }
      }
      // 情况2：行尾有 $$（格式：...$$）
      else if (trimmedLineText.endsWith('$$') && trimmedLineText.length > 2) {
        openDelim = ''
        closeDelim = '$$'
        content = trimmedLineText.slice(0, -2)
        found = true
        nextLine = startLine
      }
      // 情况3：行首有 \[ 或 [
      else if (trimmedLineText.startsWith('\\[') || trimmedLineText.startsWith('[')) {
        openDelim = trimmedLineText.startsWith('\\[') ? '\\[' : '['
        closeDelim = trimmedLineText.startsWith('\\[') ? '\\]' : ']'
        
        // 检查同一行是否有结束分隔符
        const endIndex = trimmedLineText.indexOf(closeDelim, openDelim.length)
        if (endIndex !== -1 && endIndex > openDelim.length) {
          content = trimmedLineText.slice(openDelim.length, endIndex)
          found = true
          nextLine = startLine
        } else {
          // 多行处理
          content = trimmedLineText.slice(openDelim.length)
          
          for (nextLine = startLine + 1; nextLine < endLine; nextLine++) {
            const lineStart = state.bMarks[nextLine] + state.tShift[nextLine]
            const lineEnd = state.eMarks[nextLine]
            const currentLine = src.slice(lineStart, lineEnd).trim()
            
            if (currentLine.endsWith(closeDelim)) {
              content += (content ? '\n' : '') + currentLine.slice(0, -closeDelim.length)
              found = true
              break
            } else if (currentLine === closeDelim) {
              found = true
              break
            }
            content += (content ? '\n' : '') + currentLine
          }
        }
      } else {
        return false
      }
      
      if (silent) return true
      
      const token = state.push('math_block', 'math', 0)
      token.content = content.trim()
      token.markup = openDelim === '$$' ? '$$' : openDelim ? (openDelim + closeDelim) : '$$'
      token.raw = openDelim + content + closeDelim
      token.block = true
      token.map = [startLine, nextLine + 1]
      token.loading = !found
      
      state.line = nextLine + 1
      return true
    }
    
    // 注册规则（在 escape 规则之前，这样数学公式中的反斜杠不会被转义）
    md.inline.ruler.before('escape', 'math_inline', mathInline)
    md.block.ruler.before('paragraph', 'math_block', mathBlock, {
      alt: ['paragraph', 'reference', 'blockquote', 'list']
    })
  }

  setupSubSupPlugin() {
    const md = this.md
    
    // 下标规则：~text~
    const subscript = (state, silent) => {
      const src = state.src
      const pos = state.pos
      
      if (src[pos] !== '~') {
        return false
      }
      
      // 检查是否不是转义的 ~
      if (pos > 0 && src[pos - 1] === '\\') {
        return false
      }
      
      // 查找结束的 ~
      let end = pos + 1
      while (end < src.length) {
        if (src[end] === '~' && src[end - 1] !== '\\') {
          break
        }
        end++
      }
      
      if (end >= src.length || src[end] !== '~') {
        return false
      }
      
      const content = src.slice(pos + 1, end)
      
      // 如果内容为空，不处理
      if (content.length === 0) {
        return false
      }
      
      if (!silent) {
        // 创建 sub_open token
        const openToken = state.push('sub_open', 'sub', 1)
        openToken.markup = '~'
        
        // 在 sub_open 和 sub_close 之间插入内容
        // 使用 inline token 包装内容，让内联解析器处理嵌套格式
        const inlineToken = state.push('inline', '', 0)
        inlineToken.content = content
        inlineToken.children = []
        // 手动解析内容以支持嵌套格式（如粗体、斜体等）
        const oldPos = state.pos
        const oldPosMax = state.posMax
        state.pos = pos + 1
        state.posMax = end
        md.inline.parse(content, md, state.env, inlineToken.children)
        state.pos = oldPos
        state.posMax = oldPosMax
        
        // 创建 sub_close token
        state.push('sub_close', 'sub', -1)
      }
      
      state.pos = end + 1
      return true
    }
    
    // 上标规则：^text^
    const superscript = (state, silent) => {
      const src = state.src
      const pos = state.pos
      
      if (src[pos] !== '^') {
        return false
      }
      
      // 检查是否不是转义的 ^
      if (pos > 0 && src[pos - 1] === '\\') {
        return false
      }
      
      // 查找结束的 ^
      let end = pos + 1
      while (end < src.length) {
        if (src[end] === '^' && src[end - 1] !== '\\') {
          break
        }
        end++
      }
      
      if (end >= src.length || src[end] !== '^') {
        return false
      }
      
      const content = src.slice(pos + 1, end)
      
      // 如果内容为空，不处理
      if (content.length === 0) {
        return false
      }
      
      if (!silent) {
        // 创建 sup_open token
        const openToken = state.push('sup_open', 'sup', 1)
        openToken.markup = '^'
        
        // 在 sup_open 和 sup_close 之间插入内容
        // 使用 inline token 包装内容，让内联解析器处理嵌套格式
        const inlineToken = state.push('inline', '', 0)
        inlineToken.content = content
        inlineToken.children = []
        // 手动解析内容以支持嵌套格式（如粗体、斜体等）
        const oldPos = state.pos
        const oldPosMax = state.posMax
        state.pos = pos + 1
        state.posMax = end
        md.inline.parse(content, md, state.env, inlineToken.children)
        state.pos = oldPos
        state.posMax = oldPosMax
        
        // 创建 sup_close token
        state.push('sup_close', 'sup', -1)
      }
      
      state.pos = end + 1
      return true
    }
    
    // 注册规则（在 escape 规则之前，这样上标下标中的内容不会被转义）
    md.inline.ruler.before('escape', 'subscript', subscript)
    md.inline.ruler.before('escape', 'superscript', superscript)
  }

  parse(markdown) {
    if (!markdown) return []
    
    try {
      // 使用 markdown-it 解析为 tokens
      const tokens = this.md.parse(markdown, {})
      
      // 将 tokens 转换为 AST
      return this.tokensToAST(tokens)
    } catch (error) {
      console.error('Markdown parsing error:', error)
      return []
    }
  }

  tokensToAST(tokens) {
    const ast = []
    let i = 0

    while (i < tokens.length) {
      const token = tokens[i]
      
      switch (token.type) {
        case 'heading_open':
          ast.push(this.parseHeading(tokens, i))
          i = this.findMatchingClose(tokens, i) + 1
          break
          
        case 'paragraph_open':
          ast.push(this.parseParagraph(tokens, i))
          i = this.findMatchingClose(tokens, i) + 1
          break
          
        case 'code_block':
        case 'fence':
          ast.push(this.parseCodeBlock(token))
          i++
          break
          
        case 'bullet_list_open':
        case 'ordered_list_open':
          const listResult = this.parseList(tokens, i)
          ast.push(listResult.node)
          i = listResult.nextIndex
          break
          
        case 'blockquote_open':
          const blockquoteResult = this.parseBlockquote(tokens, i)
          ast.push(blockquoteResult.node)
          i = blockquoteResult.nextIndex
          break
          
        case 'hr':
          ast.push({ type: 'horizontal_rule' })
          i++
          break
          
        case 'table_open':
          const tableResult = this.parseTable(tokens, i)
          ast.push(tableResult.node)
          i = tableResult.nextIndex
          break
        
        case 'math_block':
          ast.push(this.parseMathBlock(token))
          i++
          break
        
        case 'html_block':
          ast.push(this.parseHtmlBlock(token))
          i++
          break
        
        default:
          i++
      }
    }

    return ast
  }

  parseHeading(tokens, startIndex) {
    const openToken = tokens[startIndex]
    const level = parseInt(openToken.tag.slice(1))
    
    // 找到标题内容
    let content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== 'heading_close') {
      if (tokens[i].type === 'inline') {
        content = this.parseInlineTokens(tokens[i].children || [])
      }
      i++
    }
    
    return {
      type: 'heading',
      level: level,
      children: content
    }
  }

  parseParagraph(tokens, startIndex) {
    let content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== 'paragraph_close') {
      if (tokens[i].type === 'inline') {
        content = this.parseInlineTokens(tokens[i].children || [])
      }
      i++
    }
    
    return {
      type: 'paragraph',
      children: content
    }
  }

  parseCodeBlock(token) {
    const info = token.info || ''
    const language = info.trim().split(/\s+/)[0] || ''
    const code = token.content || ''
    
    return {
      type: 'code_block',
      language: language,
      value: code
    }
  }

  parseList(tokens, startIndex) {
    const openToken = tokens[startIndex]
    const ordered = openToken.type === 'ordered_list_open'
    const items = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== (ordered ? 'ordered_list_close' : 'bullet_list_close')) {
      if (tokens[i].type === 'list_item_open') {
        const itemResult = this.parseListItem(tokens, i)
        items.push(itemResult.node)
        i = itemResult.nextIndex
      } else {
        i++
      }
    }
    
    return {
      node: {
        type: 'list',
        ordered: ordered,
        children: items
      },
      nextIndex: i + 1
    }
  }

  parseListItem(tokens, startIndex) {
    let content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== 'list_item_close') {
      if (tokens[i].type === 'paragraph_open') {
        const paragraphResult = this.parseParagraph(tokens, i)
        content = content.concat(paragraphResult.children)
        i = this.findMatchingClose(tokens, i) + 1
      } else if (tokens[i].type === 'inline') {
        content = content.concat(this.parseInlineTokens(tokens[i].children || []))
        i++
      } else {
        i++
      }
    }
    
    // 检测 GFM 任务列表语法，如 "- [ ] item" 或 "- [x] item"
    let task = false
    let checked = false
    if (content.length > 0 && content[0].type === 'text') {
      const text = content[0].value || ''
      const match = text.match(/^\s*\[( |x|X)\]\s+/)
      if (match) {
        task = true
        checked = match[1].toLowerCase() === 'x'
        content[0].value = text.slice(match[0].length)
      }
    }
    
    return {
      node: {
        type: 'list_item',
        children: content,
        task: task,
        checked: checked
      },
      nextIndex: i + 1
    }
  }

  parseBlockquote(tokens, startIndex) {
    let content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== 'blockquote_close') {
      if (tokens[i].type === 'paragraph_open') {
        const paragraphResult = this.parseParagraph(tokens, i)
        content = content.concat(paragraphResult.children)
        i = this.findMatchingClose(tokens, i) + 1
      } else if (tokens[i].type === 'inline') {
        content = content.concat(this.parseInlineTokens(tokens[i].children || []))
        i++
      } else {
        i++
      }
    }
    
    return {
      node: {
        type: 'blockquote',
        children: content
      },
      nextIndex: i + 1
    }
  }

  parseTable(tokens, startIndex) {
    const headers = []
    const rows = []
    let i = startIndex + 1
    
    // 解析表头
    if (tokens[i] && tokens[i].type === 'thead_open') {
      i++ // thead_open
      if (tokens[i] && tokens[i].type === 'tr_open') {
        i++ // tr_open
        while (i < tokens.length && tokens[i].type !== 'tr_close') {
          if (tokens[i].type === 'th_open') {
            i++ // th_open
            if (tokens[i] && tokens[i].type === 'inline') {
              const headerContent = this.parseInlineTokens(tokens[i].children || [])
              headers.push(headerContent.map(node => node.value || '').join(''))
            }
            i++ // inline
            i++ // th_close
          } else {
            i++
          }
        }
        i++ // tr_close
      }
      i++ // thead_close
    }
    
    // 解析表体
    if (tokens[i] && tokens[i].type === 'tbody_open') {
      i++ // tbody_open
      while (i < tokens.length && tokens[i].type !== 'tbody_close') {
        if (tokens[i].type === 'tr_open') {
          const row = []
          i++ // tr_open
          while (i < tokens.length && tokens[i].type !== 'tr_close') {
            if (tokens[i].type === 'td_open') {
              i++ // td_open
              if (tokens[i] && tokens[i].type === 'inline') {
                const cellContent = this.parseInlineTokens(tokens[i].children || [])
                row.push(cellContent.map(node => node.value || '').join(''))
              }
              i++ // inline
              i++ // td_close
            } else {
              i++
            }
          }
          rows.push(row)
          i++ // tr_close
        } else {
          i++
        }
      }
      i++ // tbody_close
    }
    
    return {
      node: {
        type: 'table',
        headers: headers,
        rows: rows
      },
      nextIndex: i + 1
    }
  }
  
  // 轻量级处理 ** 和 ~~，用于改进流式场景下的渲染体验
  // 返回一个节点数组，如果不需要特殊处理则返回 null
  handleEmphasisAndStrikethroughInText(content) {
    if (!content) return null
    
    let result = []
    let changed = false
    let text = content
    
    // 先处理删除线：~~text~~ 或流式中的 mid-state
    const strikeIdx = text.indexOf('~~')
    if (strikeIdx !== -1) {
      const before = text.slice(0, strikeIdx)
      const rest = text.slice(strikeIdx)
      const re = /^~~([^~]*?)(~~|$)/
      const m = re.exec(rest)
      let inner = ''
      let after = ''
      if (m) {
        inner = m[1]
        after = rest.slice(m[0].length)
      } else {
        // 没有找到闭合的 ~~，将后面的内容都视为删除线内容
        inner = rest.slice(2)
        after = ''
      }

      if (before) {
        result.push({ type: 'text', value: before })
      }
      result.push({
        type: 'strikethrough',
        children: inner ? [{ type: 'text', value: inner }] : []
      })
      if (after) {
        result.push({ type: 'text', value: after })
      }

      changed = true
      text = ''
    }

    // 如果删除线没有覆盖全部内容或没有删除线，再尝试处理粗体 **
    if (!changed && text.indexOf('**') !== -1) {
      const openIdx = text.indexOf('**')
      const beforeText = openIdx > -1 ? text.slice(0, openIdx) : ''
      const rest = openIdx > -1 ? text.slice(openIdx) : text

      // 尝试匹配成对的 **...**
      const re = /^\*\*([\s\S]*?)\*\*(.*)$/
      const exec = re.exec(rest)
      let inner = ''
      let after = ''
      if (exec && typeof exec.index === 'number') {
        inner = exec[1]
        after = exec[2] || ''
      } else {
        // 找不到闭合的 **，视为流式中的 mid-state，将其后的内容都视为粗体
        inner = rest.slice(2)
        after = ''
      }

      if (beforeText) {
        result.push({ type: 'text', value: beforeText })
      }
      result.push({
        type: 'strong',
        children: inner ? [{ type: 'text', value: inner }] : []
      })
      if (after) {
        result.push({ type: 'text', value: after })
      }

      changed = true
      text = ''
    }

    if (!changed) return null
    return result
  }

  parseInlineTokens(tokens) {
    const nodes = []
    let pendingText = ''

    const flushPendingText = () => {
      if (!pendingText) return
      // 在合并后的文本上一次性解析 ** / ~~，支持跨 token 的中间态（例如 "**这是一段" + "文字**")
      const enhancedNodes = this.handleEmphasisAndStrikethroughInText(pendingText)
      if (enhancedNodes) {
        nodes.push(...enhancedNodes)
      } else {
        nodes.push({ type: 'text', value: pendingText })
      }
      pendingText = ''
    }

    for (let i = 0; i < tokens.length; i++) {
      const token = tokens[i]

      switch (token.type) {
        case 'text': {
          // 不立即解析，先合并连续的 text token 内容
          pendingText += token.content || ''
          break
        }

        case 'strong_open':
          flushPendingText()
          const strongContent = this.collectInlineContent(tokens, i, 'strong_close')
          nodes.push({
            type: 'strong',
            children: strongContent
          })
          i = this.findMatchingClose(tokens, i)
          break

        case 'em_open':
          flushPendingText()
          const emContent = this.collectInlineContent(tokens, i, 'em_close')
          nodes.push({
            type: 'emphasis',
            children: emContent
          })
          i = this.findMatchingClose(tokens, i)
          break

        case 's_open':
          flushPendingText()
          const sContent = this.collectInlineContent(tokens, i, 's_close')
          nodes.push({
            type: 'strikethrough',
            children: sContent
          })
          i = this.findMatchingClose(tokens, i)
          break

        case 'sub_open':
          flushPendingText()
          const subContent = this.collectInlineContent(tokens, i, 'sub_close')
          nodes.push({
            type: 'subscript',
            children: subContent
          })
          i = this.findMatchingClose(tokens, i)
          break

        case 'sup_open':
          flushPendingText()
          const supContent = this.collectInlineContent(tokens, i, 'sup_close')
          nodes.push({
            type: 'superscript',
            children: supContent
          })
          i = this.findMatchingClose(tokens, i)
          break

        case 'link_open':
          flushPendingText()
          const linkResult = this.parseLink(tokens, i)
          nodes.push(linkResult.node)
          i = linkResult.nextIndex
          break

        case 'image':
          flushPendingText()
          nodes.push({
            type: 'image',
            url: token.attrGet('src') || '',
            alt: token.attrGet('alt') || '',
            title: token.attrGet('title') || ''
          })
          break

        case 'math_inline':
          flushPendingText()
          nodes.push({
            type: 'math_inline',
            content: token.content || '',
            raw: token.raw || ''
          })
          break

        case 'html_inline':
          flushPendingText()
          nodes.push({
            type: 'html_inline',
            content: token.content || ''
          })
          break

        default:
          // 对于其他类型的 token，尝试解析为文本
          flushPendingText()
          if (token.content) {
            nodes.push({ type: 'text', value: token.content })
          }
      }
    }

    // 处理结尾仍然累积的纯文本
    flushPendingText()

    return nodes
  }

  parseLink(tokens, startIndex) {
    const openToken = tokens[startIndex]
    const url = openToken.attrGet('href') || ''
    const title = openToken.attrGet('title') || ''

    let content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== 'link_close') {
      if (tokens[i].type === 'text') {
        content.push({ type: 'text', value: tokens[i].content })
      } else if (tokens[i].type === 'inline') {
        content = content.concat(this.parseInlineTokens(tokens[i].children || []))
      }
      i++
    }
    
    return {
      node: {
        type: 'link',
        url: url,
        title: title,
        children: content
      },
      nextIndex: i + 1
    }
  }

  collectInlineContent(tokens, startIndex, closeType) {
    const content = []
    let i = startIndex + 1
    
    while (i < tokens.length && tokens[i].type !== closeType) {
      if (tokens[i].type === 'text') {
        content.push({ type: 'text', value: tokens[i].content })
      } else if (tokens[i].type === 'inline') {
        content.push(...this.parseInlineTokens(tokens[i].children || []))
      }
      i++
    }
    
    return content
  }

  parseMathBlock(token) {
    return {
      type: 'math_block',
      content: token.content || '',
      raw: token.raw || ''
    }
  }

  parseHtmlBlock(token) {
    return {
      type: 'html_block',
      content: token.content || ''
    }
  }

  findMatchingClose(tokens, startIndex) {
    const openToken = tokens[startIndex]
    const openType = openToken.type
    const closeType = openType.replace('_open', '_close')
    let level = 1
    let i = startIndex + 1
    
    while (i < tokens.length && level > 0) {
      if (tokens[i].type === openType) {
        level++
      } else if (tokens[i].type === closeType) {
        level--
      }
      i++
    }
    
    return i - 1
  }
}

