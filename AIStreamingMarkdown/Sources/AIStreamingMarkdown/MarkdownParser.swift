import Foundation
import Markdown

// MARK: - Parser

/// Parses Markdown text into `[MarkdownBlock]` using Apple's swift-markdown.
public struct MarkdownParser: Sendable {

    /// Parsing options.
    public struct Options: Sendable {
        /// Whether to treat newlines within paragraphs as soft breaks.
        public var softBreaksOnSingleNewline: Bool = true

        public init() {}
    }

    public let options: Options

    public init(options: Options = Options()) {
        self.options = options
    }

    /// Parse a Markdown string into an array of block-level elements.
    /// - Parameter markdown: Raw Markdown text (may be incomplete / mid-stream).
    /// - Returns: Parsed block array. Incomplete blocks land in the last element(s).
    public func parse(_ markdown: String) -> [MarkdownBlock] {
        // Pre-process math blocks: extract $$...$$ before swift-markdown sees them
        let (processed, mathPlaceholders) = extractMathBlocks(markdown)
        let document = Document(parsing: processed)
        var visitor = BlockVisitor(options: options, mathPlaceholders: mathPlaceholders)
        return visitor.visit(document)
    }

    // MARK: - Math Pre-processing

    /// Extracts `$$...$$` display math blocks and replaces them with HTML comments
    /// that swift-markdown will treat as inline HTML (preserving position).
    /// Returns the cleaned markdown and a dict mapping placeholder → math content.
    private func extractMathBlocks(_ markdown: String) -> (String, [String: String]) {
        var placeholders: [String: String] = [:]
        var result = markdown

        // Match $$ ... $$ (display math, may span lines)
        let pattern = "\\$\\$\\s*\\n?([\\s\\S]*?)\\s*\\$\\$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (markdown, [:])
        }

        let nsRange = NSRange(markdown.startIndex..<markdown.endIndex, in: markdown)
        let matches = regex.matches(in: markdown, options: [], range: nsRange)

        // Process in reverse to preserve string indices
        for (index, match) in matches.enumerated().reversed() {
            guard let contentRange = Range(match.range(at: 1), in: markdown) else { continue }
            let mathContent = String(markdown[contentRange])
            let placeholder = "<!--math\(index)-->"
            placeholders[placeholder] = mathContent

            guard let matchRange = Range(match.range(at: 0), in: result) else { continue }
            result.replaceSubrange(matchRange, with: "\n\n\(placeholder)\n\n")
        }

        return (result, placeholders)
    }
}

// MARK: - BlockVisitor

private struct BlockVisitor: MarkupVisitor {
    let options: MarkdownParser.Options
    let mathPlaceholders: [String: String]

    init(options: MarkdownParser.Options, mathPlaceholders: [String: String] = [:]) {
        self.options = options
        self.mathPlaceholders = mathPlaceholders
    }

    // MARK: - Top-level visit

    func visit(_ document: Document) -> [MarkdownBlock] {
        document.children.flatMap { visitBlock($0) }
    }

    // MARK: - Block dispatch

    mutating func visitBlock(_ markup: Markup) -> [MarkdownBlock] {
        switch markup {
        case let heading as Heading:
            return [.heading(level: heading.level, content: visitInlines(heading.children))]

        case let paragraph as Paragraph:
            // Check if this paragraph is a math placeholder
            if let mathBlock = extractMathPlaceholder(from: paragraph) {
                return [mathBlock]
            }
            let inlines = visitInlines(paragraph.children)
            // Standalone image: a paragraph containing only a single image → ImageCell
            if inlines.count == 1, case .image(let source, let alt) = inlines[0] {
                return [.image(source: source, alt: alt)]
            }
            return [.paragraph(content: inlines)]

        case let codeBlock as CodeBlock:
            let lang = codeBlock.language?.trimmingCharacters(in: .whitespaces)
            return [.codeBlock(language: lang, code: codeBlock.code)]

        case let blockquote as BlockQuote:
            let blocks = blockquote.blockChildren.flatMap { visitBlock($0) }
            return [.blockquote(content: blocks)]

        case let list as UnorderedList:
            let items = list.listItems.enumerated().map { (_, item) in
                visitListItem(item, ordered: false, index: 0)
            }
            return [.unorderedList(items: items)]

        case let list as OrderedList:
            let startIndex = list.startIndex
            let items = list.listItems.enumerated().map { (offset, item) in
                visitListItem(item, ordered: true, index: startIndex + offset)
            }
            return [.orderedList(start: startIndex, items: items)]

        case is ThematicBreak:
            return [.thematicBreak]

        case let table as Markdown.Table:
            return [visitTable(table)]

        case let image as Markdown.Image:
            let source = image.source ?? ""
            let alt = image.plainText
            return [.image(source: source, alt: alt)]

        default:
            // Fallback: treat unknown block types as paragraphs
            if markup.childCount > 0 {
                return [.paragraph(content: visitInlines(markup.children))]
            } else if !markup.plainText.isEmpty {
                return [.paragraph(content: [.text(markup.plainText)])]
            }
            return []
        }
    }

    // MARK: - Math Placeholder

    /// Checks if a Paragraph is actually a math placeholder (<!--mathN-->).
    /// If so, returns the corresponding `.mathBlock`.
    private func extractMathPlaceholder(from paragraph: Paragraph) -> MarkdownBlock? {
        let children = Array(paragraph.children)
        guard children.count == 1,
              let html = children[0] as? InlineHTML else {
            return nil
        }
        let raw = html.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let mathContent = mathPlaceholders[raw] else {
            return nil
        }
        return .mathBlock(content: mathContent.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: - List Items

    mutating func visitListItem(_ item: ListItem, ordered: Bool, index: Int) -> MarkdownListItem {
        let blocks = item.blockChildren.flatMap { visitBlock($0) }
        return MarkdownListItem(content: blocks.isEmpty ? [.paragraph(content: [.text(item.plainText)])] : blocks)
    }

    // MARK: - Table

    mutating func visitTable(_ table: Markdown.Table) -> MarkdownBlock {
        let headers: [[MarkdownInline]] = table.head.cells.map { cell in
            visitInlines(cell.children)
        }

        let rows: [[[MarkdownInline]]] = table.body.rows.map { row in
            row.cells.map { cell in
                visitInlines(cell.children)
            }
        }

        return .table(headers: headers, rows: rows)
    }

    // MARK: - Inline Content

    mutating func visitInlines(_ children: MarkupChildren) -> [MarkdownInline] {
        var result: [MarkdownInline] = []

        for child in children {
            let inlines = visitInline(child)
            result.append(contentsOf: inlines)
        }

        // Collapse adjacent text nodes and handle soft breaks
        return collapseInlines(result)
    }

    mutating func visitInline(_ markup: Markup) -> [MarkdownInline] {
        switch markup {
        case let text as Markdown.Text:
            return [.text(text.string)]

        case let strong as Strong:
            let content = visitInlines(strong.children)
            return [.strong(content)]

        case let emphasis as Emphasis:
            let content = visitInlines(emphasis.children)
            return [.emphasis(content)]

        case let strikethrough as Strikethrough:
            let content = visitInlines(strikethrough.children)
            return [.strikethrough(content)]

        case let inlineCode as InlineCode:
            return [.inlineCode(inlineCode.code)]

        case let link as Markdown.Link:
            let dest = link.destination ?? ""
            let content = visitInlines(link.children)
            let display = content.isEmpty ? [.text(dest)] : content
            return [.link(destination: dest, content: display)]

        case let image as Markdown.Image:
            let source = image.source ?? ""
            let alt = image.plainText
            return [.image(source: source, alt: alt.isEmpty ? "" : alt)]

        case let softBreak as SoftBreak:
            return [.softBreak]

        case let lineBreak as LineBreak:
            return [.lineBreak]

        case let inlineHTML as InlineHTML:
            return [.text(inlineHTML.plainText)]

        case let symbol as SymbolLink:
            return [.text(symbol.plainText)]

        default:
            if markup.childCount > 0 {
                return visitInlines(markup.children)
            } else if !markup.plainText.isEmpty {
                return [.text(markup.plainText)]
            }
            return []
        }
    }

    // MARK: - Collapse

    /// Merge adjacent text nodes and handle soft breaks for cleaner rendering.
    private func collapseInlines(_ inlines: [MarkdownInline]) -> [MarkdownInline] {
        var result: [MarkdownInline] = []

        for inline in inlines {
            guard let last = result.last else {
                result.append(inline)
                continue
            }

            switch (last, inline) {
            case (.text(let a), .text(let b)):
                // Merge adjacent text
                result[result.count - 1] = .text(a + b)
            case (.text(let a), .softBreak):
                // Soft break within paragraph: join with space
                if options.softBreaksOnSingleNewline {
                    result[result.count - 1] = .text(a + " ")
                } else {
                    result[result.count - 1] = .text(a + "\n")
                }
            default:
                result.append(inline)
            }
        }

        return result
    }
}
