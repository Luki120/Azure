import CryptoKit
import Foundation

/// Class to generate TOTP codes
final class TOTPGenerator {

	private let secret: Data

	/// Designated initializer
	/// - Parameters:
	///     - secret: the secret hash data from which to generate the TOTP code
	init(secret: Data) {
		self.secret = secret
	}

	// ! Private

	private func generateOTP(forCounter counter: UInt64) -> String {
		let counterBytes = (0..<8).reversed().map { UInt8(counter >> (8 * $0) & 0xff) }
		let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: SymmetricKey(data: secret))
		let offset = Int(hash.suffix(1)[0] & 0x0f)
		let hash32 = hash
			.dropFirst(offset)
			.prefix(4)
			.reduce(0, { ($0 << 8) | UInt32($1) })
		let hash31 = hash32 & 0x7FFF_FFFF
		let pad = String(repeating: "0", count: 6)

		return String((pad + String(hash31)).suffix(6))
	}

}

extension TOTPGenerator {

	// ! Public

	/// Function to generate a TOTP code for the given date
	/// - Parameters:
	///     - forDate: the given date	
	/// - Returns: A string
	func generateOTP(forDate date: Date) -> String {
		let counter = UInt64(date.timeIntervalSince1970 / TimeInterval(30))
		return generateOTP(forCounter: counter)
	}

}
