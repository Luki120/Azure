import UIKit


protocol NewIssuerVCDelegate: AnyObject {
	func shouldDismissVC(in newIssuerVC: NewIssuerVC)
	func shouldPushAlgorithmVC(in newIssuerVC: NewIssuerVC)
}

extension NewIssuerVCDelegate {
	func shouldPushAlgorithmVC(in newIssuerVC: NewIssuerVC) {}
}

/// Controller that'll show the new issuer view
final class NewIssuerVC: UIViewController {

	private let algorithmVC = AlgorithmVC()
	private var newIssuerView: NewIssuerView!

	weak var delegate: NewIssuerVCDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		algorithmVC.delegate = self

		newIssuerView = .init(dataSource: self, delegate: self)

		NotificationCenter.default.addObserver(self, selector: #selector(shouldSaveData), name: .shouldSaveDataNotification, object: nil)
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	override func loadView() { view = newIssuerView }

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
		newIssuerView.resignFirstResponders()
	}

	// ! Private

	private func configureAlgorithmLabel(withSelectedRow row: Int) {
		switch row {
			case 0: newIssuerView.algorithmLabel.text = "SHA1"
			case 1: newIssuerView.algorithmLabel.text = "SHA256"
			case 2: newIssuerView.algorithmLabel.text = "SHA512"
			default: break
		}
	}

	// ! NSNotificationCenter

	@objc private func shouldSaveData() {
		if newIssuerView.issuerTextField.text?.count ?? 0 == 0
			|| newIssuerView.secretTextField.text?.count ?? 0 == 0 {
			newIssuerView.toastView.fadeInOutToastView(withMessage: "Fill out both forms.", finalDelay: 1.5)
			newIssuerView.resignFirstResponders()
			return
		}

		IssuerManager.sharedInstance.feedIssuer(
			withName: newIssuerView.issuerTextField.text ?? "",
			secret: .base32DecodedString(newIssuerView.secretTextField.text ?? "")
		) { isDuplicateItem, issuer in

			guard !isDuplicateItem else {
				newIssuerView.toastView.fadeInOutToastView(withMessage: "Item already exists, updating it now.", finalDelay: 1.5)
				newIssuerView.resignFirstResponders()
				return
			}

			IssuerManager.sharedInstance.issuers.append(issuer)
			delegate?.shouldDismissVC(in: self)

			newIssuerView.issuerTextField.text = ""
			newIssuerView.secretTextField.text = ""
		}
	}

}

// ! AlgorithmVCDelegate

extension NewIssuerVC: AlgorithmVCDelegate {

	func algorithmVC(_ algorithmVC: AlgorithmVC, didUpdateAlgorithmLabelWithSelectedRow row: Int) {
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
				newIssuerView.setupSubviews(newIssuerView.issuerStackView, newIssuerView.issuerTextField, forCell: cell)
			case 1:
				newIssuerView.setupSubviews(newIssuerView.secretHashStackView, newIssuerView.secretTextField, forCell: cell)
			case 2: newIssuerView.setupAlgorithmLabels(forCell: cell)
			default: break
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard indexPath.row == 2 else { return }
		delegate?.shouldPushAlgorithmVC(in: self)
	}

}
