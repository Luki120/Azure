import UIKit
import UniformTypeIdentifiers

/// Controller that'll show the issuers list
final class IssuersVC: UIViewController {

	private let authManager = AuthManager()
	private let backupManager = BackupManager()

	private var continueAction: UIAlertAction!
	private var issuersView: IssuersView!
	private var newIssuerOptionsVC: NewIssuerOptionsVC!

	private var isEncrypted = false
	private var password = ""

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		issuersView = .init(floatingButtonViewDelegate: self)
		issuersView.setupSearchController(for: self)

		setupObservers()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		issuersView.delegate = self
		issuersView.backgroundColor = .systemBackground
		view.addSubview(issuersView)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		view.pinViewToAllEdgesIncludingSafeAreas(issuersView)
	}

	// ! Private

	private func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(didPurgeData), name: .didPurgeDataNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shouldMakeBackup), name: .shouldMakeBackupNotification, object: nil)
	}

	// ! NotificationCenter

	@objc private func didPurgeData() {
		IssuerManager.sharedInstance.removeAllIssuers()
		issuersView.reloadData
	}

	@objc private func shouldMakeBackup() {
		guard authManager.shouldUseBiometrics() else {
			makeBackup()
			return
		}
		authManager.setupAuth(withReason: .sensitiveOperation) { [weak self] success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				self?.makeBackup()
			}
		}
	}

	private func makeBackup() {
		newIssuerOptionsVC = NewIssuerOptionsVC()
		newIssuerOptionsVC.delegate = self
		newIssuerOptionsVC.configureHeader(isDefaultConfiguration: false, isBackupOptions: true)
		newIssuerOptionsVC.setupBackupOptionsDataSource()
		newIssuerOptionsVC.modalPresentationStyle = .overFullScreen
		present(newIssuerOptionsVC, animated: false)
	}

	private func presentInitialAlertController(isEncrypting: Bool = true, completion: @escaping () -> Void) {
		let message = isEncrypting ? "Do you want to encrypt your data?" : "Did you encrypt your backup?"
		let alertController = UIAlertController(title: "Azure", message: message, preferredStyle: .alert)

		let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
			completion()
			self.isEncrypted = true
		}

		let noAction = UIAlertAction(title: "No", style: .default) { _ in
			if isEncrypting {
				self.backupManager.encodeData()
				self.configureNewIssuerOptionsHeader()
			}
			else {
				if isJailbroken() {
					self.backupManager.decodeData()
					self.transitionIssuersView()
				}
				else {
					self.didPresentDocumentPickerVC()
				}
			}

			self.isEncrypted = false
		}

		alertController.addAction(yesAction)
		alertController.addAction(noAction)

		presentedViewController?.present(alertController, animated: true)
	}

	private func presentAlertController(isMakingBackup: Bool = true, completion: @escaping (String) -> Void) {
		let message = isMakingBackup ? backupManager.makeBackupMessage : backupManager.loadBackupMessage

		let alertController = UIAlertController(title: "Azure", message: message, preferredStyle: .alert)

		alertController.addTextField { textField in
			textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		}

		continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
			completion(alertController.textFields?.first?.text ?? "")
		}
		continueAction.isEnabled = false

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		alertController.addAction(continueAction)
		alertController.addAction(cancelAction)

		presentedViewController?.present(alertController, animated: true)
	}

	@objc private func textFieldDidChange(_ textField: UITextField) {
		continueAction.isEnabled = textField.text?.count ?? 0 >= 8
	}

	// ! Reusable

	private func configureNewIssuerOptionsHeader() {
		newIssuerOptionsVC.configureHeader(isDefaultConfiguration: false, isBackupOptions: false)
		newIssuerOptionsVC.setupMakeBackupOptionsDataSource()
		newIssuerOptionsVC.animateTableView()
	}

	private func didPresentDocumentPickerVC() {
		newIssuerOptionsVC.shouldDismissVC()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			let documentPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
			documentPickerVC.delegate = self
			self.present(documentPickerVC, animated: true)
		}
	}

	private func transitionIssuersView() {
		UIView.transition(with: view, duration: 0.5, animations: {
			self.issuersView.reloadData
		}) { _ in
			self.newIssuerOptionsVC.shouldDismissVC()
		}
	}

}

// ! FloatingButtonViewDelegate

extension IssuersVC: FloatingButtonViewDelegate {

	func didTapFloatingButton(in floatingButtonView: FloatingButtonView) {
		newIssuerOptionsVC = NewIssuerOptionsVC()
		newIssuerOptionsVC.delegate = self
		newIssuerOptionsVC.configureHeader()
		newIssuerOptionsVC.modalPresentationStyle = .overFullScreen

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.present(self.newIssuerOptionsVC, animated: false)
		}
	}

}

// ! IssuersViewDelegate

extension IssuersVC: IssuersViewDelegate {

	func didTapCopyPinCode(in issuersView: IssuersView) {
		issuersView.toastView.fadeInOutToastView(withMessage: "Copied code!", finalDelay: 0.2)
	}

	func didTapCopySecret(in issuersView: IssuersView) {
		guard authManager.shouldUseBiometrics() else {
			issuersView.toastView.fadeInOutToastView(withMessage: "Copied secret!", finalDelay: 0.2)
			return
		}
		authManager.setupAuth(withReason: .sensitiveOperation) { success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				issuersView.toastView.fadeInOutToastView(withMessage: "Copied secret!", finalDelay: 0.2) 
			}
		}
	}

	func issuersView(_ issuersView: IssuersView, didTapDeleteAndPresent alertController: UIAlertController) {
		present(alertController, animated: true)
	}

	func issuersView(_ issuersView: IssuersView, didTapAddToSystemAndOpen url: URL) {
		UIApplication.shared.open(url)
	}

	func issuersView(_ issuersView: IssuersView, didPresent alertController: UIAlertController) {
		present(alertController, animated: true)
	}

}

// ! NewIssuerOptionsVCDelegate

extension IssuersVC: NewIssuerOptionsVCDelegate {

	func didTapLoadBackupCell(in newIssuerOptionsVC: NewIssuerOptionsVC) {
		if isJailbroken() {
			presentInitialAlertController(isEncrypting: false) {
				self.presentAlertController(isMakingBackup: false) { [weak self] password in
					guard let self else { return }

					backupManager.decodeData(withPassword: password, isEncrypted: true)
					self.transitionIssuersView()
				}
			}
		}
		else {
			presentInitialAlertController(isEncrypting: false) {
				self.presentAlertController(isMakingBackup: false) { [weak self] password in
					guard let self else { return }
					self.password = password

					self.didPresentDocumentPickerVC()
				}
			}
		}
	}

	func didTapMakeBackupCell(in newIssuerOptionsVC: NewIssuerOptionsVC) {
		presentInitialAlertController {
			self.presentAlertController { [weak self] password in
				guard let self else { return }

				backupManager.encodeData(withPassword: password, encrypt: true)
				self.configureNewIssuerOptionsHeader()
			}
		}
	}

	func didTapViewInFilesOrFilzaCell(in newIssuerOptionsVC: NewIssuerOptionsVC) {
		let pathToFilza = "filza://view" + backupManager.kBackupsPathURL.path
		let pathToFiles = "shareddocuments://"

		let urlString = isJailbroken() ? pathToFilza : pathToFiles
		guard let backupURLPath = URL(string: urlString) else { return }
		UIApplication.shared.open(backupURLPath)
	}

	func didTapDismissCell(in newIssuerOptionsVC: NewIssuerOptionsVC) {
		newIssuerOptionsVC.shouldDismissVC()
	}

	func shouldReloadData(in newIssuerOptionsVC: NewIssuerOptionsVC) {
		issuersView.reloadData
	}

}

// ! UIDocumentPickerDelegate

extension IssuersVC: UIDocumentPickerDelegate {

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		backupManager.decodeData(withPassword: password, isEncrypted: isEncrypted)

		UIView.transition(with: view, duration: 0.5) {
			self.issuersView.reloadData
		}
	}

}
