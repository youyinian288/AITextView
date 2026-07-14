import UIKit

/// Renders a paragraph block using a non-editable UITextView for rich text support.
/// Link taps are forwarded to `interactionDelegate`.
final class ParagraphCell: MarkdownBaseCell, UITextViewDelegate {

    weak var interactionDelegate: MarkdownCellInteractionDelegate?

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        tv.textContainer.maximumNumberOfLines = 0
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
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Configure

    func setContent(
        _ inlines: [MarkdownInline],
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) {
        configure(with: config)
        textView.isSelectable = config.allowsTextSelection
        let attr = builder.build(inlines, baseFont: config.bodyFont, baseColor: config.textColor)
        textView.attributedText = attr
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.attributedText = nil
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
        // Return false to prevent the text view from opening the URL itself;
        // the delegate (or app) decides what to do.
        return false
    }
}
