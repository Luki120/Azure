import UIKit
import LocalAuthentication
import ObjectiveC.runtime


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	private var strongWindow: UIWindow!

	private static var NotAuthenticatedVClass: AnyClass!
	private lazy var NotAuthenticatedVC = AppDelegate.NotAuthenticatedVClass.alloc() as? UIViewController

	private let authManager = AuthManager()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		setupNotAuthenticatedVC()

		window = UIWindow()
		window?.tintColor = .kAzureLilacTintColor
		window?.backgroundColor = .systemBackground
		window?.rootViewController = UIViewController()
		window?.makeKeyAndVisible()

		strongWindow = window

		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

		let usesBiometrics = UserDefaults.standard.bool(forKey: "useBiometrics")
		if usesBiometrics && authManager.shouldUseBiometrics() { unsafePortalDispatch() }
		else { window?.rootViewController = TabBarVC() }

		return true
	}

	private func unsafePortalDispatch() {
		authManager.setupAuth(withReason: .unlockApp) { [weak self] success, error in
			DispatchQueue.main.async {
				let laError = error as? LAError
				guard success && laError?.code != .passcodeNotSet else {
					self?.strongWindow.rootViewController = self?.NotAuthenticatedVC
					return
				}
				self?.strongWindow.rootViewController = TabBarVC()
			}
		}
	}

	private func setupNotAuthenticatedVC() {
		allocateClass { notAuthenticatedVC in
			AppDelegate.sendSuper()

			let quitButton = UIButton()
			quitButton.alpha = 0
			quitButton.transform = .init(scaleX: 0.1, y: 0.1)
			quitButton.backgroundColor = .kAzureMintTintColor
			quitButton.layer.cornerCurve = .continuous
			quitButton.layer.cornerRadius = 20
			quitButton.setTitle("Retry", for: .normal)
			quitButton.addTarget(notAuthenticatedVC, action: NSSelectorFromString("didTapRetryButton"), for: .touchUpInside)

			notAuthenticatedVC.view.addSubview(quitButton)
			notAuthenticatedVC.view.centerViewOnBothAxes(quitButton)
			notAuthenticatedVC.view.setupSizeConstraints(forView: quitButton, width: 120, height: 40)

			UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn) {
				quitButton.alpha = 1
				quitButton.transform = .init(scaleX: 1, y: 1)
			}

			AppDelegate.didTapRetryButton { self.unsafePortalDispatch() }
		}
	}

	private func allocateClass(imp: @escaping @convention(block) (UIViewController) -> ()) {
		AppDelegate.NotAuthenticatedVClass = objc_allocateClassPair(UIViewController.self, "NotAuthenticatedVC", 0)!

		let method = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidLoad))!
		let azure_viewDidLoad = imp_implementationWithBlock(unsafeBitCast(imp, to: AnyObject.self))
		let typeEncoding = method_getTypeEncoding(method)!
		class_addMethod(AppDelegate.NotAuthenticatedVClass, #selector(UIViewController.viewDidLoad), azure_viewDidLoad, typeEncoding)

		objc_registerClassPair(AppDelegate.NotAuthenticatedVClass)
	}

	private static func sendSuper() {
		let superclass: AnyClass = class_getSuperclass(NotAuthenticatedVClass)!
		let selector = #selector(UIViewController.viewDidLoad)
		let imp = class_getMethodImplementation(superclass, selector)

		typealias ObjcVoidFunc = @convention(c) (AnyObject, Selector) -> ()

		let superCall = unsafeBitCast(imp, to: ObjcVoidFunc.self)
		superCall(NotAuthenticatedVClass, selector)
	}

	private static func didTapRetryButton(imp: @escaping @convention(block) () -> Void) {
		class_addMethod(
			NotAuthenticatedVClass,
			NSSelectorFromString("didTapRetryButton"),
			imp_implementationWithBlock(unsafeBitCast(imp, to: AnyObject.self)),
			"v@:"
		)
	}

}
