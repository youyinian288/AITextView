import UIKit

/// Renders a thematic break (horizontal rule).
final class ThematicBreakCell: MarkdownBaseCell {

    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 8),
            lineView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -8),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Configure

    func setContent(config: StreamingMarkdownConfiguration) {
        configure(with: config)
        lineView.backgroundColor = config.thematicBreakColor
    }
}
