import SwiftUI


@objcMembers public class SettingsVC: UIViewController {

	public func makeSettingsViewUI() -> UIViewController {
		let view = SettingsView()
		let hostingController = UIHostingController(rootView: view)
		return hostingController
	}

}
