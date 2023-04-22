import UIKit
import UniformTypeIdentifiers

/// Controller that'll show the issuers list
final class IssuersVC: UIViewController {

	private let authManager = AuthManager()
	private let backupManager = BackupManager()
	private let dataSource = IssuersDataSource()

	private var modalSheetVC: ModalSheetVC!

	private(set) var isFiltered = false
	private(set) var filteredIssuers = [Issuer]()
	private(set) var issuersVCView: IssuersVCView!

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		setupDataSource()
		setupObservers()
		setupSearchController()
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	override func loadView() { view = issuersVCView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		setupSortButton()
	}

	// ! Private

	private func setupDataSource() {
		dataSource.issuersVC = self
		dataSource.completion = { [weak self] cell in
			self?.updateSortButtonState()

			guard let cell else { return }

			if UserDefaults.standard.bool(forKey: "copySecretPopoverView") { return }
			self?.initPopoverVC(withSourceView: cell)
			UserDefaults.standard.set(true, forKey: "copySecretPopoverView")
		}
		issuersVCView = .init(dataSource: dataSource, delegate: dataSource, floatingButtonViewDelegate: self)
	}

	private func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(didPurgeData), name: .didPurgeDataNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shouldMakeBackup), name: .shouldMakeBackupNotification, object: nil)
	}

	private func setupSearchController() {
		let searchC = UISearchController()
		searchC.searchResultsUpdater = self
		searchC.obscuresBackgroundDuringPresentation = false

		navigationItem.searchController = searchC
	}

	private func setupSortButton() {
		let pencilImage = UIImage(systemName: "pencil.and.outline", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))

		let sortButtonItem = UIBarButtonItem(
			image: pencilImage,
			style: .plain,
			target: self,
			action: #selector(didTapSortButton)
		)
		navigationItem.rightBarButtonItem = sortButtonItem
	}

	@objc private func didTapSortButton() {
		if issuersVCView.issuersTableView.isEditing {
			issuersVCView.issuersTableView.setEditing(false, animated: true)
		}
		else { issuersVCView.issuersTableView.setEditing(true, animated: true) }
	}

	private func updateSortButtonState() {
		navigationItem.rightBarButtonItem?.isEnabled = IssuerManager.sharedInstance.issuers.count > 0
	}

	// ! NSNotificationCenter

	@objc private func didPurgeData() {
		IssuerManager.sharedInstance.removeAllIssuers()
		issuersVCView.issuersTableView.reloadData()
		updateSortButtonState()
	}

	@objc private func shouldMakeBackup() {
		guard authManager.shouldUseBiometrics() else {
			makeBackup()
			return
		}
		authManager.setupAuth(withReason: .sensitiveOperation) { success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				self.makeBackup()
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
				self.issuersVCView.issuersTableView.reloadData()
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

	// ! PopoverVC

	private func initPopoverVC(withSourceView view: UIView) {
		let popoverVC = PopoverVC()
		popoverVC.preferredContentSize = CGSize(width: 200, height: 40)
		popoverVC.modalPresentationStyle = .popover
		popoverVC.view.layer.cornerCurve = .continuous

		let presentationController = popoverVC.popoverPresentationController
		presentationController?.delegate = self
		presentationController?.sourceView = view
		presentationController?.permittedArrowDirections = .up

		popoverVC.fadeInPopover(withMessage: "Press the cell to save the current secret.")
		present(popoverVC, animated: true)
	}

}

// ! UISearchResultsUpdating

extension IssuersVC: UISearchResultsUpdating {

	func updateSearchResults(for searchController: UISearchController) {
		let searchedString = searchController.searchBar.text
		updateWithFilteredContent(forString: searchedString ?? "")
		issuersVCView.issuersTableView.reloadData()
	}

	func updateWithFilteredContent(forString string: String) {
		let textToSearch = string.trimmingCharacters(in: .whitespacesAndNewlines)
		isFiltered = !textToSearch.isEmpty ? true : false

		filteredIssuers = IssuerManager.sharedInstance.issuers.filter {
			let issuerName = $0.name
			return issuerName.range(of: textToSearch, options: .caseInsensitive) != nil
		}
	}

}

// ! IssuerCellDelegate

extension IssuersVC: IssuerCellDelegate {

	private func fadeInOutToast(forCell cell: IssuerCell) {
		UIPasteboard.general.string = cell.secret
		issuersVCView.toastView.fadeInOutToastView(withMessage: "Copied secret!", finalDelay: 0.2)
	}

	func didTapCell(in issuerCell: IssuerCell) {
		guard authManager.shouldUseBiometrics() else {
			fadeInOutToast(forCell: issuerCell)
			return
		}
		authManager.setupAuth(withReason: .sensitiveOperation) { success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				self.fadeInOutToast(forCell: issuerCell)  
			}
		}
	}

	func didTapInfoButton(in issuerCell: IssuerCell) {
		let message = "Issuer: \(issuerCell.name)"
		issuersVCView.toastView.fadeInOutToastView(withMessage: message, finalDelay: 0.2)
	}

	func shouldFadeInOutToastView(in issuerCell: IssuerCell) {
		issuersVCView.toastView.fadeInOutToastView(withMessage: "Copied code!", finalDelay: 0.2)
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

	func shouldReloadData(in modalSheetVC: ModalSheetVC) { issuersVCView.issuersTableView.reloadData() }

	// ! UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		backupManager.decodeData()

		UIView.transition(with: view, duration: 0.5) {
			self.issuersVCView.issuersTableView.reloadData()
		}
	}

	// ! UIPopoverPresentationControllerDelegate

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

}
