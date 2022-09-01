import UIKit


protocol ModalSheetVCDelegate: AnyObject {
	func modalSheetVCShouldReloadData()
}

final class ModalSheetVC: UIViewController {

	private var modalChildView: ModalChildView!
	private var navVC: UINavigationController!
	private var pinCodeVC: PinCodeVC!

	weak var delegate: ModalSheetVCDelegate?

	init() {
		super.init(nibName: nil, bundle: nil)
		pinCodeVC = PinCodeVC()
		pinCodeVC.delegate = self
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
		view.backgroundColor = .clear
		modalChildView = ModalChildView()
		modalChildView.delegate = self
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
			self.dismiss(animated: true, completion: nil)
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
				self.dismiss(animated: true, completion: nil)
			}
		}
	}

}

extension ModalSheetVC: ModalChildViewDelegate, PinCodeVCDelegate, QRCodeVCDelegate {

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
		present(navVC, animated: true, completion: nil)
	}

	@objc func modalChildViewDidTapImportQRImageButton() {
		let imagePickerVC = UIImagePickerController()
		imagePickerVC.delegate = self
		imagePickerVC.sourceType = .photoLibrary
		present(imagePickerVC, animated: true, completion: nil)
	}

	@objc func modalChildViewDidTapEnterManuallyButton() {
		configureVC(
			pinCodeVC,
			withTitle: "Enter QR Code",
			withItemImage: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(),
			forSelector: #selector(didTapComposeButton),
			isLeftBarButtonItem: false
		)
		pinCodeVC.navigationItem.leftBarButtonItem = UIBarButtonItem.getBarButtomItem(
			withImage: UIImage(systemName: "xmark.circle.fill") ?? UIImage(),
			forTarget: self,
			forSelector: #selector(didTapDismissButton)
		)
		present(navVC, animated: true, completion: nil)
	}

	func modalChildViewDidTapDimmedView() {
		modalChildView.animateDismiss { _ in
			self.dismiss(animated: true, completion: nil)
		}
	}

	func modalChildViewDidPanWithGesture(_ gesture: UIPanGestureRecognizer, modifyingConstraint constraint: NSLayoutConstraint) {
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

	func pinCodeVCShouldDismissVC() {
		delegate?.modalSheetVCShouldReloadData()
		dismissVC()
	}

	func pinCodeVCShouldPushAlgorithmVC() {
		let algorithmVC = AlgorithmVC()
		algorithmVC.title = "Algorithm"
		present(algorithmVC, animated: true, completion: nil)
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

extension ModalSheetVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.originalImage] as? UIImage else { return }
		let ciImage = CIImage(image: image)
		let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
		let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)

		let features = detector?.features(in: ciImage ?? CIImage()) as? [CIQRCodeFeature] ?? []

		for feature in features {
			TOTPManager.sharedInstance.makeURL(outOfOtPauthString: feature.messageString ?? "")
			delegate?.modalSheetVCShouldReloadData()
		}
		dismissVC()
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { dismissVC() }

}
