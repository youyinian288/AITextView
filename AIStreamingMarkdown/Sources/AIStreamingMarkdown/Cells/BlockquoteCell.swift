import UIKit

/// Renders a blockquote with a leading accent bar and tinted background.
/// Link taps are forwarded to `interactionDelegate`.
final class BlockquoteCell: MarkdownBaseCell, UITextViewDelegate {

    weak var interactionDelegate: MarkdownCellInteractionDelegate?

    private let barView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(barView)
        contentView.addSubview(textView)

        let barWidth: CGFloat = 3

        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            barView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            barView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            barView.widthAnchor.constraint(equalToConstant: barWidth),

            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: barView.trailingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Configure

    func setContent(
        _ blocks: [MarkdownBlock],
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) {
        configure(with: config)
        barView.backgroundColor = config.blockquoteAccentColor
        barView.layer.cornerRadius = 2
        contentView.backgroundColor = config.blockquoteBackground

        textView.isSelectable = config.allowsTextSelection

        // Render nested blocks as attributed text with separators between blocks
        let result = NSMutableAttributedString()
        for (index, block) in blocks.enumerated() {
            switch block {
            case .paragraph(let content):
                let attr = builder.build(content, baseFont: config.blockquoteFont, baseColor: config.textColor)
                result.append(attr)
            case .heading(let level, let content):
                let font = config.headingFont(level: level)
                let color = config.headingColor(level: level)
                let attr = builder.build(content, baseFont: font, baseColor: color)
                result.append(attr)
            default:
                let attr = builder.build([.text(block.debugDescription)], baseFont: config.blockquoteFont, baseColor: config.textColor)
                result.append(attr)
            }

            if index < blocks.count - 1 {
                result.append(NSAttributedString(string: "\n"))
            }
        }

        textView.attributedText = result
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.attributedText = nil
        contentView.backgroundColor = .clear
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
