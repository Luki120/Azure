import UIKit
import LocalAuthentication
import ObjectiveC.runtime


@UIApplicationMain
final class AZAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var strongWindow: UIWindow!
	private let authManager = AuthManager()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

		window = UIWindow()
		window?.tintColor = .kAzureLilacTintColor
		window?.backgroundColor = .systemBackground
		window?.rootViewController = NotAuthenticatedVC()
		window?.makeKeyAndVisible()

		strongWindow = window

		let defaults = UserDefaults.standard
		let usesBiometrics = defaults.bool(forKey: "useBiometrics")
		if usesBiometrics && authManager.shouldUseBiometrics() { unsafePortalDispatch() }
		else { window?.rootViewController = AzureRootVC() }

		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().barTintColor = .systemBackground

		return true
	}

	private func unsafePortalDispatch() {
		authManager.setupAuth(withReason: .kAzureReasonUnlockApp, reply: { success, error in
			DispatchQueue.main.async {
				let laError = error as? LAError
				guard success && laError?.code != .passcodeNotSet else {
					self.strongWindow.rootViewController = NotAuthenticatedVC()
					return
				}
				self.strongWindow.rootViewController = AzureRootVC()

			}
		})
	}

}

// :trollJackOLantern:

extension UIApplication {
	override open var next: UIResponder? {
		AwakeHelper.initialize()
		return super.next
	}
}

private protocol Awake {
	static dynamic func awake()
}

private final class AwakeHelper {

	private static let runOnce: Any? = {
		NotAuthenticatedVC.awake()
		return nil
	}()

	static func initialize() { _ = AwakeHelper.runOnce }

}

extension NotAuthenticatedVC: Awake {

	static dynamic func awake() {
		guard self === NotAuthenticatedVC.self else { return }
		let origSelector = #selector(viewDidLoad)
		let swizzledSelector = #selector(azure_viewDidLoad)

		let origMethod = class_getInstanceMethod(self, origSelector)!
		let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)!

		method_exchangeImplementations(origMethod, swizzledMethod)
	}

	@objc dynamic private func azure_viewDidLoad() {
		azure_viewDidLoad()

		let quitButton = UIButton()
		quitButton.alpha = 0
		quitButton.transform = .init(scaleX: 0.1, y: 0.1)
		quitButton.backgroundColor = .kAzureMintTintColor
		quitButton.layer.cornerCurve = .continuous
		quitButton.layer.cornerRadius = 20
		quitButton.translatesAutoresizingMaskIntoConstraints = false
		quitButton.setTitle("Quit", for: .normal)
		quitButton.addTarget(self, action: #selector(didTapQuitButton), for: .touchUpInside)

		view.addSubview(quitButton)
		view.centerViewOnBothAxes(quitButton)
		view.setupSizeConstraints(forView: quitButton, width: 120, height: 40)

		UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseIn, animations: {
			quitButton.alpha = 1
			quitButton.transform = .init(scaleX: 1, y: 1)
		})
	}

	@objc private func didTapQuitButton() { abort() }

}
