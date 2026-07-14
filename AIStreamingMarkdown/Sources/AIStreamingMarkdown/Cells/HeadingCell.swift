import UIKit

/// Renders a heading block (H1-H6) using UILabel.
final class HeadingCell: MarkdownBaseCell {

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
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
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Configure

    func setContent(
        level: Int,
        inlines: [MarkdownInline],
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) {
        configure(with: config)
        let font = config.headingFont(level: level)
        let color = config.headingColor(level: level)
        label.attributedText = builder.build(inlines, baseFont: font, baseColor: color)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.attributedText = nil
    }
}
