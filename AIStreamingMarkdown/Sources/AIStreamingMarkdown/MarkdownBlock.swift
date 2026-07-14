import Foundation

// MARK: - Inline Content Model

/// Represents inline-level Markdown elements.
/// Recursive to support nesting like **bold *and italic*** or [linked **text**](url).
public indirect enum MarkdownInline: Hashable, Sendable {
    case text(String)
    case strong([MarkdownInline])
    case emphasis([MarkdownInline])
    case strikethrough([MarkdownInline])
    case inlineCode(String)
    case link(destination: String, content: [MarkdownInline])
    case image(source: String, alt: String)
    case softBreak
    case lineBreak
}

// MARK: - Block Model

/// Represents a single block-level Markdown element.
/// Conforms to `Hashable` to support `UICollectionViewDiffableDataSource`.
public enum MarkdownBlock: Hashable, Sendable {
    case heading(level: Int, content: [MarkdownInline])
    case paragraph(content: [MarkdownInline])
    case codeBlock(language: String?, code: String)
    case blockquote(content: [MarkdownBlock])
    case unorderedList(items: [MarkdownListItem])
    case orderedList(start: Int, items: [MarkdownListItem])
    case thematicBreak
    case table(headers: [[MarkdownInline]], rows: [[[MarkdownInline]]])
    case image(source: String, alt: String)
    case mathBlock(content: String)
}

/// A single list item, which may contain nested blocks.
public struct MarkdownListItem: Hashable, Sendable {
    public let content: [MarkdownBlock]
    public let indentation: Int

    public init(content: [MarkdownBlock], indentation: Int = 0) {
        self.content = content
        self.indentation = indentation
    }
}

// MARK: - Stable ID

extension MarkdownBlock {
    /// Returns a stable identifier for this block.
    /// Used by `UICollectionViewDiffableDataSource` for item identity.
    /// The ID changes when the content changes (for volatile blocks) but
    /// remains stable for blocks whose content hasn't changed.
    public var stableID: String {
        switch self {
        case .heading(let level, let content):
            return "h\(level)-\(content.hashValue)"
        case .paragraph(let content):
            return "p-\(content.hashValue)"
        case .codeBlock(let language, let code):
            return "code-\(language ?? "")-\(code.hashValue)"
        case .blockquote(let content):
            return "bq-\(content.hashValue)"
        case .unorderedList(let items):
            return "ul-\(items.hashValue)"
        case .orderedList(let start, let items):
            return "ol\(start)-\(items.hashValue)"
        case .thematicBreak:
            return "hr"
        case .table(let headers, let rows):
            return "tbl-\(headers.hashValue)-\(rows.hashValue)"
        case .image(let source, let alt):
            return "img-\(source.hashValue)-\(alt.hashValue)"
        case .mathBlock(let content):
            return "math-\(content.hashValue)"
        }
    }
}

// MARK: - Debug Description

extension MarkdownBlock: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .heading(let level, let content):
            return "H\(level)(\(inlinePreview(content)))"
        case .paragraph(let content):
            return "P(\(inlinePreview(content)))"
        case .codeBlock(let lang, let code):
            return "Code(\(lang ?? "nil"), \(code.count) chars)"
        case .blockquote(let blocks):
            return "Quote(\(blocks.count) blocks)"
        case .unorderedList(let items):
            return "UL(\(items.count) items)"
        case .orderedList(let start, let items):
            return "OL(start:\(start), \(items.count) items)"
        case .thematicBreak:
            return "HR"
        case .table(let headers, let rows):
            return "Table(\(headers.count) cols × \(rows.count) rows)"
        case .image(let source, _):
            return "Image(\(source.prefix(50)))"
        case .mathBlock(let content):
            return "Math(\(content.prefix(30)))"
        }
    }

    private func inlinePreview(_ inlines: [MarkdownInline]) -> String {
        let text = inlines.compactMap { inline -> String? in
            if case .text(let t) = inline { return t }
            return nil
        }.joined()
        let preview = text.prefix(50).replacingOccurrences(of: "\n", with: "\\n")
        return preview.isEmpty ? "…" : preview
    }
}
