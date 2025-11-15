import UIKit

/// Singleton manager to handle the creation, deletion & saving of issuers
final class IssuerManager: ObservableObject {
	static let sharedInstance = IssuerManager()

	private(set) var selectedIndex = 0
	private(set) var imagesDict = [String:UIImage]()

	@Published private(set) var issuers = [Issuer]()

	private init() {
		issuers = KeychainManager.sharedInstance.retrieveIssuers()
		setupImagesDict()
	}

	private func setupImagesDict() {
		let kIssuersPath = "/Applications/Azure.app/Issuers/"

		let imagesArray = try? Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Issuers") ??
			FileManager.default.contentsOfDirectory(atPath: kIssuersPath).compactMap { URL(string: $0) }

		for image in imagesArray ?? [] {
			guard let strippedName = image.lastPathComponent.components(separatedBy: ".").first else { return }
			imagesDict[strippedName.lowercased()] = UIImage(named: "Issuers/" + strippedName)!
		}
	}

	private func createIssuer(
		withName name: String,
		account: String,
		secret: Data,
		algorithm: Issuer.Algorithm,
		completion: (Bool, Issuer) -> ()
	) {
		var issuer: Issuer = .init(name: name, account: account, secret: secret, algorithm: algorithm)
		KeychainManager.sharedInstance.save(issuer: &issuer, forService: name, account: account)

		completion(KeychainManager.sharedInstance.isDuplicateItem, issuer)
	}
}

// ! Public

extension IssuerManager {
	/// Function to create an issuer from the given url
	/// - Parameters:
	///		- string: The ot pauth url `String`
	///		- completion: Non `@escaping` closure that takes a `Bool` & `Issuer` as argument & returns nothing,
	///		to check if the issuer being created already exists in the keychain or not
	func createIssuer(outOfOtPauthString string: String, completion: (Bool, Issuer) -> ()) {
		let urlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		guard let safeUrl = URL(string: urlString) else { return }

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

		let scanner = Scanner(string: string)
		guard scanner.scanUpToString("/totp/") != nil,
			scanner.scanString("/totp/") != nil,
			let account = scanner.scanUpToString("?") else { return }

		guard !name.isEmpty else {
			createIssuer(withName: account, account: account, secret: .base32DecodedString(secret), algorithm: algorithm, completion: completion)
			return
		}
		createIssuer(withName: name, account: account, secret: .base32DecodedString(secret), algorithm: algorithm, completion: completion)
	}

	/// Function to create an issuer with the data passed from the input fields
	/// - Parameters:
	///		- name: A `String` that represents the issuer's name
	///		- account: A `String` that represents the issuer's account
	///		- secret: The secret hash `Data`
	///		- completion: Non `@escaping` closure that takes a `Bool` & `Issuer` as argument & returns nothing,
	///		to check if the issuer being created already exists in the keychain or not
	func createIssuer(withName name: String, account: String, secret: Data, completion: (Bool, Issuer) -> ()) {
		var algorithm: Issuer.Algorithm = .sha1

		switch selectedIndex {
			case 0: algorithm = .sha1
			case 1: algorithm = .sha256
			case 2: algorithm = .sha512
			default: break
		}

		createIssuer(withName: name, account: account, secret: secret, algorithm: algorithm, completion: completion)

		selectedIndex = 0
	}

	/// Function to pass the selected segment index to configure the encryption algorithm
	/// - Paramater index: An `Int` that represents the index
	func setSelectedIndex(_ index: Int) {
		selectedIndex = index
	}

	/// Function to append an `Issuer` to the issuers array
	/// - Parameter issuer: The `Issuer` object
	func appendIssuer(_ issuer: Issuer) {
		issuers.append(issuer)
	}

	/// Function to insert an `Issuer` to the issuers array at a given index
	/// - Parameters:
	///		- issuer: The `Issuer` object
	///		- index: An `Int` that represents the index
	func insertIssuer(_ issuer: Issuer, at index: Int) {
		issuers.insert(issuer, at: index)		
	}

	/// Function to remove an `Issuer` from the issuers array
	/// - Parameter index: An `Int` that represents the index
	func removeIssuer(at index: Int) {
		issuers.remove(at: index)
	}

	/// Function to update an `Issuer` at the given index path
	/// - Parameters:
	///		- issuer: The `Issuer` object
	///		- indexPath: The `IndexPath`
	func updateIssuer(_ issuer: Issuer, at indexPath: IndexPath) {
		issuers[indexPath.item] = issuer
	}

	/// Function to set & save all `Issuer` objects to the keychain
	/// - Parameter issuers: An array of `Issuer` objects
	func setIssuers(_ issuers: [Issuer]) {
		self.issuers = issuers
		self.issuers.forEach {
			var issuer = $0
			KeychainManager.sharedInstance.save(issuer: &issuer, forService: issuer.name, account: issuer.account)
		}
	}

	/// Function to remove an `Issuer` at the given index path
	/// - Parameter indexPath: The `IndexPath`
	func removeIssuer(at indexPath: IndexPath) {
		var issuer = issuers[indexPath.item]
		issuers.remove(at: indexPath.item)
		KeychainManager.sharedInstance.deleteIssuer(forService: issuer.name, account: issuer.account)

		let slice = issuers[indexPath.item...]

		for (index, _issuer) in zip(slice.indices, slice) {
			issuer = _issuer
			issuer.index = index

			KeychainManager.sharedInstance.save(issuer: &issuer, forService: issuer.name, account: issuer.account)
		}
	}

	/// Function to remove all `Issuer` objects from the issuers array
	func removeAllIssuers() {
		issuers.removeAll()
		KeychainManager.sharedInstance.batchDeleteIssuers()
	}
}
