import Foundation

/// View model struct to construct the funding cell for SettingsView
struct SettingsFundingCellViewViewModel: Identifiable {

	let id = UUID()
	let platform: FundingPlatform
	let onTap: (FundingPlatform) -> ()

	var name: String { return platform.name }

}
