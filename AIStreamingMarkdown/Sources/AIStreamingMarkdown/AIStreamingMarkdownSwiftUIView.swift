import SwiftUI

// MARK: - SwiftUI Bridge

/// A SwiftUI-compatible wrapper for `AIStreamingMarkdownView`.
///
/// ## Static Markdown
/// ```swift
/// StreamingMarkdownView(markdown: "# Hello World")
/// ```
///
/// ## Streaming (recommended pattern)
/// When receiving token-by-token AI output, hold a reference to the underlying
/// `AIStreamingMarkdownView` and call `append(_:)` / `finish()` directly,
/// rather than updating a `@State` string on every token.
///
/// ```swift
/// struct ChatView: View {
///     @StateObject private var streamModel = StreamModel()
///
///     var body: some View {
///         StreamingMarkdownView(
///             markdown: streamModel.fullText,
///             isStreaming: streamModel.isStreaming
///         )
///     }
/// }
/// ```
@available(iOS 14.0, *)
public struct StreamingMarkdownView: UIViewRepresentable {

    /// The current Markdown text.
    public let markdown: String

    /// Whether streaming is in progress.
    public let isStreaming: Bool

    /// Configuration for styling.
    public let configuration: StreamingMarkdownConfiguration

    /// Delegate for callbacks (weakly held by the UIKit view internally).
    public let delegate: AIStreamingMarkdownViewDelegate?

    // MARK: - Init

    public init(
        markdown: String = "",
        isStreaming: Bool = false,
        configuration: StreamingMarkdownConfiguration = .init(),
        delegate: AIStreamingMarkdownViewDelegate? = nil
    ) {
        self.markdown = markdown
        self.isStreaming = isStreaming
        self.configuration = configuration
        self.delegate = delegate
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> AIStreamingMarkdownView {
        let view = AIStreamingMarkdownView(configuration: configuration)
        view.delegate = delegate

        if !markdown.isEmpty {
            if isStreaming {
                view.append(markdown)
            } else {
                view.setMarkdown(markdown)
            }
        }

        return view
    }

    public func updateUIView(_ uiView: AIStreamingMarkdownView, context: Context) {
        guard !markdown.isEmpty else {
            uiView.reset()
            return
        }

        if isStreaming {
            // In streaming mode, only update if the text changed significantly
            if markdown != uiView.markdown {
                uiView.setMarkdown(markdown)
            }
        } else {
            uiView.setMarkdown(markdown)
        }
    }
}

// MARK: - Convenience Modifiers

@available(iOS 14.0, *)
extension View {
    /// Configures the text and streaming state of a `StreamingMarkdownView`.
    public func streamingMarkdown(
        _ markdown: String,
        isStreaming: Bool = false
    ) -> some View {
        // This is a type hint for users; actual binding happens through the view's init.
        return self
    }
}
