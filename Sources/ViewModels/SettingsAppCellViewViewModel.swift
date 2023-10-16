import Foundation

/// View model struct to construct the app cell for SettingsView
struct SettingsAppCellViewViewModel: Identifiable {

	private(set) var id = UUID()

	let app: App
	let onTap: (App) -> ()

	var appName: String { return app.appName }
	var appDescription: String { return app.appDescription }

}
