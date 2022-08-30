import UIKit


protocol PinCodeVCDelegate: AnyObject {
	func pinCodeVCShouldDismissVC()
	func pinCodeVCShouldPushAlgorithmVC()
}

extension PinCodeVCDelegate {
	func pinCodeVCShouldPushAlgorithmVC() {}
}

final class PinCodeVC: UIViewController {

	private let algorithmVC = AlgorithmVC()
	private var pinCodeVCView: PinCodeVCView!

	weak var delegate: PinCodeVCDelegate?

	init() {
		super.init(nibName: nil, bundle: nil)
		algorithmVC.delegate = self
		setupMainView()
		pinCodeVCView.pinCodesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "VanillaCell")

		NotificationCenter.default.addObserver(self, selector: #selector(shouldSaveData), name: Notification.Name("checkIfDataShouldBeSaved"), object: nil)
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private func setupMainView() { pinCodeVCView = PinCodeVCView(withDataSource: self, tableViewDelegate: self) }

	override func loadView() { view = pinCodeVCView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureAlgorithmLabel(withSelectedRow: TOTPManager.sharedInstance.selectedRow)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		pinCodeVCView.resignFirstResponderIfNeeded()
	}

	private func configureAlgorithmLabel(withSelectedRow row: Int) {
		switch row {
			case 0: pinCodeVCView.algorithmLabel.text = "SHA1"
			case 1: pinCodeVCView.algorithmLabel.text = "SHA256"
			case 2: pinCodeVCView.algorithmLabel.text = "SHA512"
			default: break
		}
	}

	// MARK: NSNotificationCenter

 	@objc private func shouldSaveData() {
		if pinCodeVCView.issuerTextField.text?.count ?? 0 <= 0
			|| pinCodeVCView.secretTextField.text?.count ?? 0 <= 0 {
			pinCodeVCView.azToastView.fadeInOutToastView(withMessage: "Fill out both forms", finalDelay: 1.5)
			pinCodeVCView.resignFirstResponderIfNeeded()
			return
		}
		TOTPManager.sharedInstance.feedDictionary(
			withObject: pinCodeVCView.issuerTextField.text ?? "",
			andObject: pinCodeVCView.secretTextField.text ?? ""
		)
		delegate?.pinCodeVCShouldDismissVC()

		pinCodeVCView.issuerTextField.text = ""
		pinCodeVCView.secretTextField.text = ""
	}

}

extension PinCodeVC: AlgorithmVCDelegate {
	func algorithmVCDidUpdateAlgorithmLabel(withSelectedRow row: Int) {
		configureAlgorithmLabel(withSelectedRow: row)
	}
}

extension PinCodeVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell", for: indexPath)
		cell.backgroundColor = .clear

		switch indexPath.row {
			case 0:
				cell.contentView.addSubview(pinCodeVCView.issuerStackView)
				pinCodeVCView.configureConstraints(forStackView: pinCodeVCView.issuerStackView, forTextField: pinCodeVCView.issuerTextField, forCell: cell)
			case 1:
				cell.contentView.addSubview(pinCodeVCView.secretHashStackView)
				pinCodeVCView.configureConstraints(forStackView: pinCodeVCView.secretHashStackView, forTextField: pinCodeVCView.secretTextField, forCell: cell)
			case 2:
				cell.accessoryType = .disclosureIndicator
				cell.textLabel?.font = .systemFont(ofSize: 14)
				cell.textLabel?.text = "Algorithm"

				cell.contentView.addSubview(pinCodeVCView.algorithmLabel)
				pinCodeVCView.algorithmLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
				pinCodeVCView.algorithmLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
			default: break
		}

		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard indexPath.row == 2 else { return }
		delegate?.pinCodeVCShouldPushAlgorithmVC()
	}
}
