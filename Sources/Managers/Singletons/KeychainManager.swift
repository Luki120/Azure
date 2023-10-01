import Foundation

/// Keychain singleton manager to handle saving, retrieving and deleting issuers from the keychain
final class KeychainManager {

	static let sharedInstance = KeychainManager()
	private init() {}

	private var status: OSStatus?

	var isDuplicateItem: Bool { return status == errSecDuplicateItem }

	/// Function to encode & save a single issuer to the keychain, or update it if it already exists
	/// Parameters:
	///		- issuer: The issuer object
	///		- forService: A string representing the service for the given issuer
	func save(issuer: Issuer, forService service: String) {
		guard let encodedIssuer = try? JSONEncoder().encode(issuer) else { return }

		let query: [CFString : Any] = [
			kSecValueData: encodedIssuer,
			kSecAttrService: service,
			kSecClass: kSecClassGenericPassword
		]

		status = SecItemAdd(query as CFDictionary, nil)

		guard !isDuplicateItem else {
			let query: [CFString : Any] = [
				kSecAttrService: service,
				kSecClass: kSecClassGenericPassword,
			]

			let attributes = [kSecValueData: encodedIssuer] as CFDictionary

			SecItemUpdate(query as CFDictionary, attributes)
			return
		}
	}

	/// Function to decode & retrieve an array of issuers form the keychain
	/// - Returns: An array of issuers
	func retrieveIssuers() -> [Issuer] {
		let query: [CFString : Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecMatchLimit: kSecMatchLimitAll,
			kSecReturnData: true,
		]

		var result: AnyObject?
		SecItemCopyMatching(query as CFDictionary, &result)

		guard let results = result as? [Data] else { return [] }

		let decoder = JSONDecoder()
		return results
			.compactMap { try? decoder.decode(Issuer.self, from: $0) }
			.sorted { $0.index < $1.index }
	}

	/// Function to delete a single issuer from the keychain
	/// Parameters:
	///		- forService: A string representing the service for the given issuer
	func deleteIssuer(forService service: String) {
		let query: [CFString : Any] = [
			kSecAttrService: service,
			kSecClass: kSecClassGenericPassword,
		]

		SecItemDelete(query as CFDictionary)
	}

	/// Function to delete all issuers from the keychain
	func batchDeleteIssuers() {
		for itemClass in [kSecClassGenericPassword] {
			SecItemDelete([kSecClass: itemClass] as CFDictionary)
		}
	}

}
