import UIKit


final class TOTPManager {

	static let sharedInstance = TOTPManager()

	var selectedRow = 0
	var entriesArray: NSMutableArray!
	var imagesDict = [String: UIImage]()

	private var defaults = UserDefaults.standard

	init() {
		selectedRow = defaults.integer(forKey: "selectedRow")
		entriesArray = NSMutableArray(array: defaults.array(forKey: "entriesArray") ?? [])
		setupImagesDict()
	}

	private func setupImagesDict() {
		imagesDict = [
			"dashlane": UIImage(named: "Dashlane") ?? UIImage(),
			"discord": UIImage(named: "Discord") ?? UIImage(),
			"facebook": UIImage(named: "Facebook") ?? UIImage(),
			"github": UIImage(named: "GitHub") ?? UIImage(),
			"instagram": UIImage(named: "Instagram") ?? UIImage(),
			"kraken": UIImage(named: "Kraken") ?? UIImage(),
			"snapchat": UIImage(named: "Snapchat") ?? UIImage(),
			"paypal": UIImage(named: "PayPal") ?? UIImage(),
			"twitter": UIImage(named: "Twitter") ?? UIImage(),
			"zoho": UIImage(named: "ZohoMail") ?? UIImage(),
			"zohomail": UIImage(named: "ZohoMail") ?? UIImage()
		]
	}

	func feedSelectedRow(withRow row: Int) {
		selectedRow = row
		defaults.set(row, forKey: "selectedRow")
	}

	func feedDictionary(withObject obj: String, andObject: String) {
		let issuersDict = NSMutableDictionary()
		issuersDict.setObject(obj, forKey: "Issuer" as NSCopying)
		issuersDict.setObject(andObject, forKey: "Secret" as NSCopying)
		configureEncryptionType(forDict: issuersDict)

		entriesArray.add(issuersDict)
		saveDefaults()
	}

	func removeObjectAtIndexPath(forRow row: Int) {
		entriesArray.removeObject(at: row)
		saveDefaults()
	}

	func removeAllObjectsFromArray() {
		entriesArray.removeAllObjects()
		saveDefaults()
	}

	func saveDefaults() {
		defaults.set(entriesArray, forKey: "entriesArray")
	}

	private let issuerDict = NSMutableDictionary()

	func makeURL(outOfOtPauthString string: String) {
		let unsafeUrl = URL(string: string)
		guard let url = unsafeUrl else { return }

		let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		let queryItems = urlComponents?.queryItems ?? []

		for item in queryItems {
			switch item.name {
				case "issuer": issuerDict.setObject(item.value ?? "", forKey: "Issuer" as NSCopying)
				case "secret": issuerDict.setObject(item.value ?? "", forKey: "Secret" as NSCopying)
				case "algorithm": issuerDict.setObject(item.value ?? "", forKey: "encryptionType" as NSCopying)
				default: break
			}
 			if item.name.range(of: "algorithm") != nil && item.name.range(of: "issuer") != nil {
				finished()
				break
			}
			else {
				if item.name.range(of: "algorithm") == nil {
					issuerDict.setObject(kOTPGeneratorSHA1Algorithm, forKey: "encryptionType" as NSCopying)
				}
 				if item.name.range(of: "issuer") == nil {
					let scanner = Scanner(string: string)
					scanner.charactersToBeSkipped = CharacterSet(charactersIn: "")
					_ = scanner.scanUpToString("/totp/")
					if let _ = scanner.scanString("/totp/") {
						if let result = scanner.scanUpToString("?") {
							issuerDict.setObject(result, forKey: "Issuer" as NSCopying)
						}
					}
				}
			}
		}
		finished()
	}

	private func finished() {
		entriesArray.add(issuerDict)
		saveDefaults()
	}

	private func configureEncryptionType(forDict dict: NSMutableDictionary) {
		switch selectedRow {
			case 0: dict.setObject(kOTPGeneratorSHA1Algorithm, forKey: "encryptionType" as NSCopying)
			case 1: dict.setObject(kOTPGeneratorSHA256Algorithm, forKey: "encryptionType" as NSCopying)
			case 2: dict.setObject(kOTPGeneratorSHA512Algorithm, forKey: "encryptionType" as NSCopying)
			default: break
		}
	}

}
