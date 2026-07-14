import XCTest
@testable import AIStreamingMarkdown

final class MarkdownParserTests: XCTestCase {

    let parser = MarkdownParser()

    // MARK: - Headings

    func testHeadingH1() {
        let blocks = parser.parse("# Hello World")
        XCTAssertEqual(blocks.count, 1)
        guard case .heading(let level, let content) = blocks[0] else {
            XCTFail("Expected heading, got \(blocks[0])")
            return
        }
        XCTAssertEqual(level, 1)
        XCTAssertTrue(containsText(content, "Hello World"))
    }

    func testHeadingH3() {
        let blocks = parser.parse("### Section")
        guard case .heading(let level, _) = blocks[0] else {
            XCTFail("Expected heading")
            return
        }
        XCTAssertEqual(level, 3)
    }

    // MARK: - Paragraphs

    func testSingleParagraph() {
        let blocks = parser.parse("This is a simple paragraph.")
        XCTAssertEqual(blocks.count, 1)
        guard case .paragraph = blocks[0] else {
            XCTFail("Expected paragraph, got \(blocks[0])")
            return
        }
    }

    func testMultipleParagraphs() {
        let markdown = """
        First paragraph.

        Second paragraph.
        """
        let blocks = parser.parse(markdown)
        XCTAssertEqual(blocks.count, 2)
        guard case .paragraph = blocks[0] else { XCTFail("Expected paragraph"); return }
        guard case .paragraph = blocks[1] else { XCTFail("Expected paragraph"); return }
    }

    // MARK: - Bold and Italic

    func testBoldText() {
        let blocks = parser.parse("This is **bold** text")
        guard case .paragraph(let content) = blocks[0] else {
            XCTFail("Expected paragraph"); return
        }
        XCTAssertTrue(containsStrong(content))
    }

    func testItalicText() {
        let blocks = parser.parse("This is *italic* text")
        guard case .paragraph(let content) = blocks[0] else {
            XCTFail("Expected paragraph"); return
        }
        XCTAssertTrue(containsEmphasis(content))
    }

    // MARK: - Code

    func testCodeBlock() {
        let markdown = """
        ```swift
        let x = 1
        print(x)
        ```
        """
        let blocks = parser.parse(markdown)
        guard case .codeBlock(let lang, let code) = blocks[0] else {
            XCTFail("Expected code block, got \(blocks[0])"); return
        }
        XCTAssertEqual(lang, "swift")
        XCTAssertTrue(code.contains("let x = 1"))
    }

    func testInlineCode() {
        let blocks = parser.parse("Use the `print()` function")
        guard case .paragraph(let content) = blocks[0] else {
            XCTFail("Expected paragraph"); return
        }
        XCTAssertTrue(containsInlineCode(content))
    }

    // MARK: - Lists

    func testUnorderedList() {
        let markdown = """
        - Item one
        - Item two
        - Item three
        """
        let blocks = parser.parse(markdown)
        guard case .unorderedList(let items) = blocks[0] else {
            XCTFail("Expected unordered list, got \(blocks[0])"); return
        }
        XCTAssertEqual(items.count, 3)
    }

    func testOrderedList() {
        let markdown = """
        1. First
        2. Second
        3. Third
        """
        let blocks = parser.parse(markdown)
        guard case .orderedList(let start, let items) = blocks[0] else {
            XCTFail("Expected ordered list, got \(blocks[0])"); return
        }
        XCTAssertEqual(start, 1)
        XCTAssertEqual(items.count, 3)
    }

    // MARK: - Blockquote

    func testBlockquote() {
        let blocks = parser.parse("> This is a quote")
        guard case .blockquote(let content) = blocks[0] else {
            XCTFail("Expected blockquote, got \(blocks[0])"); return
        }
        XCTAssertEqual(content.count, 1)
    }

    // MARK: - Thematic Break

    func testThematicBreak() {
        let blocks = parser.parse("---")
        guard case .thematicBreak = blocks[0] else {
            XCTFail("Expected thematic break, got \(blocks[0])"); return
        }
    }

    // MARK: - Links

    func testLink() {
        let blocks = parser.parse("[Click here](https://example.com)")
        guard case .paragraph(let content) = blocks[0] else {
            XCTFail("Expected paragraph"); return
        }
        XCTAssertTrue(containsLink(content))
    }

    // MARK: - Images

    func testImage() {
        let blocks = parser.parse("![Alt text](https://example.com/image.png)")
        guard case .image(let source, let alt) = blocks[0] else {
            XCTFail("Expected image, got \(blocks[0])"); return
        }
        XCTAssertEqual(source, "https://example.com/image.png")
        XCTAssertTrue(alt.contains("Alt text"))
    }

    // MARK: - Tables

    func testTable() {
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 30  |
        | Jane | 25  |
        """
        let blocks = parser.parse(markdown)
        guard case .table(let headers, let rows) = blocks[0] else {
            XCTFail("Expected table, got \(blocks[0])"); return
        }
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(rows.count, 2)
    }

    // MARK: - Incomplete Markdown (Streaming)

    func testIncompleteCodeBlock() {
        // Simulate streaming: code block not yet closed
        let blocks = parser.parse("```swift\nlet x = 1")
        // swift-markdown should still produce something
        XCTAssertFalse(blocks.isEmpty, "Parser should produce output even for incomplete input")
    }

    func testEmptyInput() {
        let blocks = parser.parse("")
        XCTAssertTrue(blocks.isEmpty)
    }

    // MARK: - Hashable (Diffable Data Source)

    func testBlockHashStability() {
        let blocks1 = parser.parse("# Title\n\nParagraph text")
        let blocks2 = parser.parse("# Title\n\nParagraph text")

        XCTAssertEqual(blocks1.count, blocks2.count)
        for (b1, b2) in zip(blocks1, blocks2) {
            XCTAssertEqual(b1, b2, "Same Markdown should produce equal blocks")
            XCTAssertEqual(b1.stableID, b2.stableID, "Same blocks should have same stable ID")
        }
    }

    func testBlockHashDifference() {
        let blocks1 = parser.parse("# Title One")
        let blocks2 = parser.parse("# Title Two")

        // Different content should produce different hashes
        XCTAssertNotEqual(blocks1[0], blocks2[0])
        XCTAssertNotEqual(blocks1[0].stableID, blocks2[0].stableID)
    }

    // MARK: - Streaming Consistency

    func testStreamingVsBulk() {
        let fullMarkdown = """
        # Title

        First paragraph with **bold** and *italic*.

        ```swift
        let x = 1
        ```

        - Item 1
        - Item 2

        > A quote

        ---

        Final paragraph with [link](https://example.com).
        """

        // Parse as bulk
        let bulkBlocks = parser.parse(fullMarkdown)

        // Simulate streaming: send chunks character by character
        var streamedBlocks: [MarkdownBlock] = []
        for char in fullMarkdown {
            let current = String(fullMarkdown.prefix(through: fullMarkdown.firstIndex(of: char)!))
            streamedBlocks = parser.parse(current)
        }

        // Final streaming result should match bulk
        XCTAssertEqual(
            streamedBlocks.count,
            bulkBlocks.count,
            "Streaming and bulk parsing should produce same block count"
        )
    }

    // MARK: - Helpers

    private func containsText(_ inlines: [MarkdownInline], _ text: String) -> Bool {
        for inline in inlines {
            switch inline {
            case .text(let t) where t.contains(text):
                return true
            case .strong(let children), .emphasis(let children):
                if containsText(children, text) { return true }
            default:
                break
            }
        }
        return false
    }

    private func containsStrong(_ inlines: [MarkdownInline]) -> Bool {
        for inline in inlines {
            if case .strong = inline { return true }
            if case .emphasis(let children) = inline, containsStrong(children) { return true }
            if case .strong(let children) = inline, containsStrong(children) { return true }
        }
        return false
    }

    private func containsEmphasis(_ inlines: [MarkdownInline]) -> Bool {
        for inline in inlines {
            if case .emphasis = inline { return true }
        }
        return false
    }

    private func containsInlineCode(_ inlines: [MarkdownInline]) -> Bool {
        for inline in inlines {
            if case .inlineCode = inline { return true }
        }
        return false
    }

    private func containsLink(_ inlines: [MarkdownInline]) -> Bool {
        for inline in inlines {
            if case .link = inline { return true }
        }
        return false
    }
}
