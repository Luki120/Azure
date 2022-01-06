import Foundation
import SwiftUI


@objc public class LinksVC: UIViewController {

	@objc public func makeLinksViewUI() -> UIViewController {
		let view = LinksView()
		let hostingController = UIHostingController(rootView: view)
		return hostingController
	}

}
