import PhotosUI
import UIKit


protocol NewIssuerOptionsVCDelegate: AnyObject {
	func didTapLoadBackupCell(in newIssuerOptionsVC: NewIssuerOptionsVC)
	func didTapMakeBackupCell(in newIssuerOptionsVC: NewIssuerOptionsVC)
	func didTapViewInFilesOrFilzaCell(in newIssuerOptionsVC: NewIssuerOptionsVC)
	func didTapDismissCell(in newIssuerOptionsVC: NewIssuerOptionsVC)
	func shouldReloadData(in newIssuerOptionsVC: NewIssuerOptionsVC)
}

/// Controller that'll show the modal sheet view
final class NewIssuerOptionsVC: UIViewController {

	private let newIssuerOptionsView = NewIssuerOptionsView()
	private let newIssuerVC = NewIssuerVC()
	private let toastView = ToastView()

	private var navVC: UINavigationController!

	weak var delegate: NewIssuerOptionsVCDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		newIssuerOptionsView.delegate = self
		newIssuerVC.delegate = self

		view.backgroundColor = .clear
	}

	override func loadView() { view = newIssuerOptionsView }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		newIssuerOptionsView.animateViews()
	}

	// ! Reusable funcs

	private func configureVC(
		_ vc: UIViewController,
		withTitle title: String,
		withItemImage image: UIImage,
		forSelector selector: Selector,
		isLeftBarButtonItem: Bool
	) {
		navVC = UINavigationController(rootViewController: vc)
		vc.title = title
		if isLeftBarButtonItem {
			vc.navigationItem.leftBarButtonItem = .getBarButtomItem(withImage: image, target: self, selector: selector)
		}
		else {
			vc.navigationItem.rightBarButtonItem = .getBarButtomItem(withImage: image, target: self, selector: selector)
		}
		navVC.modalTransitionStyle = .crossDissolve
		navVC.modalPresentationStyle = .fullScreen
	}

	private func dismissVC() {
		dismiss(animated: true, completion: nil)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			self.newIssuerOptionsView.animateDismiss { [weak self] _ in
				self?.dismiss(animated: true)
			}
		}
	}

}

// ! NewIssuerOptionsViewDelegate

extension NewIssuerOptionsVC: NewIssuerOptionsViewDelegate {

	func didTapScanQRCodeCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		let qrCodeVC = QRCodeVC()
		qrCodeVC.delegate = self

		configureVC(
			qrCodeVC,
			withTitle: "Scan QR Code",
			withItemImage: UIImage(systemName: "xmark.circle.fill") ?? UIImage(),
			forSelector: #selector(didTapDismissButton),
			isLeftBarButtonItem: true
		)
		present(navVC, animated: true)
	}

	func didTapImportQRImageCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		var configuration = PHPickerConfiguration()
		configuration.filter = PHPickerFilter.images

		let phPickerVC = PHPickerViewController(configuration: configuration)
		phPickerVC.delegate = self
		present(phPickerVC, animated: true)

		keyWindow.addSubview(toastView)
		keyWindow.pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)
	}

	func didTapEnterManuallyCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		configureVC(
			newIssuerVC,
			withTitle: "Enter QR Code",
			withItemImage: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(),
			forSelector: #selector(didTapComposeButton),
			isLeftBarButtonItem: false
		)
		newIssuerVC.navigationItem.leftBarButtonItem = .getBarButtomItem(
			withImage: UIImage(systemName: "xmark.circle.fill") ?? UIImage(),
			target: self,
			selector: #selector(didTapDismissButton)
		)
		present(navVC, animated: true)
	}

	func didTapLoadBackupCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		delegate?.didTapLoadBackupCell(in: self)
	}

	func didTapMakeBackupCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		delegate?.didTapMakeBackupCell(in: self)
	}

	func didTapViewInFilesOrFilzaCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		delegate?.didTapViewInFilesOrFilzaCell(in: self)
	}

	func didTapDismissCell(in newIssuerOptionsView: NewIssuerOptionsView) {
		delegate?.didTapDismissCell(in: self)
	}

	func didTapDimmedView(in newIssuerOptionsView: NewIssuerOptionsView) {
		newIssuerOptionsView.animateDismiss { [weak self] _ in
			self?.dismiss(animated: true)
		}
	}

	func newIssuerOptionsView(
		_ newIssuerOptionsView: NewIssuerOptionsView,
		didPanWithGesture gesture: UIPanGestureRecognizer,
		modifyingConstraint constraint: NSLayoutConstraint
	) {
		let translation = gesture.translation(in: view)
		let newHeight = newIssuerOptionsView.currentSheetHeight - translation.y

		switch gesture.state {
			case .changed:
				if newHeight < newIssuerOptionsView.kDefaultHeight {
					constraint.constant = newHeight
					constraint.isActive = true

					newIssuerOptionsView.calculateAlpha(basedOnTranslation: translation)
					view.layoutIfNeeded()
				}
			case .ended:
				if newHeight < newIssuerOptionsView.kDismissableHeight {
					newIssuerOptionsView.animateDismiss { [weak self] _ in
						self?.dismissVC()
					}
				}
				else if newHeight < newIssuerOptionsView.kDefaultHeight {
					newIssuerOptionsView.animateSheetHeight(newIssuerOptionsView.kDefaultHeight)
				}
			default: break
		}
	}

	@objc private func didTapComposeButton() {
		NotificationCenter.default.post(name: .shouldSaveDataNotification, object: nil)
	}

	@objc private func didTapDismissButton() { dismissVC() }

}

// ! NewIssuerVCDelegate

extension NewIssuerOptionsVC: NewIssuerVCDelegate {

	func shouldDismissVC(in newIssuerVC: NewIssuerVC) {
		delegate?.shouldReloadData(in: self)
		dismissVC()
	}

}

// ! QRCodeVCDelegate

extension NewIssuerOptionsVC: QRCodeVCDelegate {

	func didCreateIssuerOutOfQRCode(in qrCodeVC: QRCodeVC) {
		delegate?.shouldReloadData(in: self)
		dismissVC()
	}

}

// ! PHPickerViewControllerDelegate

extension NewIssuerOptionsVC: PHPickerViewControllerDelegate {

	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		guard !results.isEmpty else {
			dismissVC()
			return
		}
		results.first?.itemProvider.loadObject(ofClass: UIImage.self) { imageObject, error in
			guard let image = imageObject as? UIImage, error == nil else { return }

			let ciImage = CIImage(image: image) ?? CIImage()
			let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
			let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
			let features = detector?.features(in: ciImage) as? [CIQRCodeFeature] ?? []

			DispatchQueue.main.async {
				guard let otPauthString = features.first?.messageString else {
					self.toastView.fadeInOutToastView(withMessage: "No QR code was detected on this image.", finalDelay: 1.5)
					return
				}
				IssuerManager.sharedInstance.createIssuer(outOfOtPauthString: otPauthString) { isDuplicateItem, issuer in
					guard !isDuplicateItem else {
						self.toastView.fadeInOutToastView(withMessage: "Item already exists, updating it now.", finalDelay: 1.5)
						return
					}

					IssuerManager.sharedInstance.appendIssuer(issuer)

					self.delegate?.shouldReloadData(in: self)
					self.dismissVC()
				}
			}
		}
	}

}

extension NewIssuerOptionsVC {

	// ! Public

	/// Function to animate the new issuer options table view
	func animateTableView() {
		UIView.transition(with: newIssuerOptionsView.tableView, duration: 0.35, options: .transitionCrossDissolve) {
			self.reloadData()
		}
	}

	/// Function to configure the header
	/// - Parameters:
	///		- isDefaultConfiguration: A Bool to check if we should set the header with the default configuration
	///		- isBackupOptions: A Bool to check if we should set the header for the backup options data source
	func configureHeader(isDefaultConfiguration: Bool = true, isBackupOptions: Bool = false) {
		newIssuerOptionsView.configureHeader(isDefaultConfiguration: isDefaultConfiguration, isBackupOptions: isBackupOptions)
	}

	/// Function to reload the new issuer options table view's data
	func reloadData() {
		newIssuerOptionsView.reloadData()
	}

	/// Function to dismiss the current view controller being presented
	func shouldDismissVC() {
		newIssuerOptionsView.animateDismiss { [weak self] _ in
			self?.dismiss(animated: true)
		}
	}

	/// Function to setup the backup options data source
	func setupBackupOptionsDataSource() {
		newIssuerOptionsView.setupBackupOptionsDataSource()
	}

	/// Function to setup the make backup options data source
	func setupMakeBackupOptionsDataSource() {
		newIssuerOptionsView.setupMakeBackupOptionsDataSource()
	}

}
