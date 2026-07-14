import UIKit

// MARK: - Code Theme

/// Predefined syntax highlighting themes for code blocks.
public enum CodeTheme: Sendable {
    case xcode
    case dark
    case light

    public var name: String {
        switch self {
        case .xcode: return "Xcode"
        case .dark:  return "Dark"
        case .light: return "Light"
        }
    }
}

// MARK: - Configuration

/// Configures the appearance and behavior of `AIStreamingMarkdownView`.
public struct StreamingMarkdownConfiguration: Sendable {

    // MARK: Fonts

    /// Body / paragraph text font. Default: system font size 16.
    public var bodyFont: UIFont = .systemFont(ofSize: 16)

    /// Monospaced font for code blocks and inline code. Default: system monospaced size 14.
    public var monospacedFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)

    /// Font size for each heading level (1 through 6). Default: 28, 24, 20, 18, 16, 14.
    public var headingSizes: [Int: CGFloat] = [
        1: 28, 2: 24, 3: 20, 4: 18, 5: 16, 6: 14
    ]

    /// Font weight for each heading level (1 through 6). Default: bold for levels 1-4, semibold for 5-6.
    public var headingWeights: [Int: UIFont.Weight] = [
        1: .bold, 2: .bold, 3: .semibold, 4: .semibold, 5: .medium, 6: .medium
    ]

    /// Blockquote font. Default: system font size 16, italic.
    public var blockquoteFont: UIFont = .italicSystemFont(ofSize: 16)

    // MARK: Colors

    /// Body text color. Default: `.label`.
    public var textColor: UIColor = .label

    /// Color for each heading level. Default: `.label` for all.
    public var headingColors: [Int: UIColor] = [:]

    /// Link color. Default: `.systemBlue`.
    public var linkColor: UIColor = .systemBlue

    /// Code block background color. Default: system grouped background.
    public var codeBlockBackground: UIColor = .systemGroupedBackground

    /// Inline code background color. Default: system grouped background with slight tint.
    public var inlineCodeBackground: UIColor = .systemGray6

    /// Blockquote accent bar color. Default: `.systemGray3`.
    public var blockquoteAccentColor: UIColor = .systemGray3

    /// Blockquote background tint. Default: clear.
    public var blockquoteBackground: UIColor = .clear

    /// Thematic break color. Default: `.separator`.
    public var thematicBreakColor: UIColor = .separator

    /// Table header background color. Default: `.systemGroupedBackground`.
    public var tableHeaderBackground: UIColor = .systemGroupedBackground

    /// Table alternating row background. Default: nil (no alternating).
    public var tableAlternateRowBackground: UIColor?

    // MARK: Spacing

    /// Paragraph vertical spacing. Default: 8.
    public var paragraphSpacing: CGFloat = 8

    /// Heading bottom spacing. Default: 6.
    public var headingSpacing: CGFloat = 6

    /// Code block padding (all sides). Default: 12.
    public var codeBlockPadding: CGFloat = 12

    /// Blockquote leading indent. Default: 16.
    public var blockquoteIndent: CGFloat = 16

    /// Blockquote accent bar width. Default: 3.
    public var blockquoteBarWidth: CGFloat = 3

    /// List item indent per level. Default: 20.
    public var listIndentPerLevel: CGFloat = 20

    /// Cell horizontal margins. Default: 16.
    public var horizontalMargin: CGFloat = 16

    /// Cell vertical margins. Default: 4.
    public var verticalMargin: CGFloat = 4

    // MARK: Code Theme

    /// Syntax highlighting theme. Default: `.xcode`.
    public var codeTheme: CodeTheme = .xcode

    /// Whether to show the language label on code blocks. Default: true.
    public var showCodeLanguageLabel: Bool = true

    /// Whether to show the copy button on code blocks. Default: true.
    public var showCodeCopyButton: Bool = true

    // MARK: Images

    /// Maximum image height in points. Default: 300.
    public var imageMaxHeight: CGFloat = 300

    /// Placeholder image tint color. Default: `.systemGray3`.
    public var imagePlaceholderColor: UIColor = .systemGray3

    // MARK: Streaming

    /// Throttle interval for streaming updates, in seconds. Default: 0.033 (≈30 FPS).
    public var throttleInterval: TimeInterval = 0.033

    /// Auto-scroll threshold: distance from bottom (in points) within which the view auto-scrolls.
    /// Default: 120.
    public var autoScrollThreshold: CGFloat = 120

    // MARK: Misc

    /// Corner radius for containers (code blocks, images). Default: 8.
    public var containerCornerRadius: CGFloat = 8

    /// Whether to enable text selection. Default: true.
    public var allowsTextSelection: Bool = true

    // MARK: Init

    public init() {}

    // MARK: Convenience

    /// Returns the font for a given heading level.
    public func headingFont(level: Int) -> UIFont {
        let size = headingSizes[level] ?? 16
        let weight = headingWeights[level] ?? .regular
        return .systemFont(ofSize: size, weight: weight)
    }

    /// Returns the text color for a given heading level.
    public func headingColor(level: Int) -> UIColor {
        headingColors[level] ?? textColor
    }
}

// MARK: - Presets

extension StreamingMarkdownConfiguration {

    /// A dark-mode optimized preset.
    public static var dark: StreamingMarkdownConfiguration {
        var config = StreamingMarkdownConfiguration()
        config.textColor = .white
        config.codeBlockBackground = UIColor(white: 0.15, alpha: 1)
        config.inlineCodeBackground = UIColor(white: 0.2, alpha: 1)
        config.blockquoteAccentColor = .systemGray
        config.codeTheme = .dark
        config.tableHeaderBackground = UIColor(white: 0.15, alpha: 1)
        return config
    }

    /// A compact preset with smaller fonts and tighter spacing.
    public static var compact: StreamingMarkdownConfiguration {
        var config = StreamingMarkdownConfiguration()
        config.bodyFont = .systemFont(ofSize: 14)
        config.monospacedFont = .monospacedSystemFont(ofSize: 12, weight: .regular)
        config.headingSizes = [1: 22, 2: 19, 3: 17, 4: 15, 5: 14, 6: 13]
        config.paragraphSpacing = 4
        config.headingSpacing = 4
        config.horizontalMargin = 12
        config.verticalMargin = 2
        return config
    }
}
