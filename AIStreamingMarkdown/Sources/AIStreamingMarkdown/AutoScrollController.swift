import UIKit

// MARK: - Auto-Scroll Controller

/// Manages smart auto-scrolling behavior for the Markdown collection view.
///
/// - Automatically scrolls to the bottom when the user is near the bottom
/// - Pauses auto-scrolling when the user scrolls up to read earlier content
/// - Resumes auto-scrolling when the user manually scrolls back to the bottom
final class AutoScrollController: NSObject {

    // MARK: - Properties

    private weak var collectionView: UICollectionView?
    private let threshold: CGFloat

    /// Whether auto-scrolling is enabled.
    var isEnabled: Bool = true

    /// Tracks whether the user is considered "near the bottom".
    private(set) var isNearBottom: Bool = true

    /// Whether the user is currently dragging/scrolling manually.
    private var isUserScrolling: Bool = false

    // MARK: - Init

    init(collectionView: UICollectionView, threshold: CGFloat = 120) {
        self.collectionView = collectionView
        self.threshold = threshold
        super.init()
        collectionView.delegate = self
    }

    // MARK: - Public

    /// Scroll to the bottom, optionally animated.
    func scrollToBottom(animated: Bool) {
        guard let cv = collectionView, let lastIP = lastIndexPath else { return }

        // Ensure the last item is visible
        cv.layoutIfNeeded()

        let contentHeight = cv.contentSize.height
        let frameHeight = cv.bounds.height - cv.adjustedContentInset.bottom

        guard contentHeight > frameHeight else { return }

        let targetOffset = CGPoint(x: 0, y: max(0, contentHeight - frameHeight))
        cv.setContentOffset(targetOffset, animated: animated)

        isNearBottom = true
    }

    /// Called after new content has been added. Scrolls if appropriate.
    func contentDidUpdate() {
        guard isEnabled, !isUserScrolling, isNearBottom else { return }
        scrollToBottom(animated: true)
    }

    // MARK: - Private

    private var lastIndexPath: IndexPath? {
        guard let cv = collectionView else { return nil }
        let sections = cv.numberOfSections
        guard sections > 0 else { return nil }
        let items = cv.numberOfItems(inSection: sections - 1)
        guard items > 0 else { return nil }
        return IndexPath(item: items - 1, section: sections - 1)
    }

    private func checkNearBottom() {
        guard let cv = collectionView else { return }

        let contentHeight = cv.contentSize.height
        let offsetY = cv.contentOffset.y
        let frameHeight = cv.bounds.height - cv.adjustedContentInset.bottom

        let distanceFromBottom = contentHeight - offsetY - frameHeight
        isNearBottom = distanceFromBottom < threshold
    }
}

// MARK: - UIScrollViewDelegate

extension AutoScrollController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        checkNearBottom()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isUserScrolling = false
            checkNearBottom()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserScrolling = false
        checkNearBottom()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only update near-bottom when the user is actively scrolling
        if isUserScrolling {
            checkNearBottom()
        }
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isUserScrolling = false
        isNearBottom = false
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        checkNearBottom()
    }
}
