import UIKit


final class TOTPManager {

	static let sharedInstance = TOTPManager()

	var selectedRow = 0
	var entriesArray = [[String:String]]()
	var imagesDict = [String:UIImage]()

	private var defaults = UserDefaults.standard

	private init() {
		selectedRow = defaults.integer(forKey: "selectedRow")
		entriesArray = defaults.array(forKey: "entriesArray") as? [[String:String]] ?? [[String:String]]()
		setupImagesDict()
	}

	private func setupImagesDict() {
		let images = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath ?? "/Applications/Azure.app/").filter { $0.hasSuffix("png") }

		for img in images ?? [] {
			var components = img.components(separatedBy: ".")
			guard components.count > 1 else { return }
			components.removeLast()

			let cleanImage = components.joined(separator: ".")
			imagesDict.updateValue(UIImage(named: cleanImage) ?? UIImage(), forKey: cleanImage.lowercased())
		}
	}

	func feedSelectedRow(withRow row: Int) {
		selectedRow = row
		defaults.set(row, forKey: "selectedRow")
	}

	func feedDictionary(withIssuer issuer: String, secret: String) {
		var dict = [
			"Issuer": issuer,
			"Secret": secret,
		]
		configureEncryptionType(forDict: &dict)

		entriesArray.append(dict)
		saveDefaults()
	}

	func removeObject(at indexPath: IndexPath) {
		entriesArray.remove(at: indexPath.row)
		saveDefaults()
	}

	func removeAllObjectsFromArray() {
		entriesArray.removeAll()
		saveDefaults()
	}

	func saveDefaults() { defaults.set(entriesArray, forKey: "entriesArray") }

	private var issuerDict = [String:String]()

	func makeURL(outOfOtPauthString string: String) {
		let unsafeUrl = URL(string: string)
		guard let safeUrl = unsafeUrl else { return }

		let urlComponents = URLComponents(url: safeUrl, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems ?? []

		for item in queryItems {
			switch item.name {
				case "issuer": issuerDict["Issuer"] = item.value
				case "secret": issuerDict["Secret"] = item.value
				case "algorithm": issuerDict["encryptionType"] = item.value
				default: break
			}
  			if item.name.range(of: "algorithm") != nil {
				finished()
				return
			}
			else {
 				if item.name.range(of: "algorithm") == nil {
					issuerDict["encryptionType"] = kOTPGeneratorSHA1Algorithm
				}
 				if item.name.range(of: "issuer") == nil {
					let scanner = Scanner(string: string)
					scanner.charactersToBeSkipped = CharacterSet(charactersIn: "")
					_ = scanner.scanUpToString("/totp/")
					if let _ = scanner.scanString("/totp/") {
						if let result = scanner.scanUpToString("?") { issuerDict["Issuer"] = result }
					}
				}
			}
		}
		finished()
	}

	private func finished() {
		entriesArray.append(issuerDict)
		saveDefaults()
	}

	private func configureEncryptionType(forDict dict: inout [String:String]) {
		switch selectedRow {
			case 0: dict["encryptionType"] = kOTPGeneratorSHA1Algorithm
			case 1: dict["encryptionType"] = kOTPGeneratorSHA256Algorithm
			case 2: dict["encryptionType"] = kOTPGeneratorSHA512Algorithm
			default: break
		}
	}

}
