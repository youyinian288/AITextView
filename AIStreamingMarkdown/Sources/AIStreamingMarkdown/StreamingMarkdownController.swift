import Foundation

// MARK: - Streaming State

/// The state of the streaming controller.
public enum StreamingState: Sendable {
    case idle
    case streaming
    case finishing
    case completed
    case failed(Error)
}

// MARK: - Update Result

/// The result of a streaming controller flush.
struct StreamingUpdate {
    let stable: [MarkdownBlock]
    let volatile: [MarkdownBlock]
    let fullText: String
    let allBlocks: [MarkdownBlock]
}

// MARK: - Streaming Controller

/// Actor-based controller that manages streaming Markdown input, throttling,
/// and incremental (stable + volatile) block diffing.
///
/// Thread safety: All state mutations happen on the actor's serial executor.
/// UI callbacks are dispatched to `@MainActor`.
public actor StreamingMarkdownController {

    // MARK: - Properties

    /// The complete accumulated Markdown text received so far.
    private var sourceMarkdown: String = ""

    /// Chunks that have been appended but not yet flushed.
    private var pendingChunks: [String] = []

    /// The last set of blocks rendered (used for stable/volatile diff).
    private var lastBlocks: [MarkdownBlock] = []

    /// The current state.
    public private(set) var state: StreamingState = .idle

    /// The parser instance.
    private let parser: MarkdownParser

    /// Throttle interval in seconds.
    private let throttleInterval: TimeInterval

    /// The scheduled flush task, if any.
    private var flushTask: Task<Void, Never>?

    /// Callback invoked on `@MainActor` when blocks should be updated.
    private let onUpdate: @Sendable (StreamingUpdate) async -> Void

    /// Callback invoked on `@MainActor` when streaming completes.
    private let onComplete: @Sendable () async -> Void

    // MARK: - Init

    public init(
        parser: MarkdownParser = MarkdownParser(),
        throttleInterval: TimeInterval = 0.033,
        onUpdate: @Sendable @escaping (StreamingUpdate) async -> Void,
        onComplete: @Sendable @escaping () async -> Void
    ) {
        self.parser = parser
        self.throttleInterval = throttleInterval
        self.onUpdate = onUpdate
        self.onComplete = onComplete
    }

    // MARK: - Public API

    /// Append a chunk of Markdown text from the AI stream.
    public func append(_ chunk: String) {
        guard case .idle = state {
            // If already completed or failed, ignore
            if case .completed = state { return }
            if case .failed = state { return }
            break
        }

        state = .streaming
        pendingChunks.append(chunk)

        // Schedule a flush if one isn't already scheduled
        if flushTask == nil {
            scheduleFlush()
        }
    }

    /// Signal that the stream has ended. Flushes all pending content immediately.
    public func finish() {
        state = .finishing

        // Cancel any pending timer
        flushTask?.cancel()
        flushTask = nil

        // Flush immediately
        flush(isComplete: true)

        state = .completed
        Task { @MainActor in
            await onComplete()
        }
    }

    /// Reset all state. Call before starting a new stream.
    public func reset() {
        flushTask?.cancel()
        flushTask = nil
        sourceMarkdown = ""
        pendingChunks = []
        lastBlocks = []
        state = .idle
    }

    /// Replace content with a complete Markdown string (non-streaming mode).
    public func setMarkdown(_ markdown: String) {
        flushTask?.cancel()
        flushTask = nil
        sourceMarkdown = markdown
        pendingChunks = []
        lastBlocks = []

        let blocks = parser.parse(markdown)
        lastBlocks = blocks

        let update = StreamingUpdate(
            stable: blocks,
            volatile: [],
            fullText: markdown,
            allBlocks: blocks
        )

        Task { @MainActor in
            await onUpdate(update)
        }
    }

    // MARK: - Private

    private func scheduleFlush() {
        flushTask = Task { [weak self] in
            guard let self else { return }

            let nanoseconds = UInt64(self.throttleInterval * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)

            guard !Task.isCancelled else { return }

            await self.flush(isComplete: false)
            self.flushTask = nil
        }
    }

    private func flush(isComplete: Bool) {
        // Merge pending chunks
        let merged = pendingChunks.joined()
        pendingChunks.removeAll()
        sourceMarkdown += merged

        // Parse current full text
        let blocks = parser.parse(sourceMarkdown)

        // Compute stable vs volatile
        let (stable, volatile) = computeStableVolatile(previous: lastBlocks, current: blocks, isComplete: isComplete)
        lastBlocks = blocks

        let update = StreamingUpdate(
            stable: stable,
            volatile: volatile,
            fullText: sourceMarkdown,
            allBlocks: blocks
        )

        Task { @MainActor in
            await onUpdate(update)
        }
    }

    // MARK: - Stable / Volatile Diff

    /// Compares the previous and current block arrays to determine which blocks
    /// are "stable" (unchanged) and which are "volatile" (new or changed).
    ///
    /// - When `isComplete` is true, all blocks are treated as stable.
    /// - Otherwise, blocks are compared by `Hashable` identity. The first index
    ///   where they differ marks the start of the volatile tail.
    private func computeStableVolatile(
        previous: [MarkdownBlock],
        current: [MarkdownBlock],
        isComplete: Bool
    ) -> (stable: [MarkdownBlock], volatile: [MarkdownBlock]) {

        if isComplete || previous.isEmpty {
            return (current, [])
        }

        // Find the first divergence point
        var divergenceIndex = 0
        let minCount = min(previous.count, current.count)

        for i in 0..<minCount {
            if previous[i] != current[i] {
                divergenceIndex = i
                break
            }
            divergenceIndex = i + 1
        }

        // If arrays differ in length, divergence starts at minCount
        if divergenceIndex == minCount && previous.count != current.count {
            divergenceIndex = minCount
        }

        if divergenceIndex >= current.count {
            // All current blocks are stable
            return (current, [])
        }

        let stable = Array(current[0..<divergenceIndex])
        let volatile = Array(current[divergenceIndex...])

        return (stable, volatile)
    }
}
