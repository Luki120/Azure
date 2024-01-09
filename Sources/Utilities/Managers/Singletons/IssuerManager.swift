import UIKit

/// Singleton manager to handle the creation, deletion & saving of issuers
final class IssuerManager: ObservableObject {

	private let kIssuersPath = "/Applications/Azure.app/Issuers/"

	static let sharedInstance = IssuerManager()

	private(set) var selectedRow = 0
	private(set) var imagesDict = [String:UIImage]()

	@Published private(set) var issuers = [Issuer]()

	private init() {
		selectedRow = UserDefaults.standard.integer(forKey: "selectedRow")

		issuers = KeychainManager.sharedInstance.retrieveIssuers()
		setupImagesDict()
	}

	private func setupImagesDict() {
		let imagesArray = try? Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Issuers") ??
			FileManager.default.contentsOfDirectory(atPath: kIssuersPath).compactMap { URL(string: $0) }

		for image in imagesArray ?? [] {
			let strippedName = image.lastPathComponent.components(separatedBy: ".").first!
			imagesDict.updateValue(UIImage(named: "Issuers/" + strippedName)!, forKey: strippedName.lowercased())
		}
	}

	private func createIssuer(
		withName name: String,
		account: String = "",
		secret: Data,
		algorithm: Issuer.Algorithm,
		completion: (Bool, Issuer) -> ()
	) {
		let issuer: Issuer = .init(name: name, account: account, secret: secret, algorithm: algorithm)
		KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)

		completion(KeychainManager.sharedInstance.isDuplicateItem, issuer)
	}

}

extension IssuerManager {

	// ! Public

	/// Function to create an issuer from the given url
	/// - Parameters:
	///		- outOfOtPauthString: The ot pauth url string
	///		- completion: Non escaping closure that takes a Bool & Issuer as argument & returns nothing,
	///		used to check if the issuer being created already exists in the keychain or not
	func createIssuer(outOfOtPauthString string: String, completion: (Bool, Issuer) -> ()) {
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

			createIssuer(withName: scannedName, secret: .base32DecodedString(secret), algorithm: algorithm, completion: completion)
			return
		}
		createIssuer(withName: name, secret: .base32DecodedString(secret), algorithm: algorithm, completion: completion)
	}

	/// Function to pass an index path's row to configure the encryption algorithm
	/// - Paramaters:
	///     - row: The given row
	func feedSelectedRow(withRow row: Int) {
		selectedRow = row
		UserDefaults.standard.set(selectedRow, forKey: "selectedRow")
	}

	/// Function to create an issuer with the data passed from the input fields
	/// - Parameters:
	///		- withName: A string to represent the issuer's name
	///		- account: A string to represent the issuer's account
	///		- secret: The secret hash data
	///		- completion: Non escaping closure that takes a Bool & Issuer as argument & returns nothing,
	///		used to check if the issuer being created already exists in the keychain or not
	func feedIssuer(withName name: String, account: String, secret: Data, completion: (Bool, Issuer) -> ()) {
		var algorithm: Issuer.Algorithm = .sha1

		switch selectedRow {
			case 0: algorithm = .sha1
			case 1: algorithm = .sha256
			case 2: algorithm = .sha512
			default: break
		}

		createIssuer(withName: name, account: account, secret: secret, algorithm: algorithm, completion: completion)
	}

	/// Function to append an issuer to the issuers array
	/// - Parameters:
	///		- issuer: The issuer
	func appendIssuer(_ issuer: Issuer) {
		issuers.append(issuer)
	}

	/// Function to set & save all issuers to the keychain
	/// - Parameters:
	///		- issuers: The issuers array
	func setIssuers(_ issuers: [Issuer]) {
		self.issuers = issuers
		self.issuers.forEach {
			KeychainManager.sharedInstance.save(issuer: $0, forService: $0.name)
		}
	}

	/// Function to remove an issuer from the issuers array
	/// - Parameters:
	///		- at: The given index path
	func removeIssuer(at indexPath: IndexPath) {
		var issuer = issuers[indexPath.item]
		issuers.remove(at: indexPath.item)
		KeychainManager.sharedInstance.deleteIssuer(forService: issuer.name)

		let slice = issuers[indexPath.item...]

		for (index, _issuer) in zip(slice.indices, slice) {
			issuer = _issuer
			issuer.index = index

			KeychainManager.sharedInstance.save(issuer: issuer, forService: issuer.name)
		}
	}

	/// Function to remove all issuers from the issuers array
	func removeAllIssuers() {
		issuers.removeAll()
		KeychainManager.sharedInstance.batchDeleteIssuers()
	}

}
