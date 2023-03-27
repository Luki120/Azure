import UIKit


protocol NewIssuerVCDelegate: AnyObject {
	func newIssuerVCShouldDismissVC()
	func newIssuerVCShouldPushAlgorithmVC()
}

extension NewIssuerVCDelegate {
	func newIssuerVCShouldPushAlgorithmVC() {}
}

/// Controller that'll show the new issuer view
final class NewIssuerVC: UIViewController {

	private let algorithmVC = AlgorithmVC()
	private var newIssuerVCView: NewIssuerVCView!

	weak var delegate: NewIssuerVCDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		algorithmVC.delegate = self

		newIssuerVCView = .init(dataSource: self, delegate: self)

		NotificationCenter.default.addObserver(self, selector: #selector(shouldSaveData), name: .shouldSaveDataNotification, object: nil)
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	override func loadView() { view = newIssuerVCView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureAlgorithmLabel(withSelectedRow: IssuerManager.sharedInstance.selectedRow)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		newIssuerVCView.resignFirstResponders()
	}

	// ! Private

	private func configureAlgorithmLabel(withSelectedRow row: Int) {
		switch row {
			case 0: newIssuerVCView.algorithmLabel.text = "SHA1"
			case 1: newIssuerVCView.algorithmLabel.text = "SHA256"
			case 2: newIssuerVCView.algorithmLabel.text = "SHA512"
			default: break
		}
	}

	// ! NSNotificationCenter

	@objc private func shouldSaveData() {
		if newIssuerVCView.issuerTextField.text?.count ?? 0 == 0
			|| newIssuerVCView.secretTextField.text?.count ?? 0 == 0 {
			newIssuerVCView.toastView.fadeInOutToastView(withMessage: "Fill out both forms.", finalDelay: 1.5)
			newIssuerVCView.resignFirstResponders()
			return
		}

		IssuerManager.sharedInstance.feedIssuer(
			withName: newIssuerVCView.issuerTextField.text ?? "",
			secret: .base32DecodedString(newIssuerVCView.secretTextField.text ?? "")
		) { isDuplicateItem, issuer in

			guard !isDuplicateItem else {
				newIssuerVCView.toastView.fadeInOutToastView(withMessage: "Item already exists, updating it now.", finalDelay: 1.5)
				newIssuerVCView.resignFirstResponders()
				return
			}

			IssuerManager.sharedInstance.issuers.append(issuer)
			delegate?.newIssuerVCShouldDismissVC()

			newIssuerVCView.issuerTextField.text = ""
			newIssuerVCView.secretTextField.text = ""
		}
	}

}

// ! AlgorithmVCDelegate

extension NewIssuerVC: AlgorithmVCDelegate {

	func algorithmVCDidUpdateAlgorithmLabel(withSelectedRow row: Int) {
		configureAlgorithmLabel(withSelectedRow: row)
	}

}

// ! TableView

extension NewIssuerVC: UITableViewDataSource, UITableViewDelegate {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell", for: indexPath)
		cell.backgroundColor = .clear

		switch indexPath.row {
			case 0:
				newIssuerVCView.setupSubviews(newIssuerVCView.issuerStackView, newIssuerVCView.issuerTextField, forCell: cell)
			case 1:
				newIssuerVCView.setupSubviews(newIssuerVCView.secretHashStackView, newIssuerVCView.secretTextField, forCell: cell)
			case 2: newIssuerVCView.setupAlgorithmLabels(forCell: cell)
			default: break
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard indexPath.row == 2 else { return }
		delegate?.newIssuerVCShouldPushAlgorithmVC()
	}

}
