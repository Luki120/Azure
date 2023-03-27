import class SwiftUI.UIHostingController
import UIKit

/// Root view controller, which will show our tabs
final class TabBarVC: UITabBarController {

	private var isSelected = false

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		let firstVC = IssuersVC()
		let secondVC = UIHostingController(rootView: SettingsView())
		firstVC.title = "Home"
		secondVC.title = "Settings"

		let firstNav = UINavigationController(rootViewController: firstVC)
		let secondNav = UINavigationController(rootViewController: secondVC)

		let lockImage = UIImage(named: "lock")
		let gearImage = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))

		firstNav.tabBarItem = UITabBarItem(title: "Home", image: lockImage, tag: 0)
		secondNav.tabBarItem = UITabBarItem(title: "Settings", image: gearImage, tag: 1)

		viewControllers = [firstNav, secondNav]
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		tabBar.isTranslucent = false
		tabBar.barTintColor = .systemBackground
		tabBar.clipsToBounds = true
		tabBar.layer.borderWidth = 0

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		guard UserDefaults.standard.object(forKey: "selectedIndex") != nil else { return }
		selectedIndex = UserDefaults.standard.integer(forKey: "selectedIndex")
	}

}

// ! UITabBarControllerDelegate

extension TabBarVC: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		UserDefaults.standard.set(selectedIndex, forKey: "selectedIndex")
	}

	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		let tabViewControllers = tabBarController.viewControllers
		let vcIndex = tabViewControllers?.firstIndex(of: viewController) ?? 0

		let fromView = tabBarController.selectedViewController?.view ?? UIView()
		let toView = tabViewControllers?[vcIndex].view ?? UIView()

		if fromView == toView || isSelected { return false }

		let viewSize = fromView.frame
		let scrollRight = vcIndex > tabBarController.selectedIndex

		fromView.superview?.addSubview(toView)
		toView.frame = CGRect(x: scrollRight ? 320 : -320, y: viewSize.origin.y, width: viewSize.width, height: viewSize.height)

		isSelected = true

		UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
			fromView.alpha = 0
			toView.alpha = 1

			fromView.frame = CGRect(x: scrollRight ? -320 : 320, y: viewSize.origin.y, width: viewSize.width, height: viewSize.height)
			toView.frame = CGRect(x: 0, y: viewSize.origin.y, width: viewSize.width, height: viewSize.height)

		}) { finished in 
			guard finished else { return }
			fromView.removeFromSuperview()
			tabBarController.selectedIndex = vcIndex

			self.isSelected = false
		}

		return true
	}

}
