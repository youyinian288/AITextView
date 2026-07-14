import UIKit

// MARK: - AIStreamingMarkdownView

/// A pure-Swift UIView that renders AI-streamed Markdown in real time.
///
/// No WebKit, JavaScript, or HTML is used. Parsing is handled by Apple's swift-markdown,
/// and rendering is done via a `UICollectionView` with dedicated cell types.
///
/// ## Usage
/// ```swift
/// let view = AIStreamingMarkdownView(frame: bounds)
/// view.append("# Hello")
/// view.append(" World!")
/// view.finish()
/// ```
///
/// For SwiftUI, wrap with `AIStreamingMarkdownSwiftUIView`.
@objcMembers
public final class AIStreamingMarkdownView: UIView {

    // MARK: - Public Properties

    /// The delegate for callbacks.
    public weak var delegate: AIStreamingMarkdownViewDelegate?

    /// Whether auto-scroll is enabled when streaming.
    public var isAutoScrollEnabled: Bool {
        get { autoScrollController.isEnabled }
        set { autoScrollController.isEnabled = newValue }
    }

    /// The current full Markdown text.
    public private(set) var markdown: String = ""

    /// Whether the view is currently receiving streaming content.
    public private(set) var isStreaming: Bool = false

    /// The configuration used for styling.
    public let configuration: StreamingMarkdownConfiguration

    // MARK: - Private Properties

    private let markdownCollectionView: MarkdownCollectionView
    private let dataSource: MarkdownDataSource
    private let cellProvider: MarkdownCellProvider
    fileprivate let autoScrollController: AutoScrollController
    private var streamingController: StreamingMarkdownController?
    private let parser: MarkdownParser
    private var isSetupComplete = false

    // MARK: - Init

    /// Create a new streaming Markdown view.
    /// - Parameters:
    ///   - frame: The initial frame.
    ///   - configuration: Styling configuration. Defaults to `.init()`.
    public init(frame: CGRect = .zero, configuration: StreamingMarkdownConfiguration = .init()) {
        self.configuration = configuration
        self.parser = MarkdownParser()
        self.markdownCollectionView = MarkdownCollectionView(frame: frame)
        self.cellProvider = MarkdownCellProvider(config: configuration)
        self.dataSource = MarkdownDataSource(
            collectionView: markdownCollectionView.collectionView,
            cellProvider: cellProvider
        )
        self.autoScrollController = AutoScrollController(
            collectionView: markdownCollectionView.collectionView,
            threshold: configuration.autoScrollThreshold
        )
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        self.configuration = .init()
        self.parser = MarkdownParser()
        self.markdownCollectionView = MarkdownCollectionView(frame: .zero)
        self.cellProvider = MarkdownCellProvider(configuration: configuration)
        self.dataSource = MarkdownDataSource(
            collectionView: markdownCollectionView.collectionView,
            cellProvider: cellProvider
        )
        self.autoScrollController = AutoScrollController(
            collectionView: markdownCollectionView.collectionView,
            threshold: configuration.autoScrollThreshold
        )
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        markdownCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(markdownCollectionView)

        // Wire cell interaction delegate (link taps, image taps)
        cellProvider.interactionDelegate = self

        NSLayoutConstraint.activate([
            markdownCollectionView.topAnchor.constraint(equalTo: topAnchor),
            markdownCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            markdownCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            markdownCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Initialize the streaming controller
        streamingController = StreamingMarkdownController(
            parser: parser,
            throttleInterval: configuration.throttleInterval,
            onUpdate: { [weak self] update in
                await self?.handleUpdate(update)
            },
            onComplete: { [weak self] in
                await self?.handleComplete()
            }
        )

        isSetupComplete = true
        delegate?.streamingMarkdownViewDidLoad(self)
    }

    // MARK: - Public API

    /// Append a chunk of Markdown text from an AI stream.
    /// - Parameter markdownChunk: The new text fragment.
    public func append(_ markdownChunk: String) {
        guard !markdownChunk.isEmpty else { return }
        isStreaming = true

        Task {
            await streamingController?.append(markdownChunk)
        }
    }

    /// Signal that the AI stream has ended.
    public func finish() {
        isStreaming = false

        Task {
            await streamingController?.finish()
        }
    }

    /// Replace content with a complete Markdown string (non-streaming).
    /// - Parameter markdown: The full Markdown content.
    public func setMarkdown(_ markdown: String) {
        self.markdown = markdown
        isStreaming = false

        let blocks = parser.parse(markdown)
        dataSource.applyFullUpdate(blocks)

        delegate?.streamingMarkdownView(self, markdownDidChange: markdown)

        // Reset streaming state
        Task {
            await streamingController?.setMarkdown(markdown)
        }
    }

    /// Reset all content and streaming state. Ready for a new stream.
    public func reset() {
        markdown = ""
        isStreaming = false
        dataSource.clear()

        Task {
            await streamingController?.reset()
        }

        delegate?.streamingMarkdownView(self, markdownDidChange: "")
    }

    /// Scroll to the bottom of the content.
    /// - Parameter animated: Whether to animate the scroll. Default: `true`.
    public func scrollToBottom(animated: Bool = true) {
        autoScrollController.scrollToBottom(animated: animated)
    }

    // MARK: - Private Handlers

    @MainActor
    private func handleUpdate(_ update: StreamingUpdate) {
        markdown = update.fullText

        if update.volatile.isEmpty {
            // All stable — full update
            dataSource.applyFullUpdate(update.allBlocks)
        } else {
            // Incremental update
            dataSource.applyIncrementalUpdate(stable: update.stable, volatile: update.volatile)
        }

        delegate?.streamingMarkdownView(self, markdownDidChange: update.fullText)
        autoScrollController.contentDidUpdate()
    }

    @MainActor
    private func handleComplete() {
        isStreaming = false
    }
}

// MARK: - MarkdownCellInteractionDelegate

extension AIStreamingMarkdownView: MarkdownCellInteractionDelegate {

    func cellDidTapLink(_ url: URL) {
        let handled = delegate?.streamingMarkdownView(self, didTapLink: url) ?? true
        if handled {
            // Default behavior: open in Safari
            UIApplication.shared.open(url)
        }
    }

    func cellDidTapImage(source: String) {
        delegate?.streamingMarkdownView(self, didTapImage: source)
    }
}
