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
        switch (cell, block) {
        case let (cell as ParagraphCell, .paragraph(let content)):
            cell.setContent(content, config: config, builder: builder)
            cell.interactionDelegate = interactionDelegate

        case let (cell as HeadingCell, .heading(let level, let content)):
            cell.setContent(level: level, inlines: content, config: config, builder: builder)

        case let (cell as CodeBlockCell, .codeBlock(let lang, let code)):
            cell.setContent(language: lang, code: code, config: config)

        case let (cell as BlockquoteCell, .blockquote(let blocks)):
            cell.setContent(blocks, config: config, builder: builder)
            cell.interactionDelegate = interactionDelegate

        case let (cell as ListItemCell, .unorderedList(let items)):
            cell.setContent(items: items, ordered: false, start: 0, config: config, builder: builder)
            cell.interactionDelegate = interactionDelegate

        case let (cell as ListItemCell, .orderedList(let start, let items)):
            cell.setContent(items: items, ordered: true, start: start, config: config, builder: builder)
            cell.interactionDelegate = interactionDelegate

        case let (cell as ThematicBreakCell, .thematicBreak):
            cell.setContent(config: config)

        case let (cell as TableCell, .table(let headers, let rows)):
            cell.setContent(headers: headers, rows: rows, config: config, builder: builder)

        case let (cell as ImageCell, .image(let source, let alt)):
            cell.setContent(source: source, alt: alt, config: config)
            cell.interactionDelegate = interactionDelegate

        case let (cell as MathBlockCell, .mathBlock(let content)):
            cell.setContent(math: content, config: config)

        default:
            break
        }
    }
}
