import SwiftUI
import class SafariServices.SFSafariViewController

/// Struct to represent the settings view
struct SettingsView: View {

	@Environment(\.colorScheme) private var colorScheme

	@State private var showWarningAlert = false
	@State private var showCreditsSheet = false

	private let credits = """
	Credits:
	@6007135: App icon & significant contributions
	@leptos-null, @RuntimeOverflow: Significant contributions
	@L1ghtmann: Valuable contributions
	"""

	@StateObject private var viewModel = SettingsViewViewModel()

	private var copyrightLabel: String {
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
					Toggle("Use biometrics", isOn: viewModel.$useBiometrics)
						.toggleStyle(SwitchToggleStyle(tint: Color(.kAzureMintTintColor)))

					Toggle("Use floating button", isOn: viewModel.useFloatingButtonBinding)
						.toggleStyle(SwitchToggleStyle(tint: Color(.kAzureMintTintColor)))

					Button("Backup options") {
						viewModel.didTapBackupOptionsButton()
					}
					.foregroundColor(.primary)

					Button("Purge data") {
						showWarningAlert.toggle()
					}
					.foregroundColor(Color(.kAzureMintTintColor))
					.alert(isPresented: $showWarningAlert) {
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
					Button("About Azure") { showCreditsSheet.toggle() }
						.foregroundColor(.primary)
						.sheet(isPresented: $showCreditsSheet) { CreditsView() }
				}

				Section(footer: SettingsFundingCellView()) {}
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

	@ViewBuilder
	private func SettingsFundingCellView() -> some View {
		VStack(spacing: 15) {
			HStack {
				ForEach(viewModel.fundingCellViewModels) { viewModel in
					viewModel.platform.image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 25, height: 25)
						.contentShape(Rectangle())
						.onTapGesture {
							viewModel.onTap(viewModel.platform)
						}
				}
			}
			Text(copyrightLabel)
		}
		.frame(maxWidth: .infinity)
	}

	@State private var showLicenseSheet = false
	@State private var showSourceCodeSheet = false
	@State private var showFlatIconSheet = false

	@ViewBuilder
	private func CreditsView() -> some View {
		List {
			Section(header: Text("Azure")) {
				Group {
					Button("LICENSE") { showLicenseSheet.toggle() }
						.openSafariSheet(shouldShow: $showLicenseSheet, urlString: .kLicenseURL)

					Button("Source Code") { showSourceCodeSheet.toggle() }
						.openSafariSheet(shouldShow: $showSourceCodeSheet, urlString: .kSourceCodeURL)
				}
				.foregroundColor(.primary)
			}

			Section(header: Text("Credits")) {
				Button("Lock Icon") { showFlatIconSheet.toggle() }
					.foregroundColor(.primary)
					.openSafariSheet(shouldShow: $showFlatIconSheet, urlString: .kFlatIconURL)
			}

			Section(footer: Text("Lock icon created by Freepik - Flat icon.\n\n\(credits)")) {}
		}
		.padding(.top, 25)
		.listStyle(.insetGrouped)
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
