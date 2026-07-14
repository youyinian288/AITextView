# 渲染转换流程示例

本文档通过具体示例展示 Markdown 文本到 DOM 元素的完整转换过程。

## 示例 1: 简单段落

### 阶段 1: Markdown 文本
```markdown
这是一个**粗体**文本示例。
```

### 阶段 2: Token 序列（markdown-it 输出）

```javascript
[
  // 段落开始
  {
    type: 'paragraph_open',
    tag: 'p',
    nesting: 1,
    attrs: null,
    map: [0, 1],
    level: 0
  },
  
  // 内联内容
  {
    type: 'inline',
    tag: '',
    nesting: 0,
    content: '这是一个**粗体**文本示例。',
    map: [0, 1],
    level: 1,
    children: [
      { type: 'text', content: '这是一个', level: 0 },
      { type: 'strong_open', tag: 'strong', nesting: 1, level: 0 },
      { type: 'text', content: '粗体', level: 0 },
      { type: 'strong_close', tag: 'strong', nesting: -1, level: 0 },
      { type: 'text', content: '文本示例。', level: 0 }
    ]
  },
  
  // 段落结束
  {
    type: 'paragraph_close',
    tag: 'p',
    nesting: -1,
    level: 0
  }
]
```

### 阶段 3: AST 树（MarkdownItParser 输出）

```javascript
[
  {
    type: 'paragraph',
    children: [
      { type: 'text', value: '这是一个' },
      {
        type: 'strong',
        children: [
          { type: 'text', value: '粗体' }
        ]
      },
      { type: 'text', value: '文本示例。' }
    ]
  }
]
```

**转换过程**:
1. `parseParagraph()` 识别到 `paragraph_open` token
2. 提取 `inline` token 中的 `children`
3. `parseInlineTokens()` 遍历内联 tokens:
   - `text` token → `{ type: 'text', value: '这是一个' }`
   - `strong_open` + `strong_close` → `{ type: 'strong', children: [...] }`
   - 递归解析 `strong` 内的 `text` token → `{ type: 'text', value: '粗体' }`
   - `text` token → `{ type: 'text', value: '文本示例。' }`

### 阶段 4: 组件渲染（PureJSMarkdownRenderer）

**组件映射**:
```javascript
// renderNode() 根据 AST 节点类型选择组件
paragraph → ParagraphComponent
text → TextComponent
strong → StrongComponent
```

**渲染流程**:
```javascript
// 1. 渲染 paragraph 节点
new ParagraphComponent({
  type: 'paragraph',
  children: [...]
}).render()
  ↓
// 2. ParagraphComponent.render() 递归渲染子节点
this.renderChildren() 
  ↓
// 3. 渲染 text 节点
new TextComponent({ type: 'text', value: '这是一个' }).render()
  ↓
// 4. 渲染 strong 节点
new StrongComponent({
  type: 'strong',
  children: [{ type: 'text', value: '粗体' }]
}).render()
  ↓
// 5. 递归渲染 strong 内的 text
new TextComponent({ type: 'text', value: '粗体' }).render()
```

### 阶段 5: DOM 元素（最终输出）

```html
<p class="paragraph-node">
  <span class="text-node">这是一个</span>
  <strong class="strong-node">
    <span class="text-node">粗体</span>
  </strong>
  <span class="text-node">文本示例。</span>
</p>
```

**DOM 结构树**:
```
<p class="paragraph-node">
  ├── <span class="text-node">这是一个</span>
  ├── <strong class="strong-node">
  │     └── <span class="text-node">粗体</span>
  └── <span class="text-node">文本示例。</span>
</p>
```

---

## 示例 2: 标题 + 段落 + 代码块

### 阶段 1: Markdown 文本
```markdown
# Hello World

这是一个包含 `行内代码` 的段落。

```javascript
function hello() {
  console.log("Hello, World!");
}
```
```

### 阶段 2: Token 序列

```javascript
[
  // 标题
  { type: 'heading_open', tag: 'h1', nesting: 1, level: 0 },
  {
    type: 'inline',
    content: 'Hello World',
    children: [
      { type: 'text', content: 'Hello World' }
    ]
  },
  { type: 'heading_close', tag: 'h1', nesting: -1, level: 0 },
  
  // 段落
  { type: 'paragraph_open', tag: 'p', nesting: 1, level: 0 },
  {
    type: 'inline',
    content: '这是一个包含 `行内代码` 的段落。',
    children: [
      { type: 'text', content: '这是一个包含 ' },
      { type: 'code_inline', content: '行内代码', tag: 'code', nesting: 0 },
      { type: 'text', content: ' 的段落。' }
    ]
  },
  { type: 'paragraph_close', tag: 'p', nesting: -1, level: 0 },
  
  // 代码块
  {
    type: 'fence',
    tag: 'code',
    info: 'javascript',
    content: 'function hello() {\n  console.log("Hello, World!");\n}',
    map: [4, 7]
  }
]
```

### 阶段 3: AST 树

```javascript
[
  {
    type: 'heading',
    level: 1,
    children: [
      { type: 'text', value: 'Hello World' }
    ]
  },
  {
    type: 'paragraph',
    children: [
      { type: 'text', value: '这是一个包含 ' },
      { type: 'code', value: '行内代码' },
      { type: 'text', value: ' 的段落。' }
    ]
  },
  {
    type: 'code_block',
    language: 'javascript',
    value: 'function hello() {\n  console.log("Hello, World!");\n}'
  }
]
```

### 阶段 4: 组件渲染

```javascript
// 1. HeadingComponent.render()
new HeadingComponent({
  type: 'heading',
  level: 1,
  children: [{ type: 'text', value: 'Hello World' }]
}).render()
  ↓ 创建 <h1> 元素
  ↓ 渲染子节点 TextComponent

// 2. ParagraphComponent.render()
new ParagraphComponent({
  type: 'paragraph',
  children: [
    { type: 'text', value: '这是一个包含 ' },
    { type: 'code', value: '行内代码' },
    { type: 'text', value: ' 的段落。' }
  ]
}).render()
  ↓ 创建 <p> 元素
  ↓ 渲染子节点: TextComponent, InlineCodeComponent, TextComponent

// 3. CodeBlockComponent.render()
new CodeBlockComponent({
  type: 'code_block',
  language: 'javascript',
  value: 'function hello() {...}'
}).render()
  ↓ 创建 <div class="code-block-container">
  ↓ 添加语言标签
  ↓ 创建 <pre><code> 元素
  ↓ 添加复制按钮
```

### 阶段 5: DOM 元素

```html
<h1 class="heading-node heading-1" id="hello-world">
  <span class="text-node">Hello World</span>
</h1>

<p class="paragraph-node">
  <span class="text-node">这是一个包含 </span>
  <code class="code-node">行内代码</code>
  <span class="text-node"> 的段落。</span>
</p>

<div class="code-block-container">
  <div class="code-block-language">javascript</div>
  <pre class="code-block-pre">
    <code class="language-javascript">function hello() {
  console.log("Hello, World!");
}</code>
  </pre>
  <button class="code-block-copy">复制</button>
</div>
```

---

## 示例 3: 列表 + 嵌套格式

### 阶段 1: Markdown 文本
```markdown
- 第一项包含 **粗体** 和 *斜体*
- 第二项包含 [链接](https://example.com)
- 第三项包含 `代码`
```

### 阶段 2: Token 序列（部分）

```javascript
[
  { type: 'bullet_list_open', tag: 'ul', nesting: 1, level: 0 },
  
  // 第一项
  { type: 'list_item_open', tag: 'li', nesting: 1, level: 1 },
  {
    type: 'inline',
    content: '第一项包含 **粗体** 和 *斜体*',
    children: [
      { type: 'text', content: '第一项包含 ' },
      { type: 'strong_open', tag: 'strong', nesting: 1 },
      { type: 'text', content: '粗体' },
      { type: 'strong_close', tag: 'strong', nesting: -1 },
      { type: 'text', content: ' 和 ' },
      { type: 'em_open', tag: 'em', nesting: 1 },
      { type: 'text', content: '斜体' },
      { type: 'em_close', tag: 'em', nesting: -1 }
    ]
  },
  { type: 'list_item_close', tag: 'li', nesting: -1 },
  
  // 第二项
  { type: 'list_item_open', tag: 'li', nesting: 1, level: 1 },
  {
    type: 'inline',
    content: '第二项包含 [链接](https://example.com)',
    children: [
      { type: 'text', content: '第二项包含 ' },
      { type: 'link_open', tag: 'a', attrs: [['href', 'https://example.com']], nesting: 1 },
      { type: 'text', content: '链接' },
      { type: 'link_close', tag: 'a', nesting: -1 }
    ]
  },
  { type: 'list_item_close', tag: 'li', nesting: -1 },
  
  // 第三项...
  { type: 'list_item_open', tag: 'li', nesting: 1, level: 1 },
  // ...
  { type: 'list_item_close', tag: 'li', nesting: -1 },
  
  { type: 'bullet_list_close', tag: 'ul', nesting: -1, level: 0 }
]
```

### 阶段 3: AST 树

```javascript
[
  {
    type: 'list',
    ordered: false,
    children: [
      {
        type: 'list_item',
        children: [
          {
            type: 'paragraph',
            children: [
              { type: 'text', value: '第一项包含 ' },
              {
                type: 'strong',
                children: [
                  { type: 'text', value: '粗体' }
                ]
              },
              { type: 'text', value: ' 和 ' },
              {
                type: 'emphasis',
                children: [
                  { type: 'text', value: '斜体' }
                ]
              }
            ]
          }
        ]
      },
      {
        type: 'list_item',
        children: [
          {
            type: 'paragraph',
            children: [
              { type: 'text', value: '第二项包含 ' },
              {
                type: 'link',
                url: 'https://example.com',
                children: [
                  { type: 'text', value: '链接' }
                ]
              }
            ]
          }
        ]
      },
      {
        type: 'list_item',
        children: [
          {
            type: 'paragraph',
            children: [
              { type: 'text', value: '第三项包含 ' },
              { type: 'code', value: '代码' }
            ]
          }
        ]
      }
    ]
  }
]
```

### 阶段 4: 组件渲染流程

```javascript
// 1. ListComponent.render()
new ListComponent({
  type: 'list',
  ordered: false,
  children: [/* 3个 list_item */]
}).render()
  ↓ 创建 <ul> 元素
  ↓ 遍历每个 list_item，创建 ListItemComponent

// 2. ListItemComponent.render()
new ListItemComponent({
  type: 'list_item',
  children: [{ type: 'paragraph', ... }]
}).render()
  ↓ 创建 <li> 元素
  ↓ 递归渲染子节点（ParagraphComponent）

// 3. ParagraphComponent.render()
new ParagraphComponent({
  type: 'paragraph',
  children: [
    { type: 'text', value: '第一项包含 ' },
    { type: 'strong', children: [...] },
    // ...
  ]
}).render()
  ↓ 创建 <p> 元素（列表项中可能不创建，视实现而定）
  ↓ 渲染子节点: TextComponent, StrongComponent, EmphasisComponent
```

### 阶段 5: DOM 元素

```html
<ul class="list-node">
  <li class="list-item-node">
    <p class="paragraph-node">
      <span class="text-node">第一项包含 </span>
      <strong class="strong-node">
        <span class="text-node">粗体</span>
      </strong>
      <span class="text-node"> 和 </span>
      <em class="emphasis-node">
        <span class="text-node">斜体</span>
      </em>
    </p>
  </li>
  <li class="list-item-node">
    <p class="paragraph-node">
      <span class="text-node">第二项包含 </span>
      <a href="https://example.com" class="link-node">
        <span class="text-node">链接</span>
      </a>
    </p>
  </li>
  <li class="list-item-node">
    <p class="paragraph-node">
      <span class="text-node">第三项包含 </span>
      <code class="code-node">代码</code>
    </p>
  </li>
</ul>
```

---

## 示例 4: 数学公式

### 阶段 1: Markdown 文本
```markdown
这是一个行内公式 $E = mc^2$ 和块级公式：

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

### 阶段 2: Token 序列

```javascript
[
  // 段落
  { type: 'paragraph_open', tag: 'p', nesting: 1 },
  {
    type: 'inline',
    content: '这是一个行内公式 $E = mc^2$ 和块级公式：',
    children: [
      { type: 'text', content: '这是一个行内公式 ' },
      { 
        type: 'math_inline', 
        content: 'E = mc^2',
        markup: '$',
        raw: '$E = mc^2$'
      },
      { type: 'text', content: ' 和块级公式：' }
    ]
  },
  { type: 'paragraph_close', tag: 'p', nesting: -1 },
  
  // 块级数学公式
  {
    type: 'math_block',
    content: '\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}',
    markup: '$$',
    raw: '$$\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}$$',
    map: [2, 4]
  }
]
```

### 阶段 3: AST 树

```javascript
[
  {
    type: 'paragraph',
    children: [
      { type: 'text', value: '这是一个行内公式 ' },
      {
        type: 'math_inline',
        content: 'E = mc^2',
        raw: '$E = mc^2$'
      },
      { type: 'text', value: ' 和块级公式：' }
    ]
  },
  {
    type: 'math_block',
    content: '\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}',
    raw: '$$\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}$$'
  }
]
```

### 阶段 4: 组件渲染

```javascript
// 1. MathInlineComponent.render()
new MathInlineComponent({
  type: 'math_inline',
  content: 'E = mc^2'
}).render()
  ↓ 创建 <span class="math-inline-node">
  ↓ 调用 window.katex.render() 渲染公式

// 2. MathBlockComponent.render()
new MathBlockComponent({
  type: 'math_block',
  content: '\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}'
}).render()
  ↓ 创建 <div class="math-block-node">
  ↓ 调用 window.katex.render() 渲染公式（displayMode: true）
```

### 阶段 5: DOM 元素

```html
<p class="paragraph-node">
  <span class="text-node">这是一个行内公式 </span>
  <span class="math-inline-node">
    <!-- KaTeX 渲染结果 -->
    <span class="katex">
      <span class="katex-mathml">...</span>
      <span class="katex-html">E = mc<sup>2</sup></span>
    </span>
  </span>
  <span class="text-node"> 和块级公式：</span>
</p>

<div class="math-block-node">
  <!-- KaTeX 渲染结果 -->
  <span class="katex-display">
    <span class="katex">
      <span class="katex-mathml">...</span>
      <span class="katex-html">
        <span class="strut">...</span>
        <span class="mop op-symbol">∫</span>
        <!-- ... 更多 KaTeX 生成的元素 ... -->
      </span>
    </span>
  </span>
</div>
```

---

## 转换映射表

| Markdown | Token 类型 | AST 类型 | 组件类 | DOM 标签 |
|----------|-----------|----------|--------|---------|
| `# 标题` | `heading_open` + `inline` + `heading_close` | `heading` | `HeadingComponent` | `<h1>` |
| `段落` | `paragraph_open` + `inline` + `paragraph_close` | `paragraph` | `ParagraphComponent` | `<p>` |
| `**粗体**` | `strong_open` + `text` + `strong_close` | `strong` | `StrongComponent` | `<strong>` |
| `*斜体*` | `em_open` + `text` + `em_close` | `emphasis` | `EmphasisComponent` | `<em>` |
| `` `代码` `` | `code_inline` | `code` | `InlineCodeComponent` | `<code>` |
| ```代码块``` | `fence` | `code_block` | `CodeBlockComponent` | `<pre><code>` |
| `[链接](url)` | `link_open` + `text` + `link_close` | `link` | `LinkComponent` | `<a>` |
| `- 列表` | `bullet_list_open` + `list_item` + ... | `list` | `ListComponent` | `<ul><li>` |
| `> 引用` | `blockquote_open` + ... | `blockquote` | `BlockquoteComponent` | `<blockquote>` |
| `$公式$` | `math_inline` | `math_inline` | `MathInlineComponent` | `<span>` (KaTeX) |
| `$$公式$$` | `math_block` | `math_block` | `MathBlockComponent` | `<div>` (KaTeX) |

---

## 关键转换函数

### Token → AST

```javascript
// parseParagraph()
tokensToAST() 
  → parseParagraph(tokens, i)
    → parseInlineTokens(inlineToken.children)
      → 遍历内联 tokens，转换为 AST 节点
```

### AST → DOM

```javascript
// renderAST()
renderAST(ast, container)
  → renderNode(node, container)  // 遍历每个 AST 节点
    → getNodeComponent(node.type)  // 根据类型获取组件类
      → new Component(node).render()  // 实例化并渲染
        → createElement(tag, attrs, children)  // 创建 DOM 元素
```

### 增量渲染

```javascript
// renderIncremental()
renderIncremental(newAST, container)
  → diffAST(oldAST, newAST)  // 比较 AST
    → { modified: [...], added: [...], removed: [...] }
      → 更新/添加/删除对应的 DOM 元素
```

---

## 总结

整个转换流程遵循单一职责原则：

1. **markdown-it**: 纯文本 → Token 序列（词法/语法分析）
2. **MarkdownItParser**: Token 序列 → AST 树（结构化）
3. **PureJSMarkdownRenderer**: AST 树 → DOM 元素（渲染）
4. **Components**: 具体节点的渲染实现（组件化）

每个阶段都有清晰的输入输出，便于测试、调试和扩展。





