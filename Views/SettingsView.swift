import SwiftUI
import SafariServices


struct SettingsView: View {

	@AppStorage("useBiometrics") private var shouldUseBiometricsToggle = false

	@Environment (\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowSourceCodeSheet = false

	private let auroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.auroraswiftui"
	private let coraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.coraswift"
	private let sourceCodeURL = "https://github.com/Luki120/iOS-Apps/tree/main/Azure"

	init() {
		UITableView.appearance().backgroundColor = .clear
//		UITableView.appearance().isScrollEnabled = false
	}

	var body: some View {

		VStack {

			Form {

				Section(header: Text("Settings")) {

					Toggle("Use biometrics", isOn: $shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: Color(.systemTeal)))

					Button("Purge data") {
						shouldShowWarningAlert.toggle()
					}
					.foregroundColor(Color(.systemRed))
					.alert(isPresented: $shouldShowWarningAlert) {
						Alert(
							title: Text("Azure"),
							message: Text("YO DUDE!! Hold up right there. You’re about to purge ALL of your 2FA codes and your data, ARE YOU ABSOLUTELY SURE? ❗️❗️Don’t be a dumbass, you’ll regret it later. I warned you 😈."),
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
							if let url = URL(string: auroraDepictionURL) {
								SafariView(url: url)
							}
						}

					Button("Cora") { shouldShowCoraSheet.toggle() }
						.foregroundColor(Color(.label))
						.sheet(isPresented: $shouldShowCoraSheet) {
							if let url = URL(string: coraDepictionURL) {
								SafariView(url: url)
							}
						}

				}
				.listRowBackground(colorScheme == .dark ? Color.black : Color.white)

				Section(footer:

					HStack {

						Spacer()

						VStack {

							Button("Source Code") { shouldShowSourceCodeSheet.toggle() }
								.font(.system(size: 15.5))
								.foregroundColor(.gray)
								.sheet(isPresented: $shouldShowSourceCodeSheet) {
									if let url = URL(string: sourceCodeURL) {
										SafariView(url: url)
									}
								}

							Text("2021 © Luki120")
								.font(.system(size: 10))
								.foregroundColor(.gray)
								.padding(.top, 5)

						}

						Spacer()

					}

				) {}

			}

		}

	}

}


private struct SafariView: UIViewControllerRepresentable {

	let url: URL

	func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

	}

}
