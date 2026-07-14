import UIKit

// MARK: - Cell Registration Identifiers

private enum CellReuseID: String, CaseIterable {
    case paragraph
    case heading
    case codeBlock
    case blockquote
    case unorderedList
    case orderedList
    case thematicBreak
    case table
    case image
    case mathBlock
}

// MARK: - Cell Interaction Delegate

/// Internal delegate for cell→view communication (link taps, image taps).
protocol MarkdownCellInteractionDelegate: AnyObject {
    func cellDidTapLink(_ url: URL)
    func cellDidTapImage(source: String)
}

// MARK: - Cell Provider

/// Registers cell types and provides the correct cell for each `MarkdownBlock`.
final class MarkdownCellProvider {

    private let config: StreamingMarkdownConfiguration
    private let builder: AttributedTextBuilder
    weak var interactionDelegate: MarkdownCellInteractionDelegate?

    init(config: StreamingMarkdownConfiguration) {
        self.config = config
        self.builder = AttributedTextBuilder(config: config)
    }

    // MARK: - Registration

    func registerCells(in collectionView: UICollectionView) {
        collectionView.register(ParagraphCell.self, forCellWithReuseIdentifier: CellReuseID.paragraph.rawValue)
        collectionView.register(HeadingCell.self, forCellWithReuseIdentifier: CellReuseID.heading.rawValue)
        collectionView.register(CodeBlockCell.self, forCellWithReuseIdentifier: CellReuseID.codeBlock.rawValue)
        collectionView.register(BlockquoteCell.self, forCellWithReuseIdentifier: CellReuseID.blockquote.rawValue)
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: CellReuseID.unorderedList.rawValue)
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: CellReuseID.orderedList.rawValue)
        collectionView.register(ThematicBreakCell.self, forCellWithReuseIdentifier: CellReuseID.thematicBreak.rawValue)
        collectionView.register(TableCell.self, forCellWithReuseIdentifier: CellReuseID.table.rawValue)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: CellReuseID.image.rawValue)
        collectionView.register(MathBlockCell.self, forCellWithReuseIdentifier: CellReuseID.mathBlock.rawValue)
    }

    // MARK: - Cell Dequeue

    func dequeueCell(
        for block: MarkdownBlock,
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let reuseID: String

        switch block {
        case .heading:               reuseID = CellReuseID.heading.rawValue
        case .paragraph:             reuseID = CellReuseID.paragraph.rawValue
        case .codeBlock:             reuseID = CellReuseID.codeBlock.rawValue
        case .blockquote:            reuseID = CellReuseID.blockquote.rawValue
        case .unorderedList:         reuseID = CellReuseID.unorderedList.rawValue
        case .orderedList:           reuseID = CellReuseID.orderedList.rawValue
        case .thematicBreak:         reuseID = CellReuseID.thematicBreak.rawValue
        case .table:                 reuseID = CellReuseID.table.rawValue
        case .image:                 reuseID = CellReuseID.image.rawValue
        case .mathBlock:             reuseID = CellReuseID.mathBlock.rawValue
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)
        configure(cell: cell, with: block, config: config)
        return cell
    }

    // MARK: - Configuration

    private func configure(cell: UICollectionViewCell, with block: MarkdownBlock, config: StreamingMarkdownConfiguration) {
        switch block {
        case .paragraph(let content):
            guard let c = cell as? ParagraphCell else { return }
            c.setContent(content, config: config, builder: builder)
            c.interactionDelegate = interactionDelegate

        case .heading(let level, let content):
            guard let c = cell as? HeadingCell else { return }
            c.setContent(level: level, inlines: content, config: config, builder: builder)

        case .codeBlock(let lang, let code):
            guard let c = cell as? CodeBlockCell else { return }
            c.setContent(language: lang, code: code, config: config)

        case .blockquote(let blocks):
            guard let c = cell as? BlockquoteCell else { return }
            c.setContent(blocks, config: config, builder: builder)
            c.interactionDelegate = interactionDelegate

        case .unorderedList(let items):
            guard let c = cell as? ListItemCell else { return }
            c.setContent(items: items, ordered: false, start: 0, config: config, builder: builder)
            c.interactionDelegate = interactionDelegate

        case .orderedList(let start, let items):
            guard let c = cell as? ListItemCell else { return }
            c.setContent(items: items, ordered: true, start: start, config: config, builder: builder)
            c.interactionDelegate = interactionDelegate

        case .thematicBreak:
            guard let c = cell as? ThematicBreakCell else { return }
            c.setContent(config: config)

        case .table(let headers, let rows):
            guard let c = cell as? TableCell else { return }
            c.setContent(headers: headers, rows: rows, config: config, builder: builder)

        case .image(let source, let alt):
            guard let c = cell as? ImageCell else { return }
            c.setContent(source: source, alt: alt, config: config)
            c.interactionDelegate = interactionDelegate

        case .mathBlock(let content):
            guard let c = cell as? MathBlockCell else { return }
            c.setContent(math: content, config: config)
        }
    }
}
