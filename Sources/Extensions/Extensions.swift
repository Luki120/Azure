import UIKit


extension Notification.Name {
	static let didPurgeDataNotification = Notification.Name("didPurgeDataNotification")
	static let shouldMakeBackupNotification = Notification.Name("shouldMakeBackupNotification")
	static let shouldSaveDataNotification = Notification.Name("shouldSaveDataNotification")
}

extension String {
	static let kCheckra1n = "/var/checkra1n.dmg"
	static let kDopamine = "/var/jb/"
	static let kTaurine = "/taurine"
	static let kUnc0ver = "/private/etc/apt/undecimus"
	static let kZina = "/var/LIY/"
	static let kAzureDir = "/var/mobile/Documents/Azure"
	static let kAzurePath = "/var/mobile/Documents/Azure/AzureBackup.json"
}

extension UIBarButtonItem {
	static func getBarButtomItem(withImage image: UIImage, target: Any?, selector: Selector) -> UIBarButtonItem {
		return UIBarButtonItem(image: image, style: .done, target: target, action: selector)
	}
}

extension UIColor {
	static let kAzureLilacTintColor = UIColor(red: 0.70, green: 0.56, blue: 1.0, alpha: 1.0)
	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)
}

extension UIImage {
	func resizeImage(_ image: UIImage, withSize size: CGSize) -> UIImage {
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

extension UIStackView {
	func addArrangedSubviews(_ views: UIView ...) {
		views.forEach { addArrangedSubview($0) }
	}
}

extension UIView {
	func addSubviews(_ views: UIView ...) {
		views.forEach { addSubview($0) }
	}

	func animateView(withDelay delay: TimeInterval = 0, animations: @escaping () -> Void, completion: ((Bool) -> ())?) {
		UIView.animate(
			withDuration: 0.5,
			delay: delay,
			options: .curveEaseIn,
			animations: animations,
			completion: completion
		)
	}

	func makeRotationTransform(forViews views: [UIView]) {
		let π = Double.pi
		var rotation = CATransform3DIdentity
		rotation.m34 = 1.0 / -500.0
		rotation = CATransform3DRotate(rotation, π, 0.0, 1.0, 0.0)
		views[0].layer.transform = rotation
		views[1].layer.transform = rotation
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

	func pinViewToAllEdgesIncludingSafeAreas(_ view: UIView, bottomConstant: CGFloat = 0) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	func pinToastToTheBottomCenteredOnTheXAxis(_ toastView: UIView, bottomConstant: CGFloat) {
		toastView.translatesAutoresizingMaskIntoConstraints = false
		toastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant).isActive = true
		toastView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
	}

	func centerViewOnBothAxes(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}

	func setupHorizontalConstraints(forView view: UIView, leadingConstant: CGFloat = 0, trailingConstant: CGFloat = 0) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant).isActive = true
		view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).isActive = true
	}

	func setupSizeConstraints(forView view: UIView, width: CGFloat, height: CGFloat) {
		view.widthAnchor.constraint(equalToConstant: width).isActive = true
		view.heightAnchor.constraint(equalToConstant: height).isActive = true
	}
}

extension UIViewController {
	var keyWindow: UIWindow! {
		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.filter { $0.activationState == .foregroundActive }.first?.windows.last
	}
}

func isJailbroken() -> Bool {
	let fileM = FileManager.default
	if fileM.fileExists(atPath: .kCheckra1n)
		|| fileM.fileExists(atPath: .kDopamine)
		|| fileM.fileExists(atPath: .kTaurine)
		|| fileM.fileExists(atPath: .kUnc0ver)
		|| fileM.fileExists(atPath: .kZina) { return true }

	return false
}
