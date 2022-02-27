import SwiftUI
import SafariServices


struct SettingsView: View {

	@AppStorage("useBiometrics") private var shouldUseBiometricsToggle = false

	@Environment(\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowSourceCodeSheet = false

	private let auroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.auroraswiftui"
	private let coraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.coraswiftui"
	private let sourceCodeURL = "https://github.com/Luki120/iOS-Apps/tree/main/Azure"

	private let kAzureMintTintColor = Color(red: 0.40, green: 0.81, blue: 0.73)

	init() {
		UITableView.appearance().backgroundColor = .clear
		UITableView.appearance().isScrollEnabled = false
	}

	var body: some View {

		VStack {

			Form {

				Section(header: Text("Settings")) {

					Toggle("Use biometrics", isOn: $shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: kAzureMintTintColor))

					Button("Purge data") {
						shouldShowWarningAlert.toggle()
					}
					.foregroundColor(kAzureMintTintColor)
					.alert(isPresented: $shouldShowWarningAlert) {
						Alert(
							title: Text("Azure"),
							message: Text("YO DUDE!! Hold up right there. You’re about to purge ALL of your 2FA codes and data, ARE YOU ABSOLUTELY SURE? ❗️❗️Don’t be a dumbass, you’ll regret it later. I warned you 😈."),
							primaryButton: .destructive(Text("I'm sure")) {
								NotificationCenter.default.post(name: Notification.Name("purgeDataDone"), object: nil)
							},
							secondaryButton: .cancel()
						)

					}

				}
				.listRowBackground(colorScheme == .dark ? Color.black : Color.white)

				Section(header: Text("Other apps you may like")) {

					Button("Aurora") { shouldShowAuroraSheet.toggle() }
						.foregroundColor(Color(.label))
						.sheet(isPresented: $shouldShowAuroraSheet) {
							SafariView(url: URL(string: auroraDepictionURL))
						}

					Button("Cora") { shouldShowCoraSheet.toggle() }
						.foregroundColor(Color(.label))
						.sheet(isPresented: $shouldShowCoraSheet) {
							SafariView(url: URL(string: coraDepictionURL))
						}

				}
				.listRowBackground(colorScheme == .dark ? Color.black : Color.white)

			}

			Section(footer: Text("")) {

				VStack {

					Button("Source Code") { shouldShowSourceCodeSheet.toggle() }
						.font(.system(size: 15.5))
						.foregroundColor(.gray)
						.sheet(isPresented: $shouldShowSourceCodeSheet) {
							SafariView(url: URL(string: sourceCodeURL))
						}

					Text("2022 © Luki120")
						.font(.system(size: 10))
						.foregroundColor(.gray)
						.padding(.top, 5)

				}

			}
			.padding(.top, 25)

		}

	}

}


private struct SafariView: UIViewControllerRepresentable {

	let url: URL?

	func makeUIViewController(context: Context) -> SFSafariViewController {

		let fallbackURL = URL(string: "https://github.com/Luki120")! // this 100% exists so it's safe

		guard let url = url else {
			return SFSafariViewController(url: fallbackURL)
		}

		return SFSafariViewController(url: url)

	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {

	}

}
