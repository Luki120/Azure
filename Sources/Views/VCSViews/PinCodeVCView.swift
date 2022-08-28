import UIKit


final class PinCodeVCView: UIView {

	var issuerStackView: UIStackView!
	var secretHashStackView: UIStackView!
	var algorithmLabel: UILabel!
	var issuerTextField: UITextField!
	var secretTextField: UITextField!
	var pinCodesTableView: UITableView!
	var azToastView: AzureToastView!

	private var issuerLabel: UILabel!
	private var secretLabel: UILabel!

	init(withDataSource dataSource: UITableViewDataSource, tableViewDelegate: UITableViewDelegate) {
		super.init(frame: .zero)
		setupUI()
		pinCodesTableView.dataSource = dataSource
		pinCodesTableView.delegate = tableViewDelegate
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	private func setupUI() {
		pinCodesTableView = UITableView(frame: .zero, style: .grouped)
		pinCodesTableView.backgroundColor = .systemBackground
		addSubview(pinCodesTableView)

		issuerStackView = setupStackView()
		secretHashStackView = setupStackView()

		issuerLabel = createLabel(withText: "Issuer", textColor: .label)
		secretLabel = createLabel(withText: "Secret hash:", textColor: .label)

		issuerTextField = createTextField(withPlaceholder: "For example: GitHub", keyType: .next)
		secretTextField = createTextField(withPlaceholder: "Enter secret", keyType: .default)

		issuerTextField.becomeFirstResponder()

		issuerStackView.addArrangedSubview(issuerLabel)
		issuerStackView.addArrangedSubview(issuerTextField)
		secretHashStackView.addArrangedSubview(secretLabel)
		secretHashStackView.addArrangedSubview(secretTextField)

		azToastView = AzureToastView()
		addSubview(azToastView)

		algorithmLabel = createLabel(textColor: .placeholderText)
		algorithmLabel.textAlignment = .center
		algorithmLabel.translatesAutoresizingMaskIntoConstraints = false

	}

	private func layoutUI() {
		pinViewToAllEdges(pinCodesTableView)
		pinAzureToastToTheBottomCenteredOnTheXAxis(azToastView, bottomConstant: -5)
	}

	// MARK: Reusable

	private func createLabel(withText text: String? = nil, textColor: UIColor) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.text = text ?? ""
		label.textColor = textColor
		return label
	}

	private func createTextField(withPlaceholder placeholder: String, keyType: UIReturnKeyType) -> UITextField {
		let textField = UITextField()
		textField.font = .systemFont(ofSize: 14)
		textField.delegate = self
		textField.placeholder = placeholder
		textField.returnKeyType = keyType
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}

	private func setupStackView() -> UIStackView {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 10
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}

}

extension PinCodeVCView {
	// MARK: Public

	func configureConstraints(
		forStackView stackView: UIStackView,
		forTextField textField: UITextField,
		forCell cell: UITableViewCell
	) {
		stackView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15).isActive = true
		stackView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
		textField.widthAnchor.constraint(equalToConstant: cell.frame.width - 43).isActive = true
		textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
	}

	func resignFirstResponderIfNeeded() {
		issuerTextField.resignFirstResponder()
		secretTextField.resignFirstResponder()
	}
}

extension PinCodeVCView: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == issuerTextField {
			textField.resignFirstResponder()
			secretTextField.becomeFirstResponder()
		} else { textField.resignFirstResponder() }

		return true
	}

}
