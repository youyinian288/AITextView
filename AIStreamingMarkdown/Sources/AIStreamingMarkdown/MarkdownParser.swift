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
    public func parse(_ markdown: String) -> [MarkdownBlock] {
        let (processed, mathPlaceholders) = extractMathBlocks(markdown)
        let document = Document(parsing: processed)
        var visitor = BlockVisitor(options: options, mathPlaceholders: mathPlaceholders)
        return visitor.visitDocument(document)
    }

    // MARK: - Math Pre-processing

    private func extractMathBlocks(_ markdown: String) -> (String, [String: String]) {
        var placeholders: [String: String] = [:]
        var result = markdown

        let pattern = "\\$\\$\\s*\\n?([\\s\\S]*?)\\s*\\$\\$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (markdown, [:])
        }

        let nsRange = NSRange(markdown.startIndex..<markdown.endIndex, in: markdown)
        let matches = regex.matches(in: markdown, options: [], range: nsRange)

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

private struct BlockVisitor {
    let options: MarkdownParser.Options
    let mathPlaceholders: [String: String]

    init(options: MarkdownParser.Options, mathPlaceholders: [String: String] = [:]) {
        self.options = options
        self.mathPlaceholders = mathPlaceholders
    }

    // MARK: - Document

    mutating func visitDocument(_ document: Document) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        for child in document.children {
            blocks.append(contentsOf: visitBlock(child))
        }
        return blocks
    }

    // MARK: - Block dispatch

    mutating func visitBlock(_ markup: some Markup) -> [MarkdownBlock] {
        if let heading = markup as? Heading {
            return [.heading(level: heading.level, content: visitInlineChildren(heading.children))]
        }

        if let paragraph = markup as? Paragraph {
            if let mathBlock = extractMathPlaceholder(from: paragraph) {
                return [mathBlock]
            }
            let inlines = visitInlineChildren(paragraph.children)
            if inlines.count == 1, case .image(let source, let alt) = inlines[0] {
                return [.image(source: source, alt: alt)]
            }
            return [.paragraph(content: inlines)]
        }

        if let codeBlock = markup as? CodeBlock {
            let lang = codeBlock.language?.trimmingCharacters(in: .whitespaces)
            return [.codeBlock(language: lang, code: codeBlock.code)]
        }

        if let blockquote = markup as? BlockQuote {
            var nested: [MarkdownBlock] = []
            for child in blockquote.blockChildren {
                nested.append(contentsOf: visitBlock(child))
            }
            return [.blockquote(content: nested)]
        }

        if let list = markup as? UnorderedList {
            let items = Array(list.listItems.enumerated()).map { (_, item) in
                visitListItem(item, ordered: false, index: 0)
            }
            return [.unorderedList(items: items)]
        }

        if let list = markup as? OrderedList {
            let start = Int(list.startIndex)
            let items = Array(list.listItems.enumerated()).map { (offset, item) in
                visitListItem(item, ordered: true, index: start + offset)
            }
            return [.orderedList(start: start, items: items)]
        }

        if markup is ThematicBreak {
            return [.thematicBreak]
        }

        if let table = markup as? Markdown.Table {
            return [visitTable(table)]
        }

        if let image = markup as? Markdown.Image {
            let source = image.source ?? ""
            return [.image(source: source, alt: image.plainText)]
        }

        // Fallback: unknown block → inspect children
        let children = Array(markup.children)
        if !children.isEmpty {
            guard let firstChild = children.first else { return [] }
            // Try to treat children as inline content for paragraph
            var allInlines: [MarkdownInline] = []
            for child in children {
                allInlines.append(contentsOf: visitInline(child))
            }
            if !allInlines.isEmpty {
                // Filter out empty text nodes
                let meaningful = allInlines.filter { inline in
                    if case .text(let t) = inline { return !t.isEmpty }
                    return true
                }
                if !meaningful.isEmpty {
                    return [.paragraph(content: collapseInlines(meaningful))]
                }
            }
        }

        return []
    }

    // MARK: - Math Placeholder

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
        var blocks: [MarkdownBlock] = []
        for child in item.blockChildren {
            blocks.append(contentsOf: visitBlock(child))
        }
        if blocks.isEmpty {
            let text = extractPlainText(from: item)
            if !text.isEmpty {
                blocks = [.paragraph(content: [.text(text)])]
            }
        }
        return MarkdownListItem(content: blocks)
    }

    private func extractPlainText(from markup: some Markup) -> String {
        var result = ""
        for child in markup.children {
            if let text = child as? Markdown.Text {
                result += text.string
            } else if child.childCount > 0 {
                result += extractPlainText(from: child)
            }
        }
        return result
    }

    // MARK: - Table

    mutating func visitTable(_ table: Markdown.Table) -> MarkdownBlock {
        let headers: [[MarkdownInline]] = table.head.cells.map { cell in
            visitInlineChildren(cell.children)
        }

        let rows: [[[MarkdownInline]]] = table.body.rows.map { row in
            row.cells.map { cell in
                visitInlineChildren(cell.children)
            }
        }

        return .table(headers: headers, rows: rows)
    }

    // MARK: - Inline Content

    mutating func visitInlineChildren(_ children: some Sequence<any Markup>) -> [MarkdownInline] {
        var result: [MarkdownInline] = []
        for child in children {
            result.append(contentsOf: visitInline(child))
        }
        return collapseInlines(result)
    }

    mutating func visitInline(_ markup: some Markup) -> [MarkdownInline] {
        if let text = markup as? Markdown.Text {
            return [.text(text.string)]
        }

        if let strong = markup as? Strong {
            return [.strong(visitInlineChildren(strong.children))]
        }

        if let emphasis = markup as? Emphasis {
            return [.emphasis(visitInlineChildren(emphasis.children))]
        }

        if let strikethrough = markup as? Strikethrough {
            return [.strikethrough(visitInlineChildren(strikethrough.children))]
        }

        if let inlineCode = markup as? InlineCode {
            return [.inlineCode(inlineCode.code)]
        }

        if let link = markup as? Markdown.Link {
            let dest = link.destination ?? ""
            let content = visitInlineChildren(link.children)
            let display = content.isEmpty ? [.text(dest)] : content
            return [.link(destination: dest, content: display)]
        }

        if let image = markup as? Markdown.Image {
            let source = image.source ?? ""
            let alt = image.plainText
            return [.image(source: source, alt: alt)]
        }

        if markup is SoftBreak {
            return [.softBreak]
        }

        if markup is LineBreak {
            return [.lineBreak]
        }

        if let inlineHTML = markup as? InlineHTML {
            return [.text(inlineHTML.plainText)]
        }

        if let symbol = markup as? SymbolLink {
            return [.text(symbol.plainText ?? "")]
        }

        // Fallback: children or plain text
        let children = Array(markup.children)
        if !children.isEmpty {
            return visitInlineChildren(children)
        }
        let pt = extractPlainText(from: markup)
        if !pt.isEmpty {
            return [.text(pt)]
        }
        return []
    }

    // MARK: - Collapse

    private func collapseInlines(_ inlines: [MarkdownInline]) -> [MarkdownInline] {
        var result: [MarkdownInline] = []

        for inline in inlines {
            guard let last = result.last else {
                result.append(inline)
                continue
            }

            switch (last, inline) {
            case (.text(let a), .text(let b)):
                result[result.count - 1] = .text(a + b)
            case (.text(let a), .softBreak):
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
