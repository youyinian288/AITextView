import UIKit

/// Base class for all Markdown block cells.
/// Provides common setup, reuse preparation, and content margins.
open class MarkdownBaseCell: UICollectionViewCell {

    /// The configuration used for styling.
    public var config: StreamingMarkdownConfiguration = .init()

    // MARK: - Lifecycle

    open override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    /// Apply configuration and set up content margins.
    open func configure(with config: StreamingMarkdownConfiguration) {
        self.config = config
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: config.verticalMargin,
            leading: config.horizontalMargin,
            bottom: config.verticalMargin,
            trailing: config.horizontalMargin
        )
    }

    // MARK: - Preferred Layout

    open override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(
            width: layoutAttributes.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let autoSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.frame.size.height = autoSize.height
        return attributes
    }
}
