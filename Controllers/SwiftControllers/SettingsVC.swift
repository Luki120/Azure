import Foundation
import SwiftUI


@objc public class SettingsVC: UIViewController {

	@objc public func makeSettingsViewUI() -> UIViewController {
		let view = SettingsView()
		let hostingController = UIHostingController(rootView: view)
		return hostingController
	}

}
