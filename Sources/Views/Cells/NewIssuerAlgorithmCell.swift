import UIKit


protocol NewIssuerAlgorithmCellDelegate: AnyObject {
	func didChangeSelectedIndex(_ index: Int)
}

/// Class to represent the new issuer algorithm cell
final class NewIssuerAlgorithmCell: UITableViewCell {

	static let identifier = "NewIssuerAlgorithmCell"

	private var items = [String]()

	private lazy var algorithmLabel: UILabel = {
		let label = UILabel()
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	private lazy var algorithmSegmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: items)
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.addTarget(self, action: #selector(didChangeSelectedIndex(_:)), for: .valueChanged)
		contentView.addSubview(segmentedControl)
		return segmentedControl
	}()

	weak var delegate: NewIssuerAlgorithmCellDelegate?

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		backgroundColor = .clear
		contentView.backgroundColor = .secondarySystemGroupedBackground
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()

		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 14
		contentView.layer.masksToBounds = true
		setupCleanShadowLayer(withBackgroundColor: UIColor.secondarySystemGroupedBackground.cgColor)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		layer.backgroundColor = UIColor.secondarySystemGroupedBackground.cgColor
		layer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor
	}

	// ! Private

	private func layoutUI() {
		NSLayoutConstraint.activate([
			algorithmLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			algorithmLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			algorithmLabel.trailingAnchor.constraint(equalTo: algorithmSegmentedControl.leadingAnchor, constant: -20),

			algorithmSegmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			algorithmSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		])
	}

	@objc private func didChangeSelectedIndex(_ sender: UISegmentedControl) {
		delegate?.didChangeSelectedIndex(sender.selectedSegmentIndex)
	}

}

extension NewIssuerAlgorithmCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: NewIssuerAlgorithmCellViewModel) {
		items = viewModel.items

		algorithmLabel.text = viewModel.algorithmText
		algorithmSegmentedControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
	}

}
