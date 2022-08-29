import UIKit


extension String {
	static let kIdentifier = "AzurePinCodeCell"
	static let kCheckra1n = "/var/checkra1n.dmg"
	static let kTaurine = "/taurine"
	static let kUnc0ver = "/private/etc/apt/undecimus"
	static let kAzureDir = "/var/mobile/Documents/Azure"
	static let kAzurePath = "/var/mobile/Documents/Azure/AzureBackup.json"
	static let kAzureReasonSensitiveOperation = "Azure needs you to authenticate for a sensitive operation."
}


extension UIBarButtonItem {

	static func getBarButtomItemWithImage(
		_ image: UIImage,
		forTarget target: Any?,
		forSelector selector: Selector
	) -> UIBarButtonItem {
		let barButtonItem = UIBarButtonItem(image: image, style: .done, target: target, action: selector)
		return barButtonItem
	}

}

extension UIColor {

	static let kAzureLilacTintColor = UIColor(red: 0.70, green: 0.56, blue: 1.0, alpha: 1.0)
	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)

}

extension UIImage {

	@objc public static func resizeImageFromImage(_ image: UIImage, withSize size: CGSize) -> UIImage {
		let newSize = size

		let scale = max(newSize.width / image.size.width, newSize.height / image.size.height)
		let width = image.size.width * scale
		let height = image.size.height * scale
		let imageRect = CGRect(
			x: (newSize.width - width) / 2.0,
			y: (newSize.height - height) / 2.0,
			width: width,
			height: height
		)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
		image.draw(in: imageRect)

		let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()

		return newImage
	}

}

extension UIView {

	func animateViewWithDelay(_ delay: TimeInterval,
		withAnimations animations: @escaping () -> (),
		withCompletion completion: ((Bool) -> ())?
	) {
		UIView.animate(withDuration: 0.5,
			delay: delay,
			options: .curveEaseIn,
			animations: animations,
			completion: completion
		)
	}

	func makeRotationTransformForView(_ view: UIView, andLabel label: UILabel) {
		var rotation = CATransform3DIdentity
		rotation.m34 = 1.0 / -500.0
		rotation = CATransform3DRotate(rotation, 180 * CGFloat.pi / 180.0, 0.0, 1.0, 0.0)
		view.layer.transform = rotation
		label.layer.transform = rotation
	}

	func pinViewToAllEdges(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	func pinViewToAllEdgesIncludingSafeAreas(_ view: UIView, bottomConstant: CGFloat) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	func pinAzureToastToTheBottomCenteredOnTheXAxis(_ toastView: UIView, bottomConstant: CGFloat) {
		toastView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			toastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			toastView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

}
