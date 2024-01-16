import UIKit

/// Class to represent the new issuer form cell
final class NewIssuerFormCell: UITableViewCell {

	static let identifier = "NewIssuerFormCell"

	private lazy var cleanTextField: UITextField = {
		let textField = UITextField()
		textField.font = .systemFont(ofSize: 16)
		textField.delegate = self
		textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 20, height: textField.frame.size.height))
		textField.leftViewMode = .always
		addSubview(textField)
		return textField
	}()

	var completion: ((String) -> Void)?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		backgroundColor = .clear
		contentView.backgroundColor = .secondarySystemGroupedBackground

		NotificationCenter.default.addObserver(self, selector: #selector(resignResponder), name: .shouldResignResponderNotification, object: nil)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(cleanTextField)

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

	@objc private func resignResponder() {
		cleanTextField.resignFirstResponder()
	}

}

extension NewIssuerFormCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: NewIssuerFormCellViewModel) {
		cleanTextField.tag = viewModel.tag
		cleanTextField.placeholder = viewModel.placeholder
		cleanTextField.returnKeyType = viewModel.returnKeyType
	}

}

// ! UITextFieldDelegate

extension NewIssuerFormCell: UITextFieldDelegate {

	func textFieldDidEndEditing(_ textField: UITextField) {
		completion?(textField.text ?? "")
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let nextTextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField else {
			textField.resignFirstResponder()
			return false
		}

		nextTextField.becomeFirstResponder()
		return true
	}

}
