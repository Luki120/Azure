import UIKit
import func SwiftUI.withAnimation

/// View model class for `SettingsGitHubCellView`
@MainActor
final class SettingsGitHubCellViewViewModel: Identifiable, ObservableObject {
	let id = UUID()
	let developer: Developer
	let onTap: (Developer) -> ()

	var devName: String { return developer.devName }
	var targetURL: URL? { return developer.targetURL }

	@Published private(set) var image = UIImage()

	/// Designated initializer
	/// - Parameters:
	/// 	- developer: A `Developer` object to represent the developer
	/// 	- onTap: An `@escaping` closure that takes a `Developer` object as argument & returns nothing
	init(developer: Developer, onTap: @escaping (Developer) -> ()) {
		self.developer = developer
		self.onTap = onTap

		Task {
			await fetchImage()
		}
	}

	nonisolated
	private func fetchImage() async {
		guard let url = URL(string: developer == .luki ? Developer.lukiIcon : Developer.cookiesIcon) else {
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, _, error in
			guard let data, let image = UIImage(data: data), error == nil else { return }

			Task {
				await MainActor.run {
					withAnimation(.smooth) {
						self.image = image
					}
				}
			}
		}
		task.resume()
	}
}
