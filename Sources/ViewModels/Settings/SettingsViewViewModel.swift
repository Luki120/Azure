import SwiftUI
import UIKit
import class SafariServices.SFSafariViewController

/// View model class for SettingsView
final class SettingsViewViewModel {

	@AppStorage("useBiometrics") private(set) var shouldUseBiometricsToggle = false

	private(set) var appCellViewModels = [SettingsAppCellViewViewModel]()
	private(set) var ghCellViewModels = [SettingsGitHubCellViewViewModel]()

	/// Designated initializer
	init() {
		setupModels()
	}

	private func setupModels() {
		appCellViewModels = [
			.init(app: .aurora) { [weak self] app in
				self?.openURL(app.appURL)
			},
			.init(app: .cora) { [weak self] app in
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
	}

	private func openURL(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
