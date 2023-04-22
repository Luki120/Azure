import PhotosUI
import UIKit


protocol ModalSheetVCDelegate: AnyObject {
	func shouldReloadData(in modalSheetVC: ModalSheetVC)
}

/// Controller that'll show the modal sheet view
final class ModalSheetVC: UIViewController {

	let dataSource = ModalSheetDataSource()

	var headerView: NewIssuerOptionsHeaderView { return modalChildView.headerView }
	var childTableView: UITableView { return modalChildView.tableView }

	private let newIssuerVC = NewIssuerVC()
	private let toastView = ToastView()

	private var modalChildView: ModalChildView!
	private var navVC: UINavigationController!

	weak var delegate: ModalSheetVCDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		modalChildView = .init(dataSource: dataSource)
		modalChildView.delegate = self
		newIssuerVC.delegate = self

		view.backgroundColor = .clear
	}

	override func loadView() { view = modalChildView }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		modalChildView.animateViews()
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
			self.modalChildView.animateDismiss { [weak self] _ in
				self?.dismiss(animated: true)
			}
		}
	}

	// ! Public

	/// Function to reload the child table view's data
	func reloadData() {
		modalChildView.reloadData()
	}

	/// Function to dismiss the current view controller being presented
	func shouldDismissVC() {
		modalChildView.animateDismiss { [weak self] _ in
			self?.dismiss(animated: true)
		}
	}

	/// Function to setup the backup options data source
	/// - Parameters:
	///		- buttonTarget: The button's target
	///		- selectors: An array of selectors for the buttons
	func setupBackupOptionsDataSource(buttonTarget target: Any?, selectors: [Selector]) {
		dataSource.setupBackupOptionsDataSource(buttonTarget: target, selectors: selectors)
	}

	/// Function to setup the make backup options data source
	/// - Parameters:
	///		- buttonTarget: The button's target
	///		- selectors: An array of selectors for the buttons
	func setupMakeBackupOptionsDataSource(buttonTarget target: Any?, selectors: [Selector]) {
		dataSource.setupMakeBackupOptionsDataSource(buttonTarget: target, selectors: selectors)
	}

}

// ! ModalChildViewDelegate

extension ModalSheetVC: ModalChildViewDelegate {

	@objc func didTapScanQRCodeButton(in modalChildView: ModalChildView) {
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

	@objc func didTapImportQRImageButton(in modalChildView: ModalChildView) {
		var configuration = PHPickerConfiguration()
		configuration.filter = PHPickerFilter.images

		let phPickerVC = PHPickerViewController(configuration: configuration)
		phPickerVC.delegate = self
		present(phPickerVC, animated: true)

		keyWindow.addSubview(toastView)
		keyWindow.pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)
	}

	@objc func didTapEnterManuallyButton(in modalChildView: ModalChildView) {
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

	func didTapDimmedView(in modalChildView: ModalChildView) {
		modalChildView.animateDismiss { [weak self] _ in
			self?.dismiss(animated: true)
		}
	}

	func modalChildView(
		_ modalChildView: ModalChildView,
		didPanWithGesture gesture: UIPanGestureRecognizer,
		modifyingConstraint constraint: NSLayoutConstraint
	) {
		let translation = gesture.translation(in: view)
		let newHeight = modalChildView.currentSheetHeight - translation.y

		switch gesture.state {
			case .changed:
				if newHeight < modalChildView.kDefaultHeight {
					constraint.constant = newHeight
					constraint.isActive = true

					modalChildView.calculateAlpha(basedOnTranslation: translation)
					view.layoutIfNeeded()
				}
			case .ended:
				if newHeight < modalChildView.kDismissableHeight {
					modalChildView.animateDismiss { [weak self] _ in
						self?.dismissVC()
					}
				}
				else if newHeight < modalChildView.kDefaultHeight {
					modalChildView.animateSheetHeight(modalChildView.kDefaultHeight)
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

extension ModalSheetVC: NewIssuerVCDelegate {

	func shouldDismissVC(in newIssuerVC: NewIssuerVC) {
		delegate?.shouldReloadData(in: self)
		dismissVC()
	}

	func shouldPushAlgorithmVC(in newIssuerVC: NewIssuerVC) {
		let algorithmVC = AlgorithmVC()
		algorithmVC.title = "Algorithm"
		navVC.pushViewController(algorithmVC, animated: true)
	}

}

// ! QRCodeVCDelegate

extension ModalSheetVC: QRCodeVCDelegate {

	func didCreateIssuerOutOfQRCode(in qrCodeVC: QRCodeVC) {
		delegate?.shouldReloadData(in: self)
		dismissVC()
	}

}

// ! PHPickerViewControllerDelegate

extension ModalSheetVC: PHPickerViewControllerDelegate {

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

					IssuerManager.sharedInstance.issuers.append(issuer)

					self.delegate?.shouldReloadData(in: self)
					self.dismissVC()
				}
			}
		}
	}

}
