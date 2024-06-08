import UIKit

/// Class to represent the new issuer form cell
final class NewIssuerFormCell: UITableViewCell {

	static let identifier = "NewIssuerFormCell"

	private lazy var cleanTextField: UITextField = {
		let textField = UITextField()
		textField.font = .systemFont(ofSize: 16)
		textField.delegate = self
		textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 20, height: textField.frame.size.height))
		textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 20, height: textField.frame.size.height))
		textField.leftViewMode = .always
		textField.rightViewMode = .always
		textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		contentView.addSubview(textField)
		return textField
	}()

	private lazy var clearAllButton: UIButton = {
		let button = UIButton()
		if #available(iOS 15.0, *) {
			var configuration: UIButton.Configuration = .plain()
			configuration.image = UIImage(systemName: "xmark.circle.fill") ?? UIImage()
			configuration.baseForegroundColor = kUserInterfaceStyle == .dark ? .tertiarySystemBackground : .lightColor
			button.configuration = configuration
		}
		else {
			let configuration = UIImage.SymbolConfiguration(pointSize: 20)

			button.tintColor = kUserInterfaceStyle == .dark ? .tertiarySystemBackground : .lightColor
			button.setImage(.init(systemName: "xmark.circle.fill", withConfiguration: configuration) ?? UIImage(), for: .normal)
		}
		button.alpha = 0
		button.addAction(
			UIAction { [weak self] _ in
				guard let self else { return }
				UIView.transition(with: button, duration: 0.35, options: .transitionCrossDissolve) {
					button.alpha = 0
					self.cleanTextField.text = ""
				}
			},
			for: .touchUpInside
		)
		button.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(button)
		return button
	}()

	var completion: ((String) -> Void)?
	var textField: UITextField { return cleanTextField }

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
		layoutUI()

		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 14
		contentView.layer.masksToBounds = true
		setupCleanShadowLayer(withBackgroundColor: UIColor.secondarySystemGroupedBackground.cgColor)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		layer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor

		if #available(iOS 15.0, *) {
			clearAllButton.configuration?.baseForegroundColor = kUserInterfaceStyle == .dark ? .tertiarySystemBackground : .lightColor
		}
		else {
			clearAllButton.tintColor = kUserInterfaceStyle == .dark ? .tertiarySystemBackground : .lightColor
		}
	}

	// ! Private

	private func layoutUI() {
		contentView.pinViewToAllEdges(cleanTextField)		

		clearAllButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		clearAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true

		setupSizeConstraints(forView: clearAllButton, width: 30, height: 30)
	}

	@objc private func resignResponder() {
		cleanTextField.resignFirstResponder()
	}

	@objc private func textFieldDidChange(_ textField: UITextField) {
		guard let text = textField.text else { return }

		UIView.transition(with: clearAllButton, duration: 0.35, options: .transitionCrossDissolve) {
			self.clearAllButton.alpha = text.count > 0 ? 1 : 0
		}
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

	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField.text?.count ?? 0 > 1 {
			UIView.transition(with: clearAllButton, duration: 0.35, options: .transitionCrossDissolve) {
				self.clearAllButton.alpha = 1
			}
		}
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.transition(with: clearAllButton, duration: 0.35, options: .transitionCrossDissolve) {
			self.clearAllButton.alpha = 0
		}
		completion?(textField.text ?? "")
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let nextTextField = textField.superview?.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField else {
			textField.resignFirstResponder()
			return false
		}

		nextTextField.becomeFirstResponder()
		return true
	}

	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {

		guard textField.tag == 2, let text = textField.text, let range = Range(range, in: text) else { return true }

		if string.count > 1 {
			UIView.transition(with: clearAllButton, duration: 0.35, options: .transitionCrossDissolve) {
				self.clearAllButton.alpha = 1
			}
		}

		let strippedText = string.replacingOccurrences(of: " ", with: "")
		if strippedText == string { return true }

		textField.text = text.replacingCharacters(in: range, with: strippedText)

		DispatchQueue.main.async {
			let endPosition = textField.endOfDocument
			let selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
			textField.selectedTextRange = selectedTextRange
		}

		return false
	}

}
