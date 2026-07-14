import UIKit

/// Renders a Markdown table using UIStackView grid layout (v1: equal-width columns).
final class TableCell: MarkdownBaseCell {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        contentView.addSubview(scrollView)
        scrollView.addSubview(containerStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            containerStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Configure

    func setContent(
        headers: [[MarkdownInline]],
        rows: [[[MarkdownInline]]],
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) {
        configure(with: config)
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let columnCount = headers.count
        guard columnCount > 0 else { return }

        // Header row
        let headerRow = createRow(
            cells: headers,
            isHeader: true,
            columnCount: columnCount,
            config: config,
            builder: builder
        )
        containerStack.addArrangedSubview(headerRow)

        // Add separator after header
        let separator = UIView()
        separator.backgroundColor = config.thematicBreakColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        containerStack.addArrangedSubview(separator)

        // Data rows
        for (index, row) in rows.enumerated() {
            let rowView = createRow(
                cells: row,
                isHeader: false,
                columnCount: columnCount,
                config: config,
                builder: builder
            )

            // Alternating row background
            if let altColor = config.tableAlternateRowBackground, index % 2 == 1 {
                rowView.backgroundColor = altColor
            }

            containerStack.addArrangedSubview(rowView)
        }
    }

    private func createRow(
        cells: [[MarkdownInline]],
        isHeader: Bool,
        columnCount: Int,
        config: StreamingMarkdownConfiguration,
        builder: AttributedTextBuilder
    ) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .top
        rowStack.distribution = .fillEqually
        rowStack.spacing = 1

        if isHeader {
            rowStack.backgroundColor = config.tableHeaderBackground
        }

        let font: UIFont = isHeader
            ? .boldSystemFont(ofSize: config.bodyFont.pointSize)
            : config.bodyFont

        for (index, cellContent) in cells.enumerated() {
            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = builder.build(cellContent, baseFont: font, baseColor: config.textColor)
            label.textAlignment = .natural
            label.translatesAutoresizingMaskIntoConstraints = false

            // Add padding
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            let pad: CGFloat = 8
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: pad),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: pad),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -pad),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -pad)
            ])

            // Add vertical separator between columns (not after last)
            if index < columnCount - 1 {
                let vSep = UIView()
                vSep.backgroundColor = config.thematicBreakColor.withAlphaComponent(0.3)
                vSep.translatesAutoresizingMaskIntoConstraints = false
                vSep.widthAnchor.constraint(equalToConstant: 1).isActive = true
                rowStack.addArrangedSubview(vSep)
            }

            rowStack.addArrangedSubview(container)
        }

        return rowStack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
