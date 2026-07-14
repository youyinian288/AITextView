import Foundation

/// Delegate protocol for `AIStreamingMarkdownView` events.
public protocol AIStreamingMarkdownViewDelegate: AnyObject {

    /// Called when the view has finished initial setup and is ready to display content.
    func streamingMarkdownViewDidLoad(_ view: AIStreamingMarkdownView)

    /// Called whenever the current markdown content changes (streaming or complete).
    /// - Parameters:
    ///   - view: The markdown view.
    ///   - markdown: The full accumulated markdown text at this point.
    func streamingMarkdownView(_ view: AIStreamingMarkdownView, markdownDidChange markdown: String)

    /// Called when the user taps a link in the rendered markdown.
    /// - Parameters:
    ///   - view: The markdown view.
    ///   - url: The URL that was tapped.
    /// - Returns: Return `true` if the view should handle the link (open in Safari),
    ///            or `false` if the delegate has handled it.
    func streamingMarkdownView(_ view: AIStreamingMarkdownView, didTapLink url: URL) -> Bool

    /// Called when the user taps an image in the rendered markdown.
    /// - Parameters:
    ///   - view: The markdown view.
    ///   - source: The image source URL or data URI.
    func streamingMarkdownView(_ view: AIStreamingMarkdownView, didTapImage source: String)

    /// Called when the content height changes significantly.
    /// - Parameters:
    ///   - view: The markdown view.
    ///   - height: The new content height.
    func streamingMarkdownView(_ view: AIStreamingMarkdownView, contentHeightDidChange height: CGFloat)
}

// MARK: - Default Implementations

public extension AIStreamingMarkdownViewDelegate {
    func streamingMarkdownViewDidLoad(_ view: AIStreamingMarkdownView) {}

    func streamingMarkdownView(_ view: AIStreamingMarkdownView, markdownDidChange markdown: String) {}

    func streamingMarkdownView(_ view: AIStreamingMarkdownView, didTapLink url: URL) -> Bool {
        return true // default: let the view handle it
    }

    func streamingMarkdownView(_ view: AIStreamingMarkdownView, didTapImage source: String) {}

    func streamingMarkdownView(_ view: AIStreamingMarkdownView, contentHeightDidChange height: CGFloat) {}
}
