import UIKit
import UniformTypeIdentifiers

/// Controller that'll show the issuers list
final class IssuersVC: UIViewController {

	private let authManager = AuthManager()
	private let backupManager = BackupManager()

	private var modalSheetVC: ModalSheetVC!
	private var issuersVCView: IssuersVCView!

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		issuersVCView = .init(floatingButtonViewDelegate: self)
		issuersVCView.setupSearchController(for: self)

		setupObservers()
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	override func loadView() { view = issuersVCView }

	override func viewDidLoad() {
		super.viewDidLoad()
		issuersVCView.delegate = self
		issuersVCView.backgroundColor = .systemBackground
	}

	// ! Private

	private func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(didPurgeData), name: .didPurgeDataNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shouldMakeBackup), name: .shouldMakeBackupNotification, object: nil)
	}

	// ! NSNotificationCenter

	@objc private func didPurgeData() {
		IssuerManager.sharedInstance.removeAllIssuers()
		issuersVCView.reloadData
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
		modalSheetVC = ModalSheetVC()
		modalSheetVC.headerView.configure(
			withHeight: 110,
			title: "Backup options",
			subtitle: "Choose between loading a backup from file or making a new one."
		)
		modalSheetVC.setupBackupOptionsDataSource(
			buttonTarget: self,
			selectors: [#selector(didTapLoadBackupButton), #selector(didTapMakeBackupButton)]
		)
		modalSheetVC.modalPresentationStyle = .overFullScreen
		present(modalSheetVC, animated: false)
	}

	// ! ModalSheetVC

	@objc private func didTapLoadBackupButton() {
		if isJailbroken() {
			backupManager.decodeData()
			UIView.transition(with: view, duration: 0.5, animations: {
				self.issuersVCView.reloadData
			}) { _ in
				self.modalSheetVC.shouldDismissVC()
			}
		}
		else {
			modalSheetVC.shouldDismissVC()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				let documentPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
				documentPickerVC.delegate = self
				self.present(documentPickerVC, animated: true)
			}
		}
	}

	@objc private func didTapMakeBackupButton() {
		let subtitle = "Do you want to view your backup in \(isJailbroken() ? "Filza" : "Files") now?"

		backupManager.encodeData()

		modalSheetVC.headerView.configure(
			withHeight: 110,
			title: "Make backup actions",
			subtitle: subtitle,
			prepareForReuse: true
		)
		modalSheetVC.setupMakeBackupOptionsDataSource(
			buttonTarget: self,
			selectors: [#selector(didTapViewInFilesOrFilzaButton), #selector(didTapDismissButton)]
		)

		UIView.transition(with: modalSheetVC.childTableView, duration: 0.35, options: .transitionCrossDissolve) {
			self.modalSheetVC.reloadData()
		}
	}

	@objc private func didTapViewInFilesOrFilzaButton() {
		let pathToFilza = "filza://view" + .kAzurePath
		let pathToFiles = "shareddocuments://"

		let urlString = isJailbroken() ? pathToFilza : pathToFiles
		guard let backupURLPath = URL(string: urlString) else { return }
		UIApplication.shared.open(backupURLPath)
	}

	@objc private func didTapDismissButton() { modalSheetVC.shouldDismissVC() }

}

// ! IssuersVCViewDelegate

extension IssuersVC: IssuersVCViewDelegate {

	func didTapCopyPinCode(in issuersView: IssuersVCView) {
		issuersView.toastView.fadeInOutToastView(withMessage: "Copied code!", finalDelay: 0.2)
	}

	func didTapCopySecret(in issuersView: IssuersVCView) {
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

	func issuersView(_ issuersView: IssuersVCView, didTapDeleteAndPresent alertController: UIAlertController) {
		present(alertController, animated: true)
	}

}

extension IssuersVC: FloatingButtonViewDelegate, ModalSheetVCDelegate, UIDocumentPickerDelegate, UIPopoverPresentationControllerDelegate {

	// ! FloatingButtonViewDelegate

	func didTapFloatingButton(in floatingButtonView: FloatingButtonView) {
		modalSheetVC = ModalSheetVC()
		modalSheetVC.delegate = self
		modalSheetVC.headerView.configure()
		modalSheetVC.modalPresentationStyle = .overFullScreen

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.present(self.modalSheetVC, animated: false)
		}
	}

	// ! ModalSheetVCDelegate

	func shouldReloadData(in modalSheetVC: ModalSheetVC) { issuersVCView.reloadData }

	// ! UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		backupManager.decodeData()

		UIView.transition(with: view, duration: 0.5) {
			self.issuersVCView.reloadData
		}
	}

	// ! UIPopoverPresentationControllerDelegate

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

}
