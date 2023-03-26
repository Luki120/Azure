import UIKit


final class NewIssuerOptionsCell: UITableViewCell {

	static let identifier = "NewIssuerOptionsCell"

	private lazy var optionsImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.transform = .init(scaleX: 0.1, y: 0.1)
		imageView.tintColor = .kAzureMintTintColor
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
		return imageView
	}()

	private lazy var optionsButton: UIButton = {
		let button = UIButton()
		button.alpha = 0
		button.transform = .init(scaleX: 0.1, y: 0.1)
		button.titleLabel?.font = .systemFont(ofSize: 16)
		button.setTitleColor(.label, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(button)
		return button
	}()

	/// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		selectionStyle = .none
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func layoutUI() {
		optionsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		optionsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true	

		setupSizeConstraints(forView: optionsImageView, width: 25, height: 25)

		optionsButton.centerYAnchor.constraint(equalTo: optionsImageView.centerYAnchor).isActive = true
		optionsButton.leadingAnchor.constraint(equalTo: optionsImageView.trailingAnchor, constant: 15).isActive = true	
	}

}

extension NewIssuerOptionsCell {

	// ! Public

	/// Function to configure the cell
	/// - Parameters:
	///		- withImage: An image that represents the image view's image
	///		- title: A String that represents the button's title
	///		- target: An object representing the target for the button
	///		- selector: A Selector object for the button
	func configure(withImage image: UIImage!, title: String, target: Any? = ModalChildView.init(), selector: Selector) {
		optionsImageView.image = image

		optionsButton.setTitle(title, for: .normal)
		optionsButton.addTarget(target, action: selector, for: .touchUpInside)

		UIView.animate(withDuration: 0.5, delay: 0.8, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .transitionCrossDissolve, animations: {
			[self.optionsImageView, self.optionsButton].forEach {
				$0.alpha = 1
				$0.transform = .init(scaleX: 1, y: 1)
			}
		}) { _ in
			self.optionsImageView.transform = .identity
			self.optionsButton.transform = .identity
		}
	}

}
