import UIKit

/// Singleton manager to handle the creation, deletion & saving of issuers
final class TOTPManager {

	private let kIssuersPath = "/Applications/Azure.app/Issuers/"

	static let sharedInstance = TOTPManager()

	var issuers = [Issuer]()

	private var defaults = UserDefaults.standard
	private(set) var selectedRow = 0
	private(set) var imagesDict = [String:UIImage]()

	private init() {
		selectedRow = defaults.integer(forKey: "selectedRow")

		retrieveIssuers()
		setupImagesDict()
	}

	private func retrieveIssuers() {
		guard let data = defaults.data(forKey: "issuersData") else {
			issuers = []
			return
		}

		let decodedIssuers = try? JSONDecoder().decode([Issuer].self, from: data)
		issuers = decodedIssuers ?? []
	}

	private func setupImagesDict() {
		let imagesArray = try? Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Issuers") ??
			FileManager.default.contentsOfDirectory(atPath: kIssuersPath).compactMap { URL(string: $0) }

		for image in imagesArray ?? [] {
			let strippedName = image.lastPathComponent.components(separatedBy: ".").first!
			imagesDict.updateValue(UIImage(named: "Issuers/" + strippedName)!, forKey: strippedName.lowercased())
		}
	}

	private func appendIssuer(withName name: String, secret: Data, algorithm: Issuer.Algorithm) {
		issuers.append(.init(name: name, secret: secret, algorithm: algorithm))
		saveIssuers()
	}

}

extension TOTPManager {

	// Public

	/// Function to create an issuer from the given url
	/// Parameters:
	///		- outOfOtPauthString: The ot pauth url string
	func createIssuer(outOfOtPauthString string: String) {
		guard let safeUrl = URL(string: string) else { return }

		let urlComponents = URLComponents(url: safeUrl, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems ?? []

		var name = ""
		var secret = ""
		var algorithm: Issuer.Algorithm = .sha1

		for item in queryItems {
			switch item.name {
				case "issuer": name = item.value ?? ""
				case "secret": secret = item.value ?? ""
				case "algorithm":
					switch item.value {
						case "SHA1": algorithm = .sha1
						case "SHA256": algorithm = .sha256
						case "SHA512": algorithm = .sha512
						default: break
					}
				default: break
			}
		}
		guard !name.isEmpty else {
			let scanner = Scanner(string: string)
			guard scanner.scanUpToString("/totp/") != nil,
				scanner.scanString("/totp/") != nil,
				let scannedName = scanner.scanUpToString("?") else { return }

			appendIssuer(withName: scannedName, secret: .base32DecodedString(secret), algorithm: algorithm)
			return
		}
		appendIssuer(withName: name, secret: .base32DecodedString(secret), algorithm: algorithm)
	}

	/// Function to pass an index path's row to configure the encryption algorithm
	/// - Paramaters:
	///		- row: The given row
	func feedSelectedRow(withRow row: Int) {
		selectedRow = row
		defaults.set(row, forKey: "selectedRow")
	}

	/// Function to create an issuer with the data passed from the input fields
	/// - Parameters:
	///		- withName: A string to represent the issuer's name
	///		- secret: The secret hash data
	func feedIssuer(withName name: String, secret: Data) {
		var algorithm: Issuer.Algorithm = .sha1

		switch selectedRow {
			case 0: algorithm = .sha1
			case 1: algorithm = .sha256
			case 2: algorithm = .sha512
			default: break
		}

		appendIssuer(withName: name, secret: secret, algorithm: algorithm)
	}

	/// Function to encode the issuers as data and save them to disk
	func saveIssuers() {
		guard let encodedIssuers = try? JSONEncoder().encode(issuers) else { return }
		defaults.set(encodedIssuers, forKey: "issuersData")
	}

	/// Function to remove an issuer from the issuers array
	/// - Parameters:
	///     - at: The given index path
	func removeIssuer(at indexPath: IndexPath) {
		issuers.remove(at: indexPath.row)
		saveIssuers()
	}

	/// Function to remove all issuers from the issuers array
	func removeAllIssuers() {
		issuers.removeAll()
		saveIssuers()
	}

}
