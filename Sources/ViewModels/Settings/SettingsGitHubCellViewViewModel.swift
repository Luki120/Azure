import UIKit
import func SwiftUI.withAnimation

/// View model class for SettingsGitHubCellView
final class SettingsGitHubCellViewViewModel: Identifiable, ObservableObject {

	let id = UUID()
	let developer: Developer
	let onTap: (Developer) -> ()
	private let imageURLString: String?

	var devName: String { return developer.devName }
	var targetURL: URL? { return developer.targetURL }

	@Published private(set) var image = UIImage()

	private let imageCache = NSCache<NSString, UIImage>()

	/// Designated initializer
	/// - Parameters:
	/// 	- developer: A Developer object to represent the developer
	/// 	- imageURLString: An optional string to represent the image's url string
	/// 	- onTap: An escaping closure that takes a Developer object as argument & returns void
	init(developer: Developer, imageURLString: String?, onTap: @escaping (Developer) -> ()) {
		self.developer = developer
		self.imageURLString = imageURLString
		self.onTap = onTap
		fetchImage()
	}

	private func fetchImage() {
		guard let imageURLString, let url = URL(string: imageURLString) else { return }

		if let cachedImage = imageCache.object(forKey: imageURLString as NSString) {
			DispatchQueue.main.async {
				self.image = cachedImage
			}
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, _, error in
			guard let data, let image = UIImage(data: data), error == nil else { return }
			self.imageCache.setObject(image, forKey: imageURLString as NSString)

			DispatchQueue.main.async {
				withAnimation(.easeInOut) {
					self.image = image
				}
			}
		}
		task.resume()
	}

}
