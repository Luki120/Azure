import UIKit
import UniformTypeIdentifiers


final class AzureTableVC: UIViewController {

	private var isFiltered = false
	private var filteredArray = [[String:String]]()
	private var azureTableVCView: AzureTableVCView!
	private var authManager: AuthManager!
	private var backupManager: BackupManager!
	private var modalSheetVC: ModalSheetVC!

	init() {
		super.init(nibName: nil, bundle: nil)
		setupMainView()
		setupObservers()
		setupSearchController()

		authManager = AuthManager()
		backupManager = BackupManager()
		azureTableVCView.azureTableView.register(AzurePinCodeCell.self, forCellReuseIdentifier: .kIdentifier)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	private func setupMainView() {
		azureTableVCView = AzureTableVCView(dataSource: self, tableViewDelegate: self, floatingButtonViewDelegate: self)
	}

	private func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(purgeData), name: Notification.Name("purgeDataDone"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shouldMakeBackup), name: Notification.Name("makeBackup"), object: nil)
	}

	private func setupSearchController() {
		let searchC = UISearchController()
		searchC.searchResultsUpdater = self
		searchC.obscuresBackgroundDuringPresentation = true

		definesPresentationContext = true
		extendedLayoutIncludesOpaqueBars = true
		navigationItem.searchController = searchC
	}

	override func loadView() { view = azureTableVCView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= view.safeAreaInsets.bottom + 60 {
			azureTableVCView.azureFloatingButtonView.animateView(withAlpha: 0, translateX: 1, translateY: 100)
		}
		else { azureTableVCView.azureFloatingButtonView.animateView(withAlpha: 1, translateX: 1, translateY: 1) }
	}

	// ! NSNotificationCenter

	@objc private func purgeData() {
		TOTPManager.sharedInstance.removeAllObjectsFromArray()
		azureTableVCView.azureTableView.reloadData()
	}

	@objc private func shouldMakeBackup() {
		guard authManager.shouldUseBiometrics() else {
			makeBackup()
			return
		}
		authManager.setupAuth(withReason: .kAzureReasonSensitiveOperation, reply: { success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				self.makeBackup()
			}
		})
	}

	private func makeBackup() {
		modalSheetVC = ModalSheetVC()
		modalSheetVC.setupChildWithTitle("Backup Options",
			subtitle: "Choose between loading a backup from file or making a new one.",
			buttonTitle: "Load Backup",
			forTarget: self,
			forSelector: #selector(didTapLoadBackupButton),
			secondButtonTitle: "Make Backup",
			forTarget: self,
			forSelector: #selector(didTapMakeBackupButton), 
			accessoryImage: UIImage(systemName: "square.and.arrow.down") ?? UIImage(), 
			secondAccessoryImage: UIImage(systemName: "square.and.arrow.up") ?? UIImage(),
			prepareForReuse: false,
			scaleAnimation: true
		)
		modalSheetVC.modalPresentationStyle = .overFullScreen
		present(modalSheetVC, animated: false)
	}

	// ! ModalSheetVC

	@objc private func didTapLoadBackupButton() {
		if backupManager.isJailbroken() {
			backupManager.makeDataOutOfJSON()
			UIView.transition(with: view, duration: 0.5, animations: {
				self.azureTableVCView.azureTableView.reloadData()
			}, completion: { _ in
				self.modalSheetVC.shouldDismissVC()
			})
		}
		else {
			modalSheetVC.shouldDismissVC()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				let utType = [UTType.json]
				let documentPickerVC = UIDocumentPickerViewController(forOpeningContentTypes: utType)
				documentPickerVC.delegate = self
				self.present(documentPickerVC, animated: true)
			}
		}
	}

	@objc private func didTapMakeBackupButton() {
		let subtitle = "Do you want to view your backup in \(backupManager.isJailbroken() ? "Filza" : "Files") now?"

		backupManager.makeJSONOutOfData()
		modalSheetVC.shouldCrossDissolveChildSubviews()
		modalSheetVC.setupChildWithTitle("Make backup actions",
			subtitle: subtitle,
			buttonTitle: "Yes",
			forTarget: self,
			forSelector: #selector(didTapViewInFilesOrFilzaButton),
			secondButtonTitle: "Later",
			forTarget: self,
			forSelector: #selector(didTapDismissButton), 
			accessoryImage: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(), 
			secondAccessoryImage: UIImage(systemName: "xmark.circle.fill") ?? UIImage(),
			prepareForReuse: true,
			scaleAnimation: false
		)

	}

	@objc private func didTapViewInFilesOrFilzaButton() {
		let pathToFilza = "filza://view" + .kAzurePath
		let pathToFiles = "shareddocuments://"

		let urlString = backupManager.isJailbroken() ? pathToFilza : pathToFiles
		guard let backupURLPath = URL(string: urlString) else { return }
		UIApplication.shared.open(backupURLPath)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
			self.modalSheetVC.shouldDismissVC()
		})
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


extension AzureTableVC: UISearchControllerDelegate, UISearchResultsUpdating {

	// ! UISearchResultsUpdating

	func updateSearchResults(for searchController: UISearchController) {
		let searchedString = searchController.searchBar.text
		updateWithFilteredContent(forString: searchedString ?? "")
		azureTableVCView.azureTableView.reloadData()
	}

	func updateWithFilteredContent(forString string: String) {
		let textToSearch = string.trimmingCharacters(in: .whitespacesAndNewlines)
		isFiltered = !textToSearch.isEmpty ? true : false

		filteredArray = TOTPManager.sharedInstance.entriesArray.filter { dict in
			if let issuer = (dict as AnyObject).object(forKey: "Issuer") as? String {
				return issuer.range(of: textToSearch, options: .caseInsensitive) != nil
			}
			return false
		}
	}

}


extension AzureTableVC: AzurePinCodeCellDelegate, UITableViewDataSource, UITableViewDelegate {

	// ! AzurePinCodeCellDelegate

	private func fadeInOutToast(forCell cell: AzurePinCodeCell) {
		let pasteboard = UIPasteboard.general
		pasteboard.string = cell.hashString
		azureTableVCView.azureToastView.fadeInOutToastView(withMessage: "Copied secret!", finalDelay: 0.2)
	}

	func azurePinCodeCellDidTapCell(_ cell: AzurePinCodeCell) {
		guard authManager.shouldUseBiometrics() else {
			fadeInOutToast(forCell: cell)
			return
		}
		authManager.setupAuth(withReason: .kAzureReasonSensitiveOperation, reply: { success, _ in
			DispatchQueue.main.async {
				guard success else { return }
				self.fadeInOutToast(forCell: cell)	
			}
		})
	}

	func azurePinCodeCellDidTapInfoButton(_ cell: AzurePinCodeCell) {
		let message = "Issuer: \(cell.issuer)"
		azureTableVCView.azureToastView.fadeInOutToastView(withMessage: message, finalDelay: 0.2)
	}

	func azurePinCodeCellShouldFadeInOutToastView() {
		azureTableVCView.azureToastView.fadeInOutToastView(withMessage: "Copied!", finalDelay: 0.2)
	}

	// ! UITableViewDataSource

	private func setupDataSource(
		forArray array: [[String:String]],
		at indexPath: IndexPath,
		forCell cell: AzurePinCodeCell
	) {
		let source = array[indexPath.row] as AnyObject
		cell.issuer = source.object(forKey: "Issuer") as? String ?? ""
		cell.hashString = source.object(forKey: "Secret") as? String ?? ""
		cell.setSecret(
			source.object(forKey: "Secret") as? String ?? "", 
			withAlgorithm: source.object(forKey: "encryptionType") as? String ?? "",
			withTransition: false
		)

	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		azureTableVCView.animateViewsWhenNecessary()
		return isFiltered ? filteredArray.count : TOTPManager.sharedInstance.entriesArray.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: .kIdentifier, for: indexPath) as? AzurePinCodeCell else {
			return UITableViewCell()
		}
		cell.delegate = self
		cell.backgroundColor = .clear
		if isFiltered { setupDataSource(forArray: filteredArray, at: indexPath, forCell: cell) }
		else {
			setupDataSource(forArray: TOTPManager.sharedInstance.entriesArray, at: indexPath, forCell: cell)
		}
		let image = TOTPManager.sharedInstance.imagesDict[cell.issuer.lowercased()]
		let resizedImage = image?.resizeImage(image ?? UIImage(), withSize: CGSize(width: 30, height: 30))
		let placeholderImage = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)
		cell.issuerImageView.image = image != nil ? resizedImage : placeholderImage
		cell.issuerImageView.tintColor = image != nil ? nil : .kAzureMintTintColor

		let defaults = UserDefaults.standard
		if defaults.bool(forKey: "copySecretPopoverView") { return cell }
		initPopoverVC(withSourceView: cell)
		defaults.set(true, forKey: "copySecretPopoverView")

		return cell

	}

	// ! UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete", handler: { _, _, completion in
			let source = TOTPManager.sharedInstance.entriesArray[indexPath.row] as AnyObject
			let issuerName = source.object(forKey: "Issuer") as? String ?? ""
			let message = "You're about to delete the code for the issuer named \(issuerName) ❗❗. Are you sure you want to proceed? You'll have to set the code again if you wished to."
			let alertController = UIAlertController(title: "Azure", message: message, preferredStyle: .alert)

			let confirmAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
				TOTPManager.sharedInstance.removeObject(at: indexPath)
				self.azureTableVCView.azureTableView.deleteRows(at: [indexPath], with: .fade)

				completion(true)
			})
			let dismissAction = UIAlertAction(title: "Oops", style: .default, handler: { _ in
				completion(true)
			})

			alertController.addAction(confirmAction)
			alertController.addAction(dismissAction)
			self.present(alertController, animated: true)
		})

		action.backgroundColor = .kAzureMintTintColor

		let actions = UISwipeActionsConfiguration(actions: [action])
		return actions
	}

}


extension AzureTableVC: AzureFloatingButtonViewDelegate, ModalSheetVCDelegate, UIDocumentPickerDelegate, UIPopoverPresentationControllerDelegate {

	// ! AzureFloatingButtonViewDelegate

	func azureFloatingButtonViewDidTapFloatingButton() {
		modalSheetVC = ModalSheetVC()
		modalSheetVC.delegate = self
		modalSheetVC.setupChildWithTitle("Add issuer",
			subtitle: "Add an issuer by scanning a QR code, importing a QR image or entering the secret manually.",
			buttonTitle: "Scan QR Code",
			forTarget: modalSheetVC,
			forSelector: #selector(modalSheetVC.modalChildViewDidTapScanQRCodeButton),
			secondButtonTitle: "Import QR Image",
			forTarget: modalSheetVC,
			forSelector: #selector(modalSheetVC.modalChildViewDidTapImportQRImageButton),
			thirdStackView: true,
			thirdButtonTitle: "Enter Manually",
			forTarget: modalSheetVC,
			forSelector: #selector(modalSheetVC.modalChildViewDidTapEnterManuallyButton),
			accessoryImage: UIImage(systemName: "qrcode") ?? UIImage(),
			secondAccessoryImage: UIImage(systemName: "square.and.arrow.up") ?? UIImage(),
			thirdAccessoryImage: UIImage(systemName: "square.and.pencil") ?? UIImage(),
			prepareForReuse: false,
			scaleAnimation: true
		)
		modalSheetVC.modalPresentationStyle = .overFullScreen
		present(modalSheetVC, animated: false)
	}

	// ! ModalSheetVCDelegate

	func modalSheetVCShouldReloadData() { azureTableVCView.azureTableView.reloadData() }

	// ! UIDocumentPickerDelegate

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		backupManager.makeDataOutOfJSON()
		UIView.transition(with: view, duration: 0.5, animations: {
			self.azureTableVCView.azureTableView.reloadData()
		})
	}

	// ! UIPopoverPresentationControllerDelegate

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

}
