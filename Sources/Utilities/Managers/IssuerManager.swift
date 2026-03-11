import UIKit

/// Singleton manager to handle the creation, deletion & saving of issuers
@MainActor
final class IssuerManager: ObservableObject {
	static let sharedInstance = IssuerManager()

	private(set) var selectedIndex = 0
	private(set) var imagesDict = [String:UIImage]()

	@Published private(set) var issuers = [Issuer]()

	private init() {
		issuers = KeychainActor.sharedInstance.retrieveIssuers()
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
		name: String,
		account: String,
		secret: Data,
		algorithm: Issuer.Algorithm
	) async -> (Bool, Issuer) {
		var issuer: Issuer = .init(name: name, account: account, secret: secret, algorithm: algorithm)
		await KeychainActor.sharedInstance.save(issuer: &issuer, service: name, account: account)

		return (await KeychainActor.sharedInstance.isDuplicateItem, issuer)
	}
}

// ! Public

extension IssuerManager {
	/// Async function to create an `Issuer` from a given url
	/// - Parameter otPauthString: The ot pauth url `String`
	/// - Returns: `(Bool, Issuer)?`
	func createIssuer(otPauthString: String) async -> (Bool, Issuer)? {
		let urlString = otPauthString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		guard let safeUrl = URL(string: urlString) else { return nil }

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

		let scanner = Scanner(string: otPauthString)
		guard scanner.scanUpToString("/totp/") != nil, scanner.scanString("/totp/") != nil,
			let account = scanner.scanUpToString("?") else { return nil }

		guard !name.isEmpty else {
			return await createIssuer(name: account, account: account, secret: .base32DecodedString(secret), algorithm: algorithm)
		}

		return await createIssuer(name: name, account: account, secret: .base32DecodedString(secret), algorithm: algorithm)
	}

	/// Async function to create an `Issuer`
	/// - Parameters:
	///		- name: A `String` that represents the issuer's name
	///		- account: A `String` that represents the issuer's account
	///		- secret: The secret hash `Data`
	/// - Returns: (Bool, Issuer)
	func createIssuer(name: String, account: String, secret: Data) async -> (Bool, Issuer) {
		var algorithm: Issuer.Algorithm = .sha1

		switch selectedIndex {
			case 0: algorithm = .sha1
			case 1: algorithm = .sha256
			case 2: algorithm = .sha512
			default: break
		}

		let result = await createIssuer(name: name, account: account, secret: secret, algorithm: algorithm)
		selectedIndex = 0

		return result
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

	/// Function to update an `Issuer` at the given index path
	/// - Parameters:
	///		- issuer: The `Issuer` object
	///		- indexPath: The `IndexPath`
	func updateIssuer(_ issuer: Issuer, at indexPath: IndexPath) {
		issuers[indexPath.item] = issuer
	}

	/// Function to remove an `Issuer` at the given index
	/// - Parameters:
	///		- at: An `Int` that represents the index
	///		- saveToKeychain: A `Bool` that indicates if the `Issuer` should be saved, defaults to `false`
	func removeIssuer(at index: Int, saveToKeychain: Bool = false) {
		let issuer = issuers.remove(at: index)
		guard saveToKeychain else { return }

		Task {
			await KeychainActor.sharedInstance.deleteIssuer(service: issuer.name, account: issuer.account)
			await reindexIssuers(startingAt: index)
		}
	}

	/// Function to set & save all `Issuer` objects to the keychain
	/// - Parameter issuers: An array of `Issuer` objects
	func setIssuers(_ issuers: [Issuer]) {
		self.issuers = issuers
		self.issuers.forEach {
			var issuer = $0

			Task {
				await KeychainActor.sharedInstance.save(issuer: &issuer, service: issuer.name, account: issuer.account)
			}
		}
	}

	/// Async function to reindex `Issuer` objects & save them to the keychain
	/// - Parameter startingAt: An `Int` that represents the starting index
	func reindexIssuers(startingAt startIndex: Int) async {
		guard startIndex < issuers.count else { return }

		for index in startIndex..<issuers.count {
			var issuer = issuers[index]
			issuer.index = index

			await KeychainActor.sharedInstance.save(issuer: &issuer, service: issuer.name, account: issuer.account)
			issuers[index] = issuer
		}
	}

	/// Function to remove all `Issuer` objects from the issuers array
	func removeAllIssuers() {
		issuers.removeAll()

		Task {
			await KeychainActor.sharedInstance.batchDeleteIssuers()
		}
	}
}
