import UIKit


final class TabBarVC: UITabBarController {

	private var isSelected = false

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)

		let firstVC = IssuersVC()
		let secondVC = SettingsVC().makeSettingsViewUI()
		firstVC.title = "Home"
		secondVC.title = "Settings"

		let firstNav = UINavigationController(rootViewController: firstVC)
		let secondNav = UINavigationController(rootViewController: secondVC)

		let lockImage = UIImage(named: "lock")
		let gearImage = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))

		firstNav.tabBarItem = UITabBarItem(title: "Home", image: lockImage, tag: 0)
		secondNav.tabBarItem = UITabBarItem(title: "Settings", image: gearImage, tag: 1)

		let tabBarControllers = [firstNav, secondNav]
		viewControllers = tabBarControllers
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
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

extension TabBarVC: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		UserDefaults.standard.set(selectedIndex, forKey: "selectedIndex")
	}

 	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		let tabViewControllers = tabBarController.viewControllers
		let vcIndex = tabViewControllers?.firstIndex(of: viewController)

		let fromView = tabBarController.selectedViewController?.view
		let toView = tabViewControllers?[vcIndex ?? 0].view

		if fromView == toView || isSelected { return false }

		let viewSize = fromView?.frame
		let scrollRight = vcIndex ?? 0 > tabBarController.selectedIndex

		fromView?.superview?.addSubview(toView ?? UIView())
		toView?.frame = CGRect(x: scrollRight ? 320 : -320, y: viewSize?.origin.y ?? 0, width: viewSize?.width ?? 0, height: viewSize?.height ?? 0)

		isSelected = true

		UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
			fromView?.alpha = 0
			toView?.alpha = 1

			fromView?.frame = CGRect(x: scrollRight ? -320 : 320, y: viewSize?.origin.y ?? 0, width: viewSize?.width ?? 0, height: viewSize?.height ?? 0)
			toView?.frame = CGRect(x: 0, y: viewSize?.origin.y ?? 0, width: viewSize?.width ?? 0, height: viewSize?.height ?? 0)

		}, completion: { finished in 
			guard finished else { return }
			fromView?.removeFromSuperview()
			tabBarController.selectedIndex = vcIndex ?? 0

			self.isSelected = false
		})

		return true
	}

}
