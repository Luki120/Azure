import CryptoKit
import Foundation

/// Struct to represent an issuer for the TOTP code
struct Issuer: Codable {

	let name: String
	let account: String
	let secret: Data
	let algorithm: Algorithm

	var index = 0

	/// Enum to represent the encryption algorithm
	enum Algorithm: String, Codable {
		case sha1
		case sha256
		case sha512

		fileprivate var hashFunction: any HashFunction.Type {
			switch self {
				case .sha1: return Insecure.SHA1.self
				case .sha256: return SHA256.self
				case .sha512: return SHA512.self
			}
		}
	}

	// credits for figuring out this Swift fuckery, i.e how not to hardcode the algorithm ⇝ Kabir & Leptos
	private func hashFor<H: HashFunction>(_ hashFunction: H.Type, counter: UInt64) -> String {
		let counterBytes = (0..<MemoryLayout<UInt64>.size)
			.reversed()
			.map { UInt8(truncatingIfNeeded: counter >> (UInt8.bitWidth * $0)) }
		let hash = HMAC<H>.authenticationCode(for: counterBytes, using: SymmetricKey(data: secret))
		let offset = Int(hash.suffix(1)[0] & 0x0f)
		let hash32 = hash
			.dropFirst(offset)
			.prefix(4)
			.reduce(0, { ($0 << 8) | UInt32($1) })
		let hash31 = hash32 & 0x7FFF_FFFF
		let pad = String(repeating: "0", count: 6)

		return String((pad + String(hash31)).suffix(6))
	}

	private func generateOTP(forCounter counter: UInt64) -> String {
		hashFor(algorithm.hashFunction, counter: counter)
	}

}

extension Issuer {

	// ! Public

	/// Function to generate a TOTP code for the given date
	/// - Parameters:
	///		- forDate: The given date
	///	- Returns: A string
	func generateOTP(forDate date: Date) -> String {
		let counter = UInt64(date.timeIntervalSince1970 / TimeInterval(30))
		return generateOTP(forCounter: counter)
	}

}
