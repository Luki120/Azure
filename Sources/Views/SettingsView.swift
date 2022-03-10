import SwiftUI
import SafariServices


struct SettingsView: View {

	@AppStorage("useBiometrics") private var shouldUseBiometricsToggle = false
	@Environment(\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowCreditsSheet = false

	var body: some View {

		VStack {

			List {

				Section(header: Text("Settings")) {

					Toggle("Use biometrics", isOn: $shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: Constants.kAzureMintTintColor))

					Button("Make backup") {
						NotificationCenter.default.post(name: Notification.Name("makeBackup"), object: nil)
					}
					.foregroundColor(Color(.label))

					Button("Purge data") {
						shouldShowWarningAlert.toggle()
					}
					.foregroundColor(Constants.kAzureMintTintColor)
					.alert(isPresented: $shouldShowWarningAlert) {
						Alert(
							title: Text("Azure"),
							message: Text("Dude, hold up right there. You’re about to purge ALL of your 2FA codes and data, ARE YOU ABSOLUTELY SURE? ❗️❗️Don’t be a dumbass, you’ll regret it later. I warned you 😈. Also keep in mind that this won't remove 2FA from your accounts, so make sure you disable it from the issuers' settings in order to prevent being locked out."),
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
							.foregroundColor(Color(.label))
							.sheet(isPresented: $shouldShowAuroraSheet) {
								SafariView(url: URL(string: Constants.kAuroraDepictionURL))
							}

						Text("Vanilla password manager")
							.foregroundColor(.gray)
							.font(.system(size: 10))

					}

					VStack(alignment: .leading) {

						Button("Cora") { shouldShowCoraSheet.toggle() }
							.foregroundColor(Color(.label))
							.sheet(isPresented: $shouldShowCoraSheet) {
								SafariView(url: URL(string: Constants.kCoraDepictionURL))
							}

						Text("See your device's uptime in less clicks")
							.foregroundColor(.gray)
							.font(.system(size: 10))

					}

				}

				Section(header: Text("Misc")) {

					Button("Credits") { shouldShowCreditsSheet.toggle() }
						.foregroundColor(Color(.label))
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

				Button("LICENSE") { shouldShowLicenseSheet.toggle() }
					.foregroundColor(Color(.label))
					.sheet(isPresented: $shouldShowLicenseSheet) {
						SafariView(url: URL(string: Constants.kLicenseURL))
					}

				Button("Source Code") { shouldShowSourceCodeSheet.toggle() }
					.foregroundColor(Color(.label))
					.sheet(isPresented: $shouldShowSourceCodeSheet) {
						SafariView(url: URL(string: Constants.kSourceCodeURL))
					}

			}
			Section(header: Text("Credits")) {

				Button("Google Authenticator") { shouldShowGoogleAuthenticatorSheet.toggle() }
					.foregroundColor(Color(.label))
					.sheet(isPresented: $shouldShowGoogleAuthenticatorSheet) {
						SafariView(url: URL(string: Constants.kGoogleAuthenticatorURL))
					}

				Button("Lock Icon") { shouldShowFlatIconSheet.toggle() }
					.foregroundColor(Color(.label))
					.sheet(isPresented: $shouldShowFlatIconSheet) {
						SafariView(url: URL(string: Constants.kFlatIconURL))
					}

			}
			Section(footer: Text("Azure uses open source components from Google Authenticator, which are licensed under the Apache-2.0 License.")) {}
			Section(footer: Text("Lock icon created by Freepik - Flat icon.")) {}
			Section(footer: Text("2022 © Luki120")) {}

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

private struct Constants {

	static let kAuroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.auroraswiftui"
	static let kCoraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.coraswiftui"
	static let kSourceCodeURL = "https://github.com/Luki120/Azure"
	static let kFlatIconURL = "https://www.flaticon.com/free-icons/caps-lock"
	static let kGoogleAuthenticatorURL = "https://github.com/google/google-authenticator"
	static let kLicenseURL = "https://github.com/Luki120/Azure/blob/main/LICENSE"
	static let kAzureMintTintColor = Color(red: 0.40, green: 0.81, blue: 0.73)

}
