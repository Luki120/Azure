import UIKit

/// Class that'll show a header view for the modal child view's table view
final class NewIssuerOptionsHeaderView: UIView {

	private lazy var titleStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alpha = 0
		stackView.spacing = 10
		stackView.transform = .init(scaleX: 0.1, y: 0.1)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		return stackView
	}()

	private var headerViewHeight = 120.0
	private var strongTitleLabel, strongSubtitleLabel: UILabel!

	// ! Lifecycle

	override func layoutSubviews() {
		super.layoutSubviews()

		frame = .init(x: 0, y: 0, width: frame.size.width, height: headerViewHeight)

		NSLayoutConstraint.activate([
			titleStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
			titleStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
			titleStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
		])
	}

	// ! Reusable

	private func createLabel(
		withFont font: UIFont = .systemFont(ofSize: 16),
		text: String,
		textColor: UIColor = .label
	) -> UILabel {
		let label = UILabel()
		label.font = font
		label.text = text
		label.textColor = textColor
		label.numberOfLines = 0
		label.textAlignment = .center
		titleStackView.addArrangedSubview(label)
		return label
	}

}

extension NewIssuerOptionsHeaderView {

	// ! Public

	/// Function to animate the header view's alpha & transform properties
	func animateHeaderView() {
		UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .transitionCrossDissolve) {
			self.titleStackView.alpha = 1
			self.titleStackView.transform = .init(scaleX: 1, y: 1)
		}
	}

	/// Function to configure the header view
	/// - Parameters:
	///		- withHeight: A Double to represent the header view's height
	///		- title: A String that represents the header's title
	///		- subtitle: A String that represents the header's subtitle
	///		- prepareForReuse: A Bool to check wether we should reuse the header or not
	func configure(
		withHeight height: Double = 120,
		title: String = "Add issuer",
		subtitle: String = "Add an issuer by scanning a QR code, importing a QR image or entering the secret manually.",
		prepareForReuse: Bool = false
	) {
		if prepareForReuse {
			strongTitleLabel.text = ""
			strongSubtitleLabel.text = ""

			titleStackView.removeArrangedSubview(strongTitleLabel)
			titleStackView.removeArrangedSubview(strongSubtitleLabel)
		}

		headerViewHeight = height

		strongTitleLabel = createLabel(text: title)
		strongSubtitleLabel = createLabel(withFont: .systemFont(ofSize: 12), text: subtitle, textColor: .secondaryLabel)
	}

}
