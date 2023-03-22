import PhotosUI
import UIKit


protocol ModalSheetVCDelegate: AnyObject {
	func modalSheetVCShouldReloadData()
}

final class ModalSheetVC: UIViewController {

	private let toastView = ToastView()
	private let modalChildView = ModalChildView()
	private var navVC: UINavigationController!
	private let newIssuerVC = NewIssuerVC()

	weak var delegate: ModalSheetVCDelegate?

	init() {
		super.init(nibName: nil, bundle: nil)
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		modalChildView.animateViews()
	}

	private func setupViews() {
		modalChildView.delegate = self
		newIssuerVC.delegate = self

		view.backgroundColor = .clear
		view.addSubview(modalChildView)

		layoutUI()
	}

	private func layoutUI() { view.pinViewToAllEdges(modalChildView) }

	// MARK: Designated initializer

	func setupChildWithTitle(
		_ title: String,
		subtitle: String,
		buttonTitle: String,
		forTarget target: Any?,
		forSelector selector: Selector,
		secondButtonTitle: String,
		forTarget secondTarget: Any?,
		forSelector secondSelector: Selector,
		thirdStackView usesThirdSV: Bool = false,
		thirdButtonTitle: String? = nil,
		forTarget thirdTarget: Any? = nil,
		forSelector thirdSelector: Selector? = nil,
		accessoryImage: UIImage,
		secondAccessoryImage: UIImage,
		thirdAccessoryImage: UIImage? = nil,
		prepareForReuse reuse: Bool,
		scaleAnimation scaleAnim: Bool

	) {
		modalChildView.setupModalChildWithTitle(
			title,
			subtitle: subtitle,
			buttonTitle: buttonTitle,
			forTarget: target,
			forSelector: selector,
			secondButtonTitle: secondButtonTitle,
			forTarget: secondTarget,
			forSelector: secondSelector,
			thirdStackView: usesThirdSV,
			thirdButtonTitle: thirdButtonTitle,
			forTarget: thirdTarget,
			forSelector: thirdSelector,
			accessoryImage: accessoryImage,
			secondAccessoryImage: secondAccessoryImage,
			thirdAccessoryImage: thirdAccessoryImage,
			prepareForReuse: reuse,
			scaleAnimation: scaleAnim
		)
	}

	func shouldCrossDissolveChildSubviews() { modalChildView.shouldCrossDissolveSubviews() }
	func shouldDismissVC() {
		modalChildView.animateDismiss { _ in
			self.dismiss(animated: true)
		}
	}

	// MARK: Reusable funcs

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
			vc.navigationItem.leftBarButtonItem = UIBarButtonItem.getBarButtomItem(withImage: image, forTarget: self, forSelector: selector)
		}
		else {
			vc.navigationItem.rightBarButtonItem = UIBarButtonItem.getBarButtomItem(withImage: image, forTarget: self, forSelector: selector)
		}
		navVC.modalTransitionStyle = .crossDissolve
		navVC.modalPresentationStyle = .fullScreen
	}

	private func dismissVC() {
		dismiss(animated: true, completion: nil)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			self.modalChildView.animateDismiss { _ in
				self.dismiss(animated: true)
			}
		}
	}

}

extension ModalSheetVC: ModalChildViewDelegate, NewIssuerVCDelegate, QRCodeVCDelegate {

	@objc func modalChildViewDidTapScanQRCodeButton() {
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

	@objc func modalChildViewDidTapImportQRImageButton() {
		var configuration = PHPickerConfiguration()
		configuration.filter = PHPickerFilter.images

		let phPickerVC = PHPickerViewController(configuration: configuration)
		phPickerVC.delegate = self
		present(phPickerVC, animated: true)

		let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.filter { $0.activationState == .foregroundActive }
		let window = scenes.first?.windows.last
		window?.addSubview(toastView)
		window?.pinAzureToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)
	}

	@objc func modalChildViewDidTapEnterManuallyButton() {
		configureVC(
			newIssuerVC,
			withTitle: "Enter QR Code",
			withItemImage: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(),
			forSelector: #selector(didTapComposeButton),
			isLeftBarButtonItem: false
		)
		newIssuerVC.navigationItem.leftBarButtonItem = UIBarButtonItem.getBarButtomItem(
			withImage: UIImage(systemName: "xmark.circle.fill") ?? UIImage(),
			forTarget: self,
			forSelector: #selector(didTapDismissButton)
		)
		present(navVC, animated: true)
	}

	func modalChildViewDidTapDimmedView() {
		modalChildView.animateDismiss { _ in
			self.dismiss(animated: true)
		}
	}

	func modalChildViewDidPan(withGesture gesture: UIPanGestureRecognizer, modifyingConstraint constraint: NSLayoutConstraint) {
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
					modalChildView.animateDismiss { _ in
						self.dismissVC()
					}
				}
				else if newHeight < modalChildView.kDefaultHeight {
					modalChildView.animateSheetHeight(modalChildView.kDefaultHeight)
				}
			default: break
		}
	}

	func newIssuerVCShouldDismissVC() {
		delegate?.modalSheetVCShouldReloadData()
		dismissVC()
	}

	func newIssuerVCShouldPushAlgorithmVC() {
		let algorithmVC = AlgorithmVC()
		algorithmVC.title = "Algorithm"
		navVC.pushViewController(algorithmVC, animated: true)
	}

	func qrCodeVCDidCreateIssuerOutOfQRCode() {
		delegate?.modalSheetVCShouldReloadData()
		dismissVC()
	}

	@objc private func didTapComposeButton() {
		NotificationCenter.default.post(name: Notification.Name("checkIfDataShouldBeSaved"), object: nil)
	}

	@objc private func didTapDismissButton() { dismissVC() }

}

extension ModalSheetVC: PHPickerViewControllerDelegate {

	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		guard !results.isEmpty else {
			dismissVC()
			return
		}
		results.first?.itemProvider.loadObject(ofClass: UIImage.self) { imageObject, error in
			guard let image = imageObject as? UIImage, error == nil else { return }
			DispatchQueue.main.async {
				let ciImage = CIImage(image: image)
				let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
				let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)

				let features = detector?.features(in: ciImage ?? CIImage()) as? [CIQRCodeFeature] ?? []
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

					self.delegate?.modalSheetVCShouldReloadData()
					self.dismissVC()
				}
			}
		}
	}

}
