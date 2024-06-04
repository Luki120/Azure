import Foundation

/// Keychain singleton manager to handle saving, retrieving and deleting issuers from the keychain
final class KeychainManager {

	static let sharedInstance = KeychainManager()
	private init() {}

	private var status: OSStatus?

	var isDuplicateItem: Bool { return status == errSecDuplicateItem }

	/// Function to encode & save a single issuer to the keychain
	/// Parameters:
	///		- issuer: The issuer object
	///		- forService: A string representing the service for the given issuer
	///		- account: A string representing the account for the given issuer
	func save(issuer: inout Issuer, forService service: String, account: String) {
		guard let encodedIssuer = try? JSONEncoder().encode(issuer) else { return }

		let query: [NSString : Any] = [
			kSecAttrService: service,
			kSecAttrAccount: account,
			kSecClass: kSecClassGenericPassword
		]

		var attributes: [NSString : Any] = [
			kSecValueData: encodedIssuer,
			kSecAttrService: issuer.name,
			kSecAttrAccount: issuer.account
		]

		if issuer.creationDate != nil {
			status = SecItemUpdate(query as NSDictionary, attributes as NSDictionary)
			guard status == errSecItemNotFound else { return }
		}

		attributes[kSecReturnAttributes] = true
		attributes[kSecClass] = kSecClassGenericPassword

		var result: AnyObject?
		status = SecItemAdd(attributes as NSDictionary, &result)

		let resultAttributes = result as? [NSString : Any] ?? [:]
		issuer.creationDate = resultAttributes[kSecAttrCreationDate] as? Date
	}

	/// Function to decode & retrieve an array of issuers form the keychain
	/// - Returns: An array of issuers
	func retrieveIssuers() -> [Issuer] {
		let query: [NSString : Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecMatchLimit: kSecMatchLimitAll,
			kSecReturnAttributes: true,
			kSecReturnData: true
		]

		var result: AnyObject?
		SecItemCopyMatching(query as NSDictionary, &result)

		guard let results = result as? [[NSString : Any]] else { return [] }

		let decoder = JSONDecoder()
		return results
			.compactMap {
				var issuer = try? decoder.decode(Issuer.self, from: $0[kSecValueData] as? Data ?? Data())
				issuer?.creationDate = $0[kSecAttrCreationDate] as? Date
				return issuer
			}
			.sorted { $0.index < $1.index }
	}

	/// Function to delete a specific issuer from the keychain
	/// Parameters:
	///		- forService: A string representing the service for the given issuer
	///		- account: A string representing the account for the given issuer	
	func deleteIssuer(forService service: String, account: String) {
		let query: [NSString : Any] = [
			kSecAttrService: service,
			kSecAttrAccount: account,
			kSecClass: kSecClassGenericPassword
		]

		SecItemDelete(query as NSDictionary)
	}

	/// Function to delete all issuers from the keychain
	func batchDeleteIssuers() {
		[kSecClassGenericPassword].forEach { SecItemDelete([kSecClass: $0] as NSDictionary) }
	}

}
