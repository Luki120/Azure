import SwiftUI
import UIKit
import class SafariServices.SFSafariViewController

/// View model class for SettingsView
final class SettingsViewViewModel {

	@AppStorage("useBiometrics") private(set) var useBiometrics = false
	@AppStorage("useFloatingButton") private var useFloatingButton = false

	private(set) var appCellViewModels = [SettingsAppCellViewViewModel]()
	private(set) var ghCellViewModels = [SettingsGitHubCellViewViewModel]()
	private(set) var fundingCellViewModels = [SettingsFundingCellViewViewModel]()

	var useFloatingButtonBinding: Binding<Bool> {
		Binding(
			get: { self.useFloatingButton },
			set: { newValue in
				self.useFloatingButton = newValue
				NotificationCenter.default.post(name: .shouldUseFloatingButtonNotification, object: nil)
			}
		)
	}

	/// Designated initializer
	init() {
		setupModels()
	}

	private func setupModels() {
		appCellViewModels = [
			.init(app: .areesha) { [weak self] app in
				self?.openURL(app.appURL)
			},
			.init(app: .aurora) { [weak self] app in
				self?.openURL(app.appURL)
			}
		]

		ghCellViewModels = [
			.init(developer: .luki, imageURLString: Developer.lukiIcon) { [weak self] developer in
				self?.openURL(developer.targetURL)
			},
			.init(developer: .cookies, imageURLString: Developer.cookiesIcon) { [weak self] developer in
				self?.openURL(developer.targetURL)
			}
		]

		fundingCellViewModels = [
			.init(platform: .kofi) { [weak self] platform in
				self?.openURL(platform.url)
			},
			.init(platform: .paypal) { [weak self] platform in
				self?.openURL(platform.url)
			}
		]
	}

	private func openURL(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url)
	}

}

extension SettingsViewViewModel {

	// ! Public

	/// Function to send a notification when the backup options button is tapped
	func didTapBackupOptionsButton() {
		NotificationCenter.default.post(name: .shouldMakeBackupNotification, object: nil)
	}

	/// Function to send a notification when the purge data button is tapped
	func didTapPurgeDataButton() {
		NotificationCenter.default.post(name: .didPurgeDataNotification, object: nil)
	}

}
