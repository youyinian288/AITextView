import UIKit

/// Renders a math block (v1: displays LaTeX source in a styled container).
/// Full math rendering (KaTeX equivalent) can be added as a future enhancement.
final class MathBlockCell: MarkdownBaseCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let mathLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(containerView)
        containerView.addSubview(mathLabel)

        let pad: CGFloat = 16

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            mathLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: pad),
            mathLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pad),
            mathLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -pad),
            mathLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -pad)
        ])
    }

    // MARK: - Configure

    func setContent(math: String, config: StreamingMarkdownConfiguration) {
        configure(with: config)

        containerView.backgroundColor = config.codeBlockBackground.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = config.containerCornerRadius
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = config.blockquoteAccentColor.withAlphaComponent(0.3).cgColor

        mathLabel.font = config.monospacedFont
        mathLabel.textColor = config.textColor
        mathLabel.text = math.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mathLabel.text = nil
    }
}
