import AVFoundation
import UIKit


protocol QRCodeVCDelegate: AnyObject {
	func didCreateIssuerOutOfQRCode(in qrCodeVC: QRCodeVC)
}

// Slightly modified from ⇝ https://github.com/mattrubin/Authenticator/blob/develop/Authenticator/Source/ScannerOverlayView.swift

/// View that'll show a dimmed view for the qr code scanning view
private final class DimmedView: UIView {

	private var gradientFrame: CGRect!

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		isOpaque = false
	}

	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		UIColor.black.withAlphaComponent(0.5).setFill()
		UIColor.white.setStroke()

		gradientFrame = CGRect(
			x: windowWithCoordinates(fromRect: rect).origin.x,
			y: windowWithCoordinates(fromRect: rect).origin.y,
			width: windowWithCoordinates(fromRect: rect).size.width, 
			height: 15
		)
		setupGradientLayer()

		context.fill(rect)
		context.clear(windowWithCoordinates(fromRect: rect))
		context.stroke(windowWithCoordinates(fromRect: rect), width: 2)
	}

	private func setupGradientLayer() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [UIColor.systemGreen.withAlphaComponent(0).cgColor, UIColor.systemGreen.cgColor]
		gradientLayer.frame = gradientFrame
		gradientLayer.opacity = 0.4
		layer.insertSublayer(gradientLayer, at: 0)

		let initialYPosition = gradientLayer.position.y
		let finalYPosition = initialYPosition + (windowWithCoordinates(fromRect: frame).height - gradientLayer.frame.height)

		let animation = CABasicAnimation(keyPath: "position.y")
		animation.fromValue = initialYPosition
		animation.toValue = finalYPosition
		animation.duration = 2
		animation.repeatCount = .infinity
		animation.autoreverses = true
		gradientLayer.add(animation, forKey: nil)
	}

}

/// Controller that'll show the qr code scanner view
final class QRCodeVC: UIViewController {

	private let toastView = ToastView()
	private let dimmedView = DimmedView()
	private let captureSession = AVCaptureSession()
	private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!

	weak var delegate: QRCodeVCDelegate?

	// ! Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		view.addSubview(dimmedView)
		keyWindow.addSubview(toastView)

		checkAuthorizationStatus()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if !captureSession.isRunning { captureSession.startRunning() }
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if captureSession.isRunning { captureSession.stopRunning() }
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		view.pinViewToAllEdges(dimmedView)
		keyWindow.pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -15)
	}

	// ! Private

	private func checkAuthorizationStatus() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .authorized: setupScanner()
			case .denied: toastView.fadeInOutToastView(withMessage: "Camera access denied.", finalDelay: 1.5)
			case .notDetermined:
				AVCaptureDevice.requestAccess(for: .video) { granted in
					DispatchQueue.main.async {
						guard granted else {
							self.toastView.fadeInOutToastView(withMessage: "Camera access denied.", finalDelay: 1.5)
							return
						}
						self.setupScanner()
					}
				}
			case .restricted: break
			@unknown default: break
		}
	}

	private func setupScanner() {
		guard let captureDevice = AVCaptureDevice.default(for: .video),
			let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

		captureSession.addInput(input)

		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession.addOutput(captureMetadataOutput)
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		captureMetadataOutput.metadataObjectTypes = [.qr]

		captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		captureVideoPreviewLayer.frame = view.layer.bounds
		captureVideoPreviewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(captureVideoPreviewLayer, at: 0)
		view.layoutIfNeeded()

		let layerRect = view.windowWithCoordinates(fromRect: dimmedView.frame)
		let rectOfInterest = captureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: layerRect)
		captureMetadataOutput.rectOfInterest = rectOfInterest

		captureSession.startRunning()
	}

}

// ! AVCaptureMetadataOutputObjectsDelegate

extension QRCodeVC: AVCaptureMetadataOutputObjectsDelegate {

	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		guard metadataObjects.count != 0,
			let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
			let outputString = metadataObject.stringValue else { return }

		IssuerManager.sharedInstance.createIssuer(outOfOtPauthString: outputString) { isDuplicateItem, issuer in
			guard !isDuplicateItem else {
				toastView.fadeInOutToastView(withMessage: "Item already exists, updating it now.", finalDelay: 1.5)
				return
			}

			IssuerManager.sharedInstance.issuers.append(issuer)

			captureSession.stopRunning()
			captureVideoPreviewLayer.removeFromSuperlayer()
			dimmedView.layer.removeAllAnimations()

			delegate?.didCreateIssuerOutOfQRCode(in: self)
		}
	}

}

private extension UIView {

	func windowWithCoordinates(fromRect rect: CGRect) -> CGRect {
		let smallestDimension = min(bounds.width, bounds.height)
		let windowSize = 0.5 * smallestDimension
		let window = CGRect(
			x: rect.midX - (windowSize / 2),
			y: rect.midY - (windowSize / 2),
			width: windowSize,
			height: windowSize
		)
		return window
	}

}
