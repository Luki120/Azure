import UIKit
import UniformTypeIdentifiers

/// Controller that'll show the issuers list
final class IssuersVC: UIViewController {

	private let authManager = AuthManager()
	private let backupManager = BackupManager()

	private var issuersView: IssuersView!
	private var modalSheetVC: ModalSheetVC!

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

	override func loadView() { view = issuersView }

	override func viewDidLoad() {
		super.viewDidLoad()
		issuersView.delegate = self
		issuersView.backgroundColor = .systemBackground
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
		modalSheetVC = ModalSheetVC()
		modalSheetVC.delegate = self
		modalSheetVC.configureHeader(isDefaultConfiguration: false, isBackupOptions: true)
		modalSheetVC.setupBackupOptionsDataSource()
		modalSheetVC.modalPresentationStyle = .overFullScreen
		present(modalSheetVC, animated: false)
	}

}

// ! FloatingButtonViewDelegate

extension IssuersVC: FloatingButtonViewDelegate {

	func didTapFloatingButton(in floatingButtonView: FloatingButtonView) {
		modalSheetVC = ModalSheetVC()
		modalSheetVC.delegate = self
		modalSheetVC.configureHeader()
		modalSheetVC.modalPresentationStyle = .overFullScreen

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.present(self.modalSheetVC, animated: false)
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

}

// ! ModalSheetVCDelegate

extension IssuersVC: ModalSheetVCDelegate {

	func didTapLoadBackupCell(in modalSheetVC: ModalSheetVC) {
		if isJailbroken() {
			backupManager.decodeData()
			UIView.transition(with: view, duration: 0.5, animations: {
				self.issuersView.reloadData
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

	func didTapMakeBackupCell(in modalSheetVC: ModalSheetVC) {
		backupManager.encodeData()

		modalSheetVC.configureHeader(isDefaultConfiguration: false, isBackupOptions: false)
		modalSheetVC.setupMakeBackupOptionsDataSource()
		modalSheetVC.animateTableView()
	}

	func didTapViewInFilesOrFilzaCell(in modalSheetVC: ModalSheetVC) {
		let pathToFilza = "filza://view" + .kAzurePath
		let pathToFiles = "shareddocuments://"

		let urlString = isJailbroken() ? pathToFilza : pathToFiles
		guard let backupURLPath = URL(string: urlString) else { return }
		UIApplication.shared.open(backupURLPath)
	}

	func didTapDismissCell(in modalSheetVC: ModalSheetVC) {
		modalSheetVC.shouldDismissVC()
	}

	func shouldReloadData(in modalSheetVC: ModalSheetVC) {
		issuersView.reloadData
	}

}

// ! UIDocumentPickerDelegate

extension IssuersVC: UIDocumentPickerDelegate {

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		backupManager.decodeData()

		UIView.transition(with: view, duration: 0.5) {
			self.issuersView.reloadData
		}
	}

}
