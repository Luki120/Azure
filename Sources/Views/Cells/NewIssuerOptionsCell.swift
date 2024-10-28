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

	private lazy var optionsLabel: UILabel = {
		let label = UILabel()
		label.alpha = 0
		label.transform = .init(scaleX: 0.1, y: 0.1)
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	/// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .clear
		selectionStyle = .none

		layoutUI()
	}

	// ! Private

	private func layoutUI() {
		optionsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		optionsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true	

		setupSizeConstraints(forView: optionsImageView, width: 25, height: 25)

		optionsLabel.centerYAnchor.constraint(equalTo: optionsImageView.centerYAnchor).isActive = true
		optionsLabel.leadingAnchor.constraint(equalTo: optionsImageView.trailingAnchor, constant: 15).isActive = true	
	}

}

extension NewIssuerOptionsCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: NewIssuerOptionsCellViewModel) {
		optionsImageView.image = viewModel.image
		optionsLabel.text = viewModel.text

		UIView.animate(withDuration: 0.5, delay: 0.8, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .transitionCrossDissolve, animations: {
			[self.optionsImageView, self.optionsLabel].forEach {
				$0.alpha = 1
				$0.transform = .init(scaleX: 1, y: 1)
			}
		}) { _ in
			self.optionsImageView.transform = .identity
			self.optionsLabel.transform = .identity
		}
	}

}
