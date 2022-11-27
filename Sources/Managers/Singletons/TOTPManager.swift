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
		let imagesArray = try? Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Issuers") ??
			FileManager.default.contentsOfDirectory(atPath: .kIssuersPath).compactMap { URL(string: $0) }

		for image in imagesArray ?? [] {
			let strippedName = image.lastPathComponent.components(separatedBy: ".").first!
			imagesDict.updateValue(UIImage(named: "Issuers/" + strippedName)!, forKey: strippedName.lowercased())
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
		guard let safeUrl = URL(string: string) else { return }

		let urlComponents = URLComponents(url: safeUrl, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems ?? []

		for item in queryItems {
			switch item.name {
				case "issuer": issuerDict["Issuer"] = item.value
				case "secret": issuerDict["Secret"] = item.value
				case "algorithm": issuerDict["encryptionType"] = item.value
				default: break
			}
		}
		if issuerDict.keys.contains("Issuer") && issuerDict.keys.contains("encryptionType") {
			finished()
			return
		}
		else {
			if issuerDict["encryptionType"] == nil { issuerDict["encryptionType"] = kOTPGeneratorSHA1Algorithm }
			if issuerDict["Issuer"] == nil {
				let scanner = Scanner(string: string)
				if scanner.scanUpToString("/totp/") != nil {
					if scanner.scanString("/totp/") != nil {
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
