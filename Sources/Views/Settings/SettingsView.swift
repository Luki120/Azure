import SwiftUI
import class SafariServices.SFSafariViewController

/// Struct to represent the settings view
struct SettingsView: View {

	@Environment(\.colorScheme) private var colorScheme

	@State private var shouldShowWarningAlert = false
	@State private var shouldShowCreditsSheet = false

	private let kAzureMintTintColor = Color(red: 0.40, green: 0.81, blue: 0.73)

	private let credits = """
	Credits:
	@6007135: App icon & significant contributions
	@leptos-null, @RuntimeOverflow: Significant contributions
	@L1ghtmann: Valuable contributions
	"""

	private let viewModel = SettingsViewViewModel()

	private var copyrightYear: String {
		if #available(iOS 15.0, *) {
			return "© 2022-\(Date.now.formatted(.dateTime.year())) Luki120"
		}
		else {
			return "© 2022-\(Calendar.current.component(.year, from: Date())) Luki120"
		}
	}

	var body: some View {
		VStack {
			List {
				Section(header: Text("Developers")) {
					HStack {
						ForEach(viewModel.ghCellViewModels, id: \.id) { index, viewModel in
							SettingsGitHubCellView(viewModel: viewModel)
								.padding(.horizontal, 2.5)
								.onTapGesture {
									viewModel.onTap(viewModel.developer)
								}
							if index == 0 { Divider() }
						}
					}
				}

				Section(header: Text("Settings")) {
					Toggle("Use biometrics", isOn: viewModel.$shouldUseBiometricsToggle)
						.toggleStyle(SwitchToggleStyle(tint: kAzureMintTintColor))

					Button("Backup options") {
						viewModel.didTapBackupOptionsButton()
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
								viewModel.didTapPurgeDataButton()
							},
							secondaryButton: .cancel()
						)
					}
				}

				Section(header: Text("Other apps you may like")) {
					SettingsAppCellView()
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

	@ViewBuilder
	private func SettingsAppCellView() -> some View {
		ForEach(viewModel.appCellViewModels) { viewModel in
			VStack(alignment: .leading) {
				Text(viewModel.appName)

				Text(viewModel.appDescription)
					.font(.system(size: 10))
					.foregroundColor(.secondary)
			}
			.onTapGesture {
				viewModel.onTap(viewModel.app)
			}
		}
	}

	@State private var shouldShowLicenseSheet = false
	@State private var shouldShowSourceCodeSheet = false
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

			Section(header: Text("Support development")) {
				SettingsFundingCellView()
			}

			Section(header: Text("Credits")) {
				Button("Lock Icon") { shouldShowFlatIconSheet.toggle() }
					.foregroundColor(.primary)
					.openSafariSheet(shouldShow: $shouldShowFlatIconSheet, urlString: .kFlatIconURL)
			}

			Section(footer: Text("Lock icon created by Freepik - Flat icon.\n\n\(copyrightYear)\n\n\(credits)")) {}
		}
		.padding(.top, 25)
		.listStyle(.insetGrouped)
	}

	@ViewBuilder
	private func SettingsFundingCellView() -> some View {
		ForEach(viewModel.fundingCellViewModels) { viewModel in
			VStack(alignment: .leading) {
				Text(viewModel.name)
			}
			.onTapGesture {
				viewModel.onTap(viewModel.platform)
			}
		}
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

// credits ⇝ https://gist.github.com/leptos-null/e521cbd4a8246ea824d823fc398ba255
private extension ForEach {
	init<Base: Sequence>(_ base: Base, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data == Array<EnumeratedSequence<Base>.Element>, ID == Base.Element, Content: View, ID: Identifiable {
		self.init(Array(base.enumerated()), id: \.element, content: content)
	}

	init<Base: Sequence>(_ base: Base, id: KeyPath<Base.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data == Array<EnumeratedSequence<Base>.Element>, Content: View {
		let basePath: KeyPath<EnumeratedSequence<Base>.Element, Base.Element> = \.element
		self.init(Array(base.enumerated()), id: basePath.appending(path: id), content: content)
	}
}

private extension String {
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
