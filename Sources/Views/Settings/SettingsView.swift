import SwiftUI
import SafariServices


struct SettingsView: View {

	@AppStorage("useBiometrics") private var shouldUseBiometricsToggle = false
	@Environment(\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowCreditsSheet = false

	private let kAzureMintTintColor = Color(red: 0.40, green: 0.81, blue: 0.73)

	var body: some View {

		VStack {

			List {

				Section(header: Text("Settings")) {
					Toggle("Use biometrics", isOn: $shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: kAzureMintTintColor))

					Button("Backup options") {
						NotificationCenter.default.post(name: Notification.Name("makeBackup"), object: nil)
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
								NotificationCenter.default.post(name: Notification.Name("purgeDataDone"), object: nil)
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

						Text("Vanilla password manager")
							.foregroundColor(.gray)
							.font(.system(size: 10))
					}

					VStack(alignment: .leading) {
						Button("Cora") { shouldShowCoraSheet.toggle() }
							.foregroundColor(.primary)
							.openSafariSheet(shouldShow: $shouldShowCoraSheet, urlString: .kCoraDepictionURL)

						Text("See your device's uptime in less clicks")
							.foregroundColor(.gray)
							.font(.system(size: 10))
					}
				}

				Section(header: Text("Misc")) {
					Button("Credits") { shouldShowCreditsSheet.toggle() }
						.foregroundColor(.primary)
						.sheet(isPresented: $shouldShowCreditsSheet) { creditsView }
				}

			}
			.listStyle(InsetGroupedListStyle())

		}

	}

	@State private var shouldShowLicenseSheet = false
	@State private var shouldShowSourceCodeSheet = false
	@State private var shouldShowGoogleAuthenticatorSheet = false
	@State private var shouldShowFlatIconSheet = false

	private var creditsView: some View {

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

				Group {
					Button("Google Authenticator") { shouldShowGoogleAuthenticatorSheet.toggle() }
						.openSafariSheet(shouldShow: $shouldShowGoogleAuthenticatorSheet, urlString: .kGoogleAuthenticatorURL)

					Button("Lock Icon") { shouldShowFlatIconSheet.toggle() }
						.openSafariSheet(shouldShow: $shouldShowFlatIconSheet, urlString: .kFlatIconURL)
				}
				.foregroundColor(.primary)

			}

			Section(footer: Text("Azure uses open source components from Google Authenticator, which are licensed under the Apache-2.0 License.\n\nLock icon created by Freepik - Flat icon.\n\n2022 © Luki120 ")) {}

		}
		.padding(.top, 25)
		.listStyle(InsetGroupedListStyle())

	}

}

private struct SafariView: UIViewControllerRepresentable {

	let url: URL?

	func makeUIViewController(context: Context) -> SFSafariViewController {
		let fallbackURL = URL(string: "https://github.com/Luki120")! // this 100% exists so it's safe
		guard let url = url else { return SFSafariViewController(url: fallbackURL) }
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

}

private extension String {
	static let kAuroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.aurora"
	static let kCoraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.cora"
	static let kSourceCodeURL = "https://github.com/Luki120/Azure"
	static let kFlatIconURL = "https://www.flaticon.com/free-icons/caps-lock"
	static let kGoogleAuthenticatorURL = "https://github.com/google/google-authenticator"
	static let kLicenseURL = "https://github.com/Luki120/Azure/blob/main/LICENSE"
}

private extension View {
	func openSafariSheet(shouldShow: Binding<Bool>, urlString: String) -> some View {
		self
			.sheet(isPresented: shouldShow) { SafariView(url: URL(string: urlString)) }
	}
}
