import UIKit

/// Renders an image block with async loading, placeholder, and error states.
/// Taps on the image are forwarded to `interactionDelegate`.
final class ImageCell: MarkdownBaseCell {

    weak var interactionDelegate: MarkdownCellInteractionDelegate?

    private var currentSource: String = ""

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Unable to load image"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let altLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private var imageHeightConstraint: NSLayoutConstraint?

    // Simple in-memory image cache
    private static let cache = NSCache<NSString, UIImage>()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(errorLabel)
        contentView.addSubview(altLabel)

        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 200)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            imageHeightConstraint!,

            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            altLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            altLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            altLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4)
        ])

        // Tap gesture for image interaction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard !currentSource.isEmpty else { return }
        interactionDelegate?.cellDidTapImage(source: currentSource)
    }

    // MARK: - Configure

    func setContent(source: String, alt: String, config: StreamingMarkdownConfiguration) {
        configure(with: config)
        currentSource = source
        imageHeightConstraint?.constant = config.imageMaxHeight

        errorLabel.isHidden = true
        activityIndicator.stopAnimating()

        // Show alt text if present
        if !alt.isEmpty {
            altLabel.text = alt
            altLabel.isHidden = false
        } else {
            altLabel.isHidden = true
        }

        // Check cache first
        if let cached = Self.cache.object(forKey: source as NSString) {
            imageView.image = cached
            return
        }

        // Handle base64 data URIs
        if source.hasPrefix("data:image/") {
            loadBase64Image(source)
            return
        }

        // Handle URL loading
        guard let url = URL(string: source) else {
            showError()
            return
        }

        activityIndicator.startAnimating()
        imageView.image = nil

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async { self?.showError() }
                return
            }

            Self.cache.setObject(image, forKey: source as NSString)

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
                self.errorLabel.isHidden = true
            }
        }.resume()
    }

    private func loadBase64Image(_ dataURI: String) {
        // Parse "data:image/png;base64,iVBORw0KG..."
        guard let commaIndex = dataURI.firstIndex(of: ",") else {
            showError()
            return
        }

        let base64String = String(dataURI[dataURI.index(after: commaIndex)...])
        guard let data = Data(base64Encoded: base64String),
              let image = UIImage(data: data) else {
            showError()
            return
        }

        imageView.image = image
    }

    private func showError() {
        activityIndicator.stopAnimating()
        errorLabel.isHidden = false
        imageView.image = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
        errorLabel.isHidden = true
        altLabel.isHidden = true
        currentSource = ""
        interactionDelegate = nil
    }
}
