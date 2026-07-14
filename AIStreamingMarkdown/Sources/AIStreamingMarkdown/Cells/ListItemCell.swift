import UIKit

/// Renders bulleted or numbered list items with indentation support.
/// Link taps are forwarded to `interactionDelegate`.
final class ListItemCell: MarkdownBaseCell, UITextViewDelegate {

    weak var interactionDelegate: MarkdownCellInteractionDelegate?

    private let bulletLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.adjustsFontForContentSizeCategory = true
        return tv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        textView.delegate = self
        contentView.addSubview(bulletLabel)
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            bulletLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            bulletLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            bulletLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),

            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: bulletLabel.trailingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Configure

    func setContent(
        items: [MarkdownListItem],
        ordered: Bool,
        start: Int,
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) {
        configure(with: config)
        textView.isSelectable = config.allowsTextSelection

        let result = NSMutableAttributedString()

        for (offset, item) in items.enumerated() {
            let index = start + offset

            // Bullet prefix
            let prefix: String
            if ordered {
                prefix = "\(index). "
            } else {
                // Use different bullets for nesting levels
                switch item.indentation % 3 {
                case 0: prefix = "• "
                case 1: prefix = "◦ "
                default: prefix = "▪ "
                }
            }

            let prefixAttr = NSAttributedString(string: prefix, attributes: [
                .font: config.bodyFont,
                .foregroundColor: config.textColor
            ])
            result.append(prefixAttr)

            // Content blocks
            for (blockIndex, block) in item.content.enumerated() {
                switch block {
                case .paragraph(let content):
                    let attr = builder.build(content, baseFont: config.bodyFont, baseColor: config.textColor)
                    result.append(attr)
                case .heading(let level, let content):
                    let font = config.headingFont(level: level)
                    let color = config.headingColor(level: level)
                    let attr = builder.build(content, baseFont: font, baseColor: color)
                    result.append(attr)
                default:
                    let attr = builder.build([.text(block.debugDescription)], baseFont: config.bodyFont, baseColor: config.textColor)
                    result.append(attr)
                }

                if blockIndex < item.content.count - 1 {
                    result.append(NSAttributedString(string: "\n"))
                }
            }

            if offset < items.count - 1 {
                result.append(NSAttributedString(string: "\n"))
            }
        }

        textView.attributedText = result

        // Set bullet label (shows the first item's prefix)
        if let firstItem = items.first {
            if ordered {
                bulletLabel.text = "\(start)."
            } else {
                switch firstItem.indentation % 3 {
                case 0: bulletLabel.text = "•"
                case 1: bulletLabel.text = "◦"
                default: bulletLabel.text = "▪"
                }
            }
            bulletLabel.font = config.bodyFont
            bulletLabel.textColor = config.textColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.attributedText = nil
        bulletLabel.text = nil
        interactionDelegate = nil
    }

    // MARK: - UITextViewDelegate

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        interactionDelegate?.cellDidTapLink(URL)
        return false
    }
}
