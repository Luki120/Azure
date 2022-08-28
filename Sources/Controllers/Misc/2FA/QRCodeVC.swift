import AVFoundation
import UIKit


protocol QRCodeVCDelegate: AnyObject {
	func qrCodeVCDidCreateIssuerOutOfQRCode()
}

final class QRCodeVC: UIViewController {
	var audioPlayer: AVAudioPlayer!
	var captureSession: AVCaptureSession!
	var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
	var azToastView: AzureToastView!

	weak var delegate: QRCodeVCDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		azToastView = AzureToastView()
		view.addSubview(azToastView)

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
	}

	private func checkAuthorizationStatus() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			case .authorized: setupScanner()
			case .denied: azToastView.fadeInOutToastViewWithMessage("Camera access denied.", finalDelay: 1.5)
			case .notDetermined:
				AVCaptureDevice.requestAccess(for: .video) { granted in
					DispatchQueue.main.async {
						if !granted {
							self.azToastView.fadeInOutToastViewWithMessage("Camera access denied.", finalDelay: 1.5)
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
		captureSession = AVCaptureSession()
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
		view.layer.addSublayer(captureVideoPreviewLayer)

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
