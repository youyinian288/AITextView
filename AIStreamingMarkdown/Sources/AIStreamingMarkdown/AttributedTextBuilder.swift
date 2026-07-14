import UIKit

// MARK: - AttributedTextBuilder

/// Converts `[MarkdownInline]` into `NSAttributedString` using a given configuration.
public struct AttributedTextBuilder: Sendable {

    public let config: StreamingMarkdownConfiguration

    public init(config: StreamingMarkdownConfiguration) {
        self.config = config
    }

    /// Build an attributed string from an array of inline elements.
    /// - Parameters:
    ///   - inlines: The inline content to render.
    ///   - baseFont: The base font to use (may be overridden by styles like code).
    ///   - baseColor: The base text color.
    /// - Returns: A fully styled `NSAttributedString`.
    public func build(
        _ inlines: [MarkdownInline],
        baseFont: UIFont,
        baseColor: UIColor
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for inline in inlines {
            result.append(buildInline(inline, font: baseFont, color: baseColor))
        }
        return result
    }

    // MARK: - Inline dispatch

    private func buildInline(
        _ inline: MarkdownInline,
        font: UIFont,
        color: UIColor
    ) -> NSAttributedString {
        switch inline {
        case .text(let string):
            return NSAttributedString(string: string, attributes: [
                .font: font,
                .foregroundColor: color
            ])

        case .strong(let children):
            let boldFont = font.withTraits(.traitBold) ?? font
            return build(children, baseFont: boldFont, baseColor: color)

        case .emphasis(let children):
            let italicFont = font.withTraits(.traitItalic) ?? font
            return build(children, baseFont: italicFont, baseColor: color)

        case .strikethrough(let children):
            let attr = NSMutableAttributedString(
                attributedString: build(children, baseFont: font, baseColor: color)
            )
            attr.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue,
                              range: NSRange(location: 0, length: attr.length))
            return attr

        case .inlineCode(let code):
            let attrs: [NSAttributedString.Key: Any] = [
                .font: config.monospacedFont,
                .foregroundColor: color,
                .backgroundColor: config.inlineCodeBackground
            ]
            return NSAttributedString(string: code, attributes: attrs)

        case .link(let destination, let children):
            let displayText = children.isEmpty ? destination : children.reduce("") { acc, inline in
                if case .text(let t) = inline { return acc + t }
                return acc
            }
            let text = displayText.isEmpty ? destination : displayText
            let attr = NSMutableAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: config.linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .link: URL(string: destination) ?? destination
            ])
            return attr

        case .image(let source, let alt):
            // Inline images render as the alt text in a special style.
            let display = alt.isEmpty ? "[image]" : "[\(alt)]"
            return NSAttributedString(string: display, attributes: [
                .font: font.withTraits(.traitItalic) ?? font,
                .foregroundColor: config.blockquoteAccentColor
            ])

        case .softBreak:
            return NSAttributedString(string: " ", attributes: [
                .font: font,
                .foregroundColor: color
            ])

        case .lineBreak:
            return NSAttributedString(string: "\n", attributes: [
                .font: font,
                .foregroundColor: color
            ])
        }
    }
}

// MARK: - Font Traits Helper

extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return nil
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
