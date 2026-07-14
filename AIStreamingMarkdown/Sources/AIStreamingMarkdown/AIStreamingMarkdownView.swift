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
        self.cellProvider = MarkdownCellProvider(config: configuration)
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

        cellProvider.interactionDelegate = self

        NSLayoutConstraint.activate([
            markdownCollectionView.topAnchor.constraint(equalTo: topAnchor),
            markdownCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            markdownCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            markdownCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        streamingController = StreamingMarkdownController(
            parser: parser,
            throttleInterval: configuration.throttleInterval,
            onUpdate: { [weak self] update in
                self?.handleUpdate(update)
            },
            onComplete: { [weak self] in
                self?.handleComplete()
            }
        )

        isSetupComplete = true
        delegate?.streamingMarkdownViewDidLoad(self)
    }

    // MARK: - Public API

    /// Append a chunk of Markdown text from an AI stream.
    public func append(_ markdownChunk: String) {
        guard !markdownChunk.isEmpty else { return }
        isStreaming = true
        streamingController?.append(markdownChunk)
    }

    /// Signal that the AI stream has ended.
    public func finish() {
        isStreaming = false
        streamingController?.finish()
    }

    /// Replace content with a complete Markdown string (non-streaming).
    public func setMarkdown(_ markdown: String) {
        self.markdown = markdown
        isStreaming = false

        let blocks = parser.parse(markdown)
        dataSource.applyFullUpdate(blocks)

        delegate?.streamingMarkdownView(self, markdownDidChange: markdown)
        streamingController?.setMarkdown(markdown)
    }

    /// Reset all content and streaming state.
    public func reset() {
        markdown = ""
        isStreaming = false
        dataSource.clear()
        streamingController?.reset()
        delegate?.streamingMarkdownView(self, markdownDidChange: "")
    }

    /// Scroll to the bottom of the content.
    public func scrollToBottom(animated: Bool = true) {
        autoScrollController.scrollToBottom(animated: animated)
    }

    // MARK: - Private Handlers

    private func handleUpdate(_ update: StreamingUpdate) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.handleUpdate(update) }
            return
        }

        markdown = update.fullText

        if update.volatile.isEmpty {
            dataSource.applyFullUpdate(update.allBlocks)
        } else {
            dataSource.applyIncrementalUpdate(stable: update.stable, volatile: update.volatile)
        }

        delegate?.streamingMarkdownView(self, markdownDidChange: update.fullText)
        autoScrollController.contentDidUpdate()
    }

    private func handleComplete() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.handleComplete() }
            return
        }
        isStreaming = false
    }
}

// MARK: - MarkdownCellInteractionDelegate

extension AIStreamingMarkdownView: MarkdownCellInteractionDelegate {

    func cellDidTapLink(_ url: URL) {
        let handled = delegate?.streamingMarkdownView(self, didTapLink: url) ?? true
        if handled {
            UIApplication.shared.open(url)
        }
    }

    func cellDidTapImage(source: String) {
        delegate?.streamingMarkdownView(self, didTapImage: source)
    }
}
