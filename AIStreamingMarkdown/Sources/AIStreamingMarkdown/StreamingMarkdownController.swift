import Foundation

// MARK: - Streaming State

public enum StreamingState: Sendable {
    case idle
    case streaming
    case finishing
    case completed
    case failed(Error)
}

// MARK: - Update Result

public struct StreamingUpdate: Sendable {
    let stable: [MarkdownBlock]
    let volatile: [MarkdownBlock]
    let fullText: String
    let allBlocks: [MarkdownBlock]
}

// MARK: - Streaming Controller

/// Thread-safe controller that manages streaming Markdown input, throttling,
/// and incremental (stable + volatile) block diffing.
public class StreamingMarkdownController {

    // MARK: - Properties

    private let lock = NSLock()
    private var sourceMarkdown: String = ""
    private var pendingChunks: [String] = []
    private var lastBlocks: [MarkdownBlock] = []
    private var flushWorkItem: DispatchWorkItem?
    private let parser: MarkdownParser
    private let throttleInterval: TimeInterval
    private let flushQueue: DispatchQueue

    public private(set) var state: StreamingState = .idle

    private let onUpdate: (StreamingUpdate) -> Void
    private let onComplete: () -> Void

    // MARK: - Init

    public init(
        parser: MarkdownParser = MarkdownParser(),
        throttleInterval: TimeInterval = 0.033,
        onUpdate: @escaping (StreamingUpdate) -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.parser = parser
        self.throttleInterval = throttleInterval
        self.onUpdate = onUpdate
        self.onComplete = onComplete
        self.flushQueue = DispatchQueue(label: "com.aitextview.streaming.flush")
    }

    // MARK: - Public API

    public func append(_ chunk: String) {
        lock.lock()
        if case .completed = state { lock.unlock(); return }
        if case .failed = state { lock.unlock(); return }

        state = .streaming
        pendingChunks.append(chunk)

        if flushWorkItem == nil {
            scheduleFlush()
        }
        lock.unlock()
    }

    public func finish() {
        lock.lock()
        state = .finishing
        flushWorkItem?.cancel()
        flushWorkItem = nil
        lock.unlock()

        flush(isComplete: true)

        lock.lock()
        state = .completed
        lock.unlock()

        DispatchQueue.main.async { [weak self] in
            self?.onComplete()
        }
    }

    public func reset() {
        lock.lock()
        flushWorkItem?.cancel()
        flushWorkItem = nil
        sourceMarkdown = ""
        pendingChunks = []
        lastBlocks = []
        state = .idle
        lock.unlock()
    }

    public func setMarkdown(_ markdown: String) {
        lock.lock()
        flushWorkItem?.cancel()
        flushWorkItem = nil
        sourceMarkdown = markdown
        pendingChunks = []
        lastBlocks = []
        lock.unlock()

        let blocks = parser.parse(markdown)
        lastBlocks = blocks

        let update = StreamingUpdate(
            stable: blocks,
            volatile: [],
            fullText: markdown,
            allBlocks: blocks
        )
        DispatchQueue.main.async { [weak self] in
            self?.onUpdate(update)
        }
    }

    // MARK: - Private

    private func scheduleFlush() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.flush(isComplete: false)
        }
        flushWorkItem = workItem
        flushQueue.asyncAfter(
            deadline: .now() + throttleInterval,
            execute: workItem
        )
    }

    private func flush(isComplete: Bool) {
        lock.lock()
        let merged = pendingChunks.joined()
        pendingChunks.removeAll()
        sourceMarkdown += merged
        let text = sourceMarkdown
        lock.unlock()

        let blocks = parser.parse(text)

        lock.lock()
        let (stable, volatile) = computeStableVolatile(
            previous: lastBlocks,
            current: blocks,
            isComplete: isComplete
        )
        lastBlocks = blocks
        flushWorkItem = nil
        lock.unlock()

        let update = StreamingUpdate(
            stable: stable,
            volatile: volatile,
            fullText: text,
            allBlocks: blocks
        )

        DispatchQueue.main.async { [weak self] in
            self?.onUpdate(update)
        }
    }

    // MARK: - Stable / Volatile Diff

    private func computeStableVolatile(
        previous: [MarkdownBlock],
        current: [MarkdownBlock],
        isComplete: Bool
    ) -> (stable: [MarkdownBlock], volatile: [MarkdownBlock]) {

        if isComplete || previous.isEmpty {
            return (current, [])
        }

        var divergenceIndex = 0
        let minCount = min(previous.count, current.count)

        for i in 0..<minCount {
            if previous[i] != current[i] {
                divergenceIndex = i
                break
            }
            divergenceIndex = i + 1
        }

        if divergenceIndex == minCount && previous.count != current.count {
            divergenceIndex = minCount
        }

        if divergenceIndex >= current.count {
            return (current, [])
        }

        let stable = Array(current[0..<divergenceIndex])
        let volatile = Array(current[divergenceIndex...])
        return (stable, volatile)
    }
}
