import UIKit


extension CGColor {
	static let darkBackgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0).cgColor
	static let lightBackgroundColor = UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.0).cgColor
	static let darkShadowColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0).cgColor
	static let lightShadowColor = UIColor(red: 0.82, green: 0.85, blue: 0.90, alpha: 1.0).cgColor
}

extension Notification.Name {
	static let didPurgeDataNotification = Notification.Name("didPurgeDataNotification")
	static let shouldMakeBackupNotification = Notification.Name("shouldMakeBackupNotification")
	static let shouldResignResponderNotification = Notification.Name("shouldResignResponderNotification")
	static let shouldSaveDataNotification = Notification.Name("shouldSaveDataNotification")
}

extension NSMutableAttributedString {
	convenience init(fullString: String, subString: String) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		let mutableParagraphStyle = NSMutableParagraphStyle()
		mutableParagraphStyle.lineBreakMode = .byTruncatingTail

		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: rangeOfSubString)
		attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: rangeOfSubString)
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}

extension UIBarButtonItem {
	static func getBarButtomItem(withImage image: UIImage, target: Any?, selector: Selector) -> UIBarButtonItem {
		return UIBarButtonItem(image: image, style: .done, target: target, action: selector)
	}
}

extension UIColor {
	static let darkColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
	static let lightColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
	static let kAzureLilacTintColor = UIColor(red: 0.70, green: 0.56, blue: 1.0, alpha: 1.0)
	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)
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

	func setupCleanShadowLayer(
		withBackgroundColor color: CGColor = kUserInterfaceStyle == .dark ? .darkBackgroundColor : .lightBackgroundColor
	) {
		layer.cornerCurve = .continuous
		layer.cornerRadius = 14
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 14).cgPath
		layer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor
		layer.shadowOffset = .init(width: 0, height: 0)
		layer.shadowOpacity = 1
		layer.shadowRadius = 3.5
		layer.masksToBounds = false
		layer.backgroundColor = color
	}
}

private protocol ReusableView {
	static var reuseIdentifier: String { get }
}

private extension ReusableView {
	static var reuseIdentifier: String { return String(describing: self) }
}

extension UITableViewCell: ReusableView {}

extension UITableView {
	func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
		guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("L")
		}
		return cell
	}
}

extension UIViewController {
	var keyWindow: UIWindow! {
		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.filter { $0.activationState == .foregroundActive }.first?.windows.last
	}
}

var kUserInterfaceStyle: UIUserInterfaceStyle { return UIScreen.main.traitCollection.userInterfaceStyle }

private enum Jailbreak: String, CaseIterable {
	case checkra1n = "/var/checkra1n.dmg"
	case dopamine = "/var/jb/"
	case serotonin = "/var/mobile/.serotonin_"
	case taurine = "/taurine"
	case unc0ver = "/private/etc/apt/undecimus"
	case zina = "/var/LIY/"

	var path: String { return rawValue }
}

func isJailbroken() -> Bool {
	return Jailbreak.allCases.contains { FileManager.default.fileExists(atPath: $0.path) }
}
