import SwiftUI
import SafariServices


struct LinksView: View {

	@Environment (\.colorScheme) private var colorScheme

	@State private var shouldShowAuroraSheet = false
	@State private var shouldShowCoraSheet = false
	@State private var shouldShowSourceCodeSheet = false

	private let auroraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.auroraswiftui"
	private let coraDepictionURL = "https://luki120.github.io/depictions/web/?p=me.luki.coraswift"
	private let sourceCodeURL = "https://github.com/Luki120/iOS-Apps/tree/main/Azure"

	init() {
		UITableView.appearance().backgroundColor = .clear
		UITableView.appearance().isScrollEnabled = false
	}

	var body: some View {

		VStack {

			Form {

				Section(header: Text("Other apps you may like")) {

					Button("Aurora") { shouldShowAuroraSheet.toggle() }
						.foregroundColor(Color(.label))
						.sheet(isPresented: $shouldShowAuroraSheet) {
							if let url = URL(string: auroraDepictionURL) {
								SafariView(url: url)
							}
						}
						.listRowBackground(colorScheme == .dark ? Color.black : Color.white)

					Button("Cora") { shouldShowCoraSheet.toggle() }
						.foregroundColor(Color(.label))
						.sheet(isPresented: $shouldShowCoraSheet) {
							if let url = URL(string: coraDepictionURL) {
								SafariView(url: url)
							}
						}
						.listRowBackground(colorScheme == .dark ? Color.black : Color.white)

				}

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

					}) {}

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
