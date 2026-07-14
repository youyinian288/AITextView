import UIKit

// MARK: - Data Source

/// Manages `UICollectionViewDiffableDataSource` for Markdown blocks.
/// Supports stable + volatile incremental updates.
final class MarkdownDataSource {

    // MARK: - Types

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, String>

    // MARK: - Properties

    private let collectionView: UICollectionView
    private let cellProvider: MarkdownCellProvider
    private var dataSource: DataSource!
    private var currentBlocks: [MarkdownBlock] = []
    private var blockLookup: [String: MarkdownBlock] = [:]

    // MARK: - Init

    init(collectionView: UICollectionView, cellProvider: MarkdownCellProvider) {
        self.collectionView = collectionView
        self.cellProvider = cellProvider
        setupDataSource()
    }

    private func setupDataSource() {
        cellProvider.registerCells(in: collectionView)

        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, blockID in
            guard let self, let block = self.blockLookup[blockID] else {
                return UICollectionViewCell()
            }
            return self.cellProvider.dequeueCell(for: block, at: indexPath, in: collectionView)
        }
    }

    // MARK: - Public API

    /// Apply a snapshot built from the given blocks. IDs are index-prefixed to ensure uniqueness.
    private func applySnapshot(from blocks: [MarkdownBlock]) {
        currentBlocks = blocks
        let itemIDs = makeItemIDs(blocks)
        blockLookup = Dictionary(uniqueKeysWithValues: zip(itemIDs, blocks))

        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(itemIDs, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Replace all content with a new set of blocks (full render).
    func applyFullUpdate(_ blocks: [MarkdownBlock]) {
        applySnapshot(from: blocks)
    }

    /// Incrementally update: stable blocks stay, volatile ones are replaced.
    /// Uses a fresh snapshot with `animatingDifferences: false` for reliable updates.
    func applyIncrementalUpdate(stable: [MarkdownBlock], volatile: [MarkdownBlock]) {
        applySnapshot(from: stable + volatile)
    }

    /// Clear all content.
    func clear() {
        currentBlocks = []
        blockLookup = [:]
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// The index path of the last item, or nil if empty.
    var lastIndexPath: IndexPath? {
        guard !currentBlocks.isEmpty else { return nil }
        return IndexPath(item: currentBlocks.count - 1, section: 0)
    }

    // MARK: - Private

    /// Generate unique, stable item IDs using content-based hashes with
    /// an occurrence counter for disambiguation of identical blocks.
    ///
    /// IDs are stable across updates: a block that hasn't changed keeps
    /// the same ID regardless of position, because the counter is based
    /// on the number of preceding occurrences of the same content hash.
    private func makeItemIDs(_ blocks: [MarkdownBlock]) -> [String] {
        var counters: [String: Int] = [:]
        return blocks.map { block in
            let base = block.stableID
            let count = counters[base, default: 0]
            counters[base] = count + 1
            return "\(base)#\(count)"
        }
    }
}
