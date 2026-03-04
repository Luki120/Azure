import SwiftUI

/// Struct to represent the GitHub cell view
struct SettingsGitHubCellView: View {
	@ObservedObject private(set) var viewModel: SettingsGitHubCellViewViewModel
	@ScaledMetric private var imageHeight = 40

	var body: some View {
		HStack {
			Image(uiImage: viewModel.image)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(height: imageHeight)
				.clipShape(.circle)

			Text(viewModel.devName)
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}
}
