import UIKit

/// Renders a fenced code block with syntax highlighting, language label, and copy button.
final class CodeBlockCell: MarkdownBaseCell {

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let languageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let copyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let codeTextView: UITextView = {
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

    private var codeText: String = ""

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
        headerStack.addArrangedSubview(languageLabel)
        headerStack.addArrangedSubview(UIView()) // spacer
        headerStack.addArrangedSubview(copyButton)
        containerView.addSubview(headerStack)
        containerView.addSubview(codeTextView)

        let pad: CGFloat = 12

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pad),
            headerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -pad),

            codeTextView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 4),
            codeTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pad),
            codeTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -pad),
            codeTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -pad)
        ])

        copyButton.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
    }

    // MARK: - Configure

    func setContent(language: String?, code: String, config: StreamingMarkdownConfiguration) {
        configure(with: config)
        codeText = code

        containerView.backgroundColor = config.codeBlockBackground
        containerView.layer.cornerRadius = config.containerCornerRadius

        languageLabel.text = language?.capitalized
        languageLabel.isHidden = !config.showCodeLanguageLabel || language == nil

        copyButton.isHidden = !config.showCodeCopyButton

        let attr = highlight(code: code, language: language, config: config)
        codeTextView.attributedText = attr
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        codeTextView.attributedText = nil
        codeText = ""
        languageLabel.text = nil
    }

    // MARK: - Copy

    @objc private func copyCode() {
        UIPasteboard.general.string = codeText

        // Brief feedback
        let original = copyButton.image(for: .normal)
        copyButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyButton.setImage(original, for: .normal)
        }
    }

    // MARK: - Syntax Highlighting

    private func highlight(code: String, language: String?, config: StreamingMarkdownConfiguration) -> NSAttributedString {
        let result = NSMutableAttributedString(string: code, attributes: [
            .font: config.monospacedFont,
            .foregroundColor: config.textColor
        ])

        // Apply keyword highlighting based on language
        let keywords: [String]
        switch language?.lowercased() {
        case "swift":
            keywords = ["func", "var", "let", "class", "struct", "enum", "import",
                        "return", "if", "else", "for", "while", "guard", "switch",
                        "case", "break", "continue", "throws", "try", "catch",
                        "public", "private", "internal", "static", "override",
                        "protocol", "extension", "where", "in", "as", "is", "self"]
        case "python":
            keywords = ["def", "class", "import", "from", "return", "if", "elif",
                        "else", "for", "while", "break", "continue", "try", "except",
                        "raise", "with", "as", "in", "not", "and", "or", "True",
                        "False", "None", "lambda", "yield", "pass"]
        case "javascript", "js", "typescript", "ts":
            keywords = ["function", "const", "let", "var", "class", "import", "export",
                        "return", "if", "else", "for", "while", "break", "continue",
                        "try", "catch", "throw", "new", "this", "async", "await",
                        "typeof", "instanceof", "true", "false", "null", "undefined"]
        case "java", "kotlin":
            keywords = ["class", "public", "private", "protected", "static", "final",
                        "void", "int", "String", "boolean", "return", "if", "else",
                        "for", "while", "new", "import", "package", "throws", "try",
                        "catch", "extends", "implements", "interface", "abstract"]
        default:
            keywords = []
        }

        guard !keywords.isEmpty else { return result }

        // Naive word-boundary matching (simple but functional)
        let pattern = "\\b(\(keywords.joined(separator: "|")))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result
        }

        let nsRange = NSRange(code.startIndex..<code.endIndex, in: code)
        let matches = regex.matches(in: code, options: [], range: nsRange)

        let keywordColor: UIColor = {
            switch config.codeTheme {
            case .xcode:  return UIColor(red: 0.61, green: 0.13, blue: 0.57, alpha: 1) // purple
            case .dark:   return UIColor(red: 0.98, green: 0.45, blue: 0.65, alpha: 1) // pink
            case .light:  return UIColor(red: 0.61, green: 0.13, blue: 0.57, alpha: 1)
            }
        }()

        for match in matches {
            result.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
        }

        // Highlight comments (// ... and /* ... */)
        let commentPattern = "//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/"
        if let commentRegex = try? NSRegularExpression(pattern: commentPattern, options: []) {
            let commentColor: UIColor = {
                switch config.codeTheme {
                case .xcode:  return UIColor(red: 0.42, green: 0.50, blue: 0.39, alpha: 1) // green
                case .dark:   return UIColor(red: 0.42, green: 0.59, blue: 0.38, alpha: 1)
                case .light:  return UIColor(red: 0.42, green: 0.50, blue: 0.39, alpha: 1)
                }
            }()
            let commentMatches = commentRegex.matches(in: code, options: [], range: nsRange)
            for match in commentMatches {
                result.addAttribute(.foregroundColor, value: commentColor, range: match.range)
            }
        }

        // Highlight strings ("..." and raw string literals)
        let stringPattern = "\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\""
        if let stringRegex = try? NSRegularExpression(pattern: stringPattern, options: []) {
            let stringColor: UIColor = {
                switch config.codeTheme {
                case .xcode:  return UIColor(red: 0.78, green: 0.13, blue: 0.13, alpha: 1) // red
                case .dark:   return UIColor(red: 0.98, green: 0.39, blue: 0.30, alpha: 1)
                case .light:  return UIColor(red: 0.78, green: 0.13, blue: 0.13, alpha: 1)
                }
            }()
            let stringMatches = stringRegex.matches(in: code, options: [], range: nsRange)
            for match in stringMatches {
                result.addAttribute(.foregroundColor, value: stringColor, range: match.range)
            }
        }

        return result
    }
}
