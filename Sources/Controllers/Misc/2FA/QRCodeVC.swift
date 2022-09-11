import AVFoundation
import UIKit


protocol QRCodeVCDelegate: AnyObject {
	func qrCodeVCDidCreateIssuerOutOfQRCode()
}

final class QRCodeVC: UIViewController {

	private let azToastView = AzureToastView()
	private let gradientLayer = CAGradientLayer()
	private let captureSession = AVCaptureSession()
	private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!

	weak var delegate: QRCodeVCDelegate?

	private lazy var squareView: UIView = {
		let view = UIView()
		view.layer.borderColor = UIColor.white.cgColor
		view.layer.borderWidth = 2
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 20
		self.view.addSubview(view)
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		view.addSubview(azToastView)

		setupGradientLayer()
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
		view.pinAzureToastToTheBottomCenteredOnTheXAxis(azToastView, bottomConstant: -15)
		view.centerViewOnBothAxes(squareView)
		view.setupSizeConstraints(forView: squareView, width: 180, height: 180)
	}

	private func setupGradientLayer() {
		gradientLayer.colors = [UIColor.blue.withAlphaComponent(0), UIColor.blue]
		gradientLayer.frame = CGRect(x: 0, y: 0, width: 180, height: 15)
		gradientLayer.opacity = 0.4
	}

	private func checkAuthorizationStatus() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .authorized: setupScanner()
			case .denied: azToastView.fadeInOutToastView(withMessage: "Camera access denied.", finalDelay: 1.5)
			case .notDetermined:
				AVCaptureDevice.requestAccess(for: .video) { granted in
					DispatchQueue.main.async {
						if !granted {
							self.azToastView.fadeInOutToastView(withMessage: "Camera access denied.", finalDelay: 1.5)
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
		guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
		guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

		captureSession.addInput(input)

		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession.addOutput(captureMetadataOutput)
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		captureMetadataOutput.metadataObjectTypes = [.qr]

		captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		captureVideoPreviewLayer.frame = view.layer.bounds
		captureVideoPreviewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(captureVideoPreviewLayer, at: 0)
		squareView.layer.insertSublayer(gradientLayer, at: 0)
		view.layoutIfNeeded()

 		let layerRect = squareView.frame
		captureMetadataOutput.rectOfInterest = captureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: layerRect)

		captureSession.startRunning()
	}
}

extension QRCodeVC: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if metadataObjects.count == 0 { return }
		guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
		guard let outputString = metadataObject.stringValue else { return }

		captureSession.stopRunning()
		captureVideoPreviewLayer.removeFromSuperlayer()

		TOTPManager.sharedInstance.makeURL(outOfOtPauthString: outputString)
		delegate?.qrCodeVCDidCreateIssuerOutOfQRCode()
	}
}
