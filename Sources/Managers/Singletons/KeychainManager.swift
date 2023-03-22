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

		let query = [
			kSecValueData: encodedIssuer,
			kSecAttrService: service,
			kSecClass: kSecClassGenericPassword
		] as CFDictionary

		status = SecItemAdd(query, nil)

		guard !isDuplicateItem else {
			let query = [
				kSecAttrService: service,
				kSecClass: kSecClassGenericPassword,
			] as CFDictionary

			let attributes = [kSecValueData: encodedIssuer] as CFDictionary

			SecItemUpdate(query, attributes)
			return
		}
	}

	/// Function to decode & retrieve an array of issuers form the keychain
	/// - Returns: An array of issuers
	func retrieveIssuers() -> [Issuer] {
		let query = [
			kSecClass: kSecClassGenericPassword,
			kSecMatchLimit: kSecMatchLimitAll,
			kSecReturnData: true,
		] as CFDictionary

		var result: AnyObject?
		SecItemCopyMatching(query, &result)

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
		let query = [
			kSecAttrService: service,
			kSecClass: kSecClassGenericPassword,
		] as CFDictionary

		SecItemDelete(query)
	}

	/// Function to delete all issuers from the keychain
	func batchDeleteIssuers() {
		for itemClass in [kSecClassGenericPassword] {
			SecItemDelete([kSecClass: itemClass] as CFDictionary)
		}
	}

}
