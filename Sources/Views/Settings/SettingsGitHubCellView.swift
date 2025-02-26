import SwiftUI

/// Struct to represent the GitHub cell view
struct SettingsGitHubCellView: View {

	@ObservedObject private(set) var viewModel: SettingsGitHubCellViewViewModel

	var body: some View {
		HStack {
			Image(uiImage: viewModel.image)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 40, height: 40)
				.clipShape(.circle)

			Text(viewModel.devName)
		}
		.frame(maxWidth: .infinity, alignment: .center)
	}

}
