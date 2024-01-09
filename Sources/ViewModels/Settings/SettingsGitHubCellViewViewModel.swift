import UIKit

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
		guard let imageURLString else { return }
			fetchImage(imageURLString) { [weak self] result in
			switch result {
				case .success(let image):
					DispatchQueue.main.async {
						self?.image = image
					}

				case .failure: break
			}
		}
	}

	private func fetchImage(_ urlString: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
		if let cachedImage = imageCache.object(forKey: urlString as NSString) {
			completion(.success(cachedImage))
			return
		}

		guard let url = URL(string: urlString) else {
			completion(.failure(URLError(.badURL)))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, _, error in
			guard let data, let image = UIImage(data: data), error == nil else {
				completion(.failure(error ?? URLError(.badServerResponse)))
				return
			}
			self.imageCache.setObject(image, forKey: urlString as NSString)
			completion(.success(image))
		}
		task.resume()
	}

}
