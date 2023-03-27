import UIKit


final class NewIssuerVCView: UIView {

	private var issuerLabel, secretLabel: UILabel!

	private(set) lazy var newIssuerTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.isScrollEnabled = false
		tableView.backgroundColor = .systemBackground
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VanillaCell")
		return tableView
	}()

	private(set) var issuerStackView, secretHashStackView: UIStackView!
	private(set) var algorithmTitleLabel, algorithmLabel: UILabel!
	private(set) var issuerTextField, secretTextField: UITextField!
	private(set) var toastView = ToastView()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/// Designated initializer
	/// - Parameters:
	///     - dataSource: The object that will conform to the table view's data source
	///		- delegate: The object that will conform to the table view's data delegate
	init(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
		super.init(frame: .zero)
		setupUI()
		newIssuerTableView.dataSource = dataSource
		newIssuerTableView.delegate = delegate
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		addSubviews(newIssuerTableView, toastView)

		issuerStackView = setupStackView()
		secretHashStackView = setupStackView()

		issuerLabel = createLabel(withText: "Issuer:")
		secretLabel = createLabel(withText: "Secret hash:")
		algorithmTitleLabel = createLabel(withText: "Algorithm", usesAutoLayout: true)

		issuerTextField = createTextField(withPlaceholder: "For example: GitHub", keyType: .next)
		issuerTextField.becomeFirstResponder()

		secretTextField = createTextField(withPlaceholder: "Enter secret", keyType: .default)

		issuerStackView.addArrangedSubviews(issuerLabel, issuerTextField)
		secretHashStackView.addArrangedSubviews(secretLabel, secretTextField)

		algorithmLabel = createLabel(textColor: .placeholderText, usesAutoLayout: true)
		algorithmLabel.textAlignment = .center
	}

	private func layoutUI() {
		pinViewToAllEdges(newIssuerTableView)
		pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)
	}

	// ! Reusable

	private func createLabel(
		withText text: String? = nil,
		textColor: UIColor = .label,
		usesAutoLayout: Bool = false
	) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.text = text ?? ""
		label.textColor = textColor
		label.translatesAutoresizingMaskIntoConstraints = !usesAutoLayout
		return label
	}

	private func createTextField(withPlaceholder placeholder: String, keyType: UIReturnKeyType) -> UITextField {
		let textField = UITextField()
		textField.font = .systemFont(ofSize: 14)
		textField.delegate = self
		textField.placeholder = placeholder
		textField.returnKeyType = keyType
		return textField
	}

	private func setupStackView() -> UIStackView {
		let stackView = UIStackView()
		stackView.spacing = 10
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}

}

extension NewIssuerVCView {

	// ! Public

	/// Function to setup the cell's subviews & lay them out
	/// - Parameters:
	///     - stackView: The stack view that'll be configured
	///		- textField: The text field that'll be configured
	///		- forCell: The cell object
	func setupSubviews(
		_ stackView: UIStackView,
		_ textField: UITextField,
		forCell cell: UITableViewCell
	) {
		cell.contentView.addSubview(stackView)

		stackView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20).isActive = true
		stackView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true

		setupSizeConstraints(forView: textField, width: cell.frame.width - 43, height: 44)
	}

	/// Function to setup the algorithm labels
	/// - Parameters:
	///		- forCell: The cell object
	func setupAlgorithmLabels(forCell cell: UITableViewCell) {
		cell.accessoryType = .disclosureIndicator
		cell.contentView.addSubviews(algorithmTitleLabel, algorithmLabel)

		algorithmTitleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
		algorithmTitleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true

		algorithmLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15).isActive = true
		algorithmLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
	}

	/// Function to resign the text fields' first responder
	func resignFirstResponders() {
		issuerTextField.resignFirstResponder()
		secretTextField.resignFirstResponder()
	}

}

// ! UITextFieldDelegate

extension NewIssuerVCView: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == issuerTextField {
			textField.resignFirstResponder()
			secretTextField.becomeFirstResponder()
		} else { textField.resignFirstResponder() }

		return true
	}

}
