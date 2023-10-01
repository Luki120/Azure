import SwiftUI
import class SafariServices.SFSafariViewController

/// Struct to represent the settings view
struct SettingsView: View {

	@AppStorage("useBiometrics") private var shouldUseBiometricsToggle = false
	@Environment(\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowCreditsSheet = false

	private let kAzureMintTintColor = Color(red: 0.40, green: 0.81, blue: 0.73)

	private let credits = """
	Credits:
	@6007135: App icon & significant contributions
	@RuntimeOverflow: Significant contributions
	@leptos-null, @L1ghtmann: Valuable contributions
	"""

	var body: some View {
		VStack {
			List {
				Section(header: Text("Settings")) {
					Toggle("Use biometrics", isOn: $shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: kAzureMintTintColor))

					Button("Backup options") {
						NotificationCenter.default.post(name: .shouldMakeBackupNotification, object: nil)
					}
					.foregroundColor(.primary)

					Button("Purge data") {
						shouldShowWarningAlert.toggle()
					}
					.foregroundColor(kAzureMintTintColor)
					.alert(isPresented: $shouldShowWarningAlert) {
						Alert(
							title: Text("Azure"),
							message: Text("Dude, hold up right there. You’re about to purge ALL of your 2FA codes and data, ARE YOU ABSOLUTELY SURE? ❗️❗Don’t be a dumbass, you’ll regret it later, I warned you. Besides, keep in mind that this won't remove 2FA from your accounts, so make sure you also disable it from the issuers' settings in order to prevent being locked out."),
							primaryButton: .destructive(Text("I'm sure")) {
								NotificationCenter.default.post(name: .didPurgeDataNotification, object: nil)
							},
							secondaryButton: .cancel()
						)
					}
				}

				Section(header: Text("Other apps you may like")) {
					VStack(alignment: .leading) {
						Button("Aurora") { shouldShowAuroraSheet.toggle() }
							.foregroundColor(.primary)
							.openSafariSheet(shouldShow: $shouldShowAuroraSheet, urlString: .kAuroraDepictionURL)

						ReusableText("Vanilla password manager")
					}

					VStack(alignment: .leading) {
						Button("Cora") { shouldShowCoraSheet.toggle() }
							.foregroundColor(.primary)
							.openSafariSheet(shouldShow: $shouldShowCoraSheet, urlString: .kCoraDepictionURL)

						ReusableText("See your device's uptime in less clicks")
					}
				}

				Section(header: Text("Misc")) {
					Button("Credits") { shouldShowCreditsSheet.toggle() }
						.foregroundColor(.primary)
						.sheet(isPresented: $shouldShowCreditsSheet) { CreditsView() }
				}
			}
			.listStyle(.insetGrouped)
		}
	}

	@State private var shouldShowLicenseSheet = false
	@State private var shouldShowSourceCodeSheet = false
	@State private var shouldShowGoogleAuthenticatorSheet = false
	@State private var shouldShowFlatIconSheet = false

	@ViewBuilder
	private func CreditsView() -> some View {
		List {
			Section(header: Text("Azure")) {
				Group {
					Button("LICENSE") { shouldShowLicenseSheet.toggle() }
						.openSafariSheet(shouldShow: $shouldShowLicenseSheet, urlString: .kLicenseURL)

					Button("Source Code") { shouldShowSourceCodeSheet.toggle() }
						.openSafariSheet(shouldShow: $shouldShowSourceCodeSheet, urlString: .kSourceCodeURL)
				}
				.foregroundColor(.primary)
			}

			Section(header: Text("Credits")) {
				Button("Lock Icon") { shouldShowFlatIconSheet.toggle() }
					.foregroundColor(.primary)
					.openSafariSheet(shouldShow: $shouldShowFlatIconSheet, urlString: .kFlatIconURL)
			}

			Section(footer: Text("Lock icon created by Freepik - Flat icon.\n\n© 2022-2023 Luki120\n\n\(credits)")) {}
		}
		.padding(.top, 25)
		.listStyle(.insetGrouped)
	}

	@ViewBuilder
	private func ReusableText(_ text: String) -> some View {
		Text(text)
			.foregroundColor(.gray)
			.font(.system(size: 10))
	}

}

private struct SafariView: UIViewControllerRepresentable {

	let url: URL?

	func makeUIViewController(context: Context) -> SFSafariViewController {
		let fallbackURL = URL(string: "https://github.com/Luki120")! // this 100% exists so it's safe
		guard let url else { return .init(url: fallbackURL) }
		return .init(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

}

private extension String {
	static let kAuroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.aurora"
	static let kCoraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.cora"
	static let kSourceCodeURL = "https://github.com/Luki120/Azure"
	static let kFlatIconURL = "https://www.flaticon.com/free-icons/caps-lock"
	static let kLicenseURL = "https://github.com/Luki120/Azure/blob/main/LICENSE"
}

private extension View {
	func openSafariSheet(shouldShow: Binding<Bool>, urlString: String) -> some View {
		self
			.sheet(isPresented: shouldShow) { SafariView(url: URL(string: urlString)) }
	}
}
