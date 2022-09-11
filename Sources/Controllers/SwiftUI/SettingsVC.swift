import SwiftUI


final class SettingsVC {

	func makeSettingsViewUI() -> UIViewController {
		let view = SettingsView()
		let hostingController = UIHostingController(rootView: view)
		return hostingController
	}

}
