import CommonCrypto
import CryptoKit
import Foundation

/// Manager to handle importing & exporting backups
final class BackupManager {

	let loadBackupMessage = "Please enter your password in order to continue." 
	let makeBackupMessage = "Please input a password equal or greater than 8 characters in order to continue, make sure to remember it otherwise you won't be able to restore encrypted backups."

	private let fileM = FileManager.default
	private var kAzureJailedPathURL: URL!

	init() {
		let kDocumentsPathURL = fileM.urls(for: .documentDirectory, in: .userDomainMask)[0]
		kAzureJailedPathURL = kDocumentsPathURL.appendingPathComponent("AzureBackup.json")
	}

	private func createFile(atPath path: String) {
		if !fileM.fileExists(atPath: path) { fileM.createFile(atPath: path, contents: nil) }
		else {
			try? fileM.removeItem(atPath: path)
			fileM.createFile(atPath: path, contents: nil)
		}
	}

}

extension BackupManager {

	// ! Public

	/// Function to decode the data from a backup & import it
	/// - Parameters:
	/// 	- withPassword: A string that represents the password needed for decrpyting the data
	/// 	- isEncrypted: A bool to check wether the data is encrypted or not
	func decodeData(withPassword password: String = "", isEncrypted: Bool = false) {
		if !fileM.fileExists(atPath: .kAzurePath) && !fileM.fileExists(atPath: kAzureJailedPathURL.path) { return }
		let kAzurePathURL = URL(fileURLWithPath: .kAzurePath)

		guard let data = try? Data(contentsOf: isJailbroken() ? kAzurePathURL : kAzureJailedPathURL) else { return }

		if isEncrypted {
			guard let decryptedData = try? decryptData(data, password: password),
				let issuers = try? JSONDecoder().decode([Issuer].self, from: decryptedData) else { return }

			IssuerManager.sharedInstance.setIssuers(issuers)
		}
		else {
			guard let issuers = try? JSONDecoder().decode([Issuer].self, from: data) else { return }
			IssuerManager.sharedInstance.setIssuers(issuers)
		}
	}

	/// Function to encode the data & export it
	/// - Parameters:
	/// 	- withPassword: A string that represents the password needed for encrypting the data
	/// 	- encrypt: A bool to check wether the data should be encrypted or not
	func encodeData(withPassword password: String = "", encrypt: Bool = false) {
		guard IssuerManager.sharedInstance.issuers.count > 0 else { return }
		if isJailbroken() {
			if !fileM.fileExists(atPath: .kAzureDir) {
				try? fileM.createDirectory(atPath: .kAzureDir, withIntermediateDirectories: false, attributes: nil)
			}
			createFile(atPath: .kAzurePath)
		}
		else { createFile(atPath: kAzureJailedPathURL.path) }

		let fileHandle = FileHandle(forWritingAtPath: isJailbroken() ? .kAzurePath : kAzureJailedPathURL.path)
		fileHandle?.seekToEndOfFile()

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		guard let encodedData = try? encoder.encode(IssuerManager.sharedInstance.issuers) else { return }

		if encrypt {
			guard let encryptedData = try? encryptData(encodedData, password: password) else { return }
			fileHandle?.write(encryptedData)
		}
		else {
			fileHandle?.write(encodedData)
		}

		fileHandle?.closeFile()
	}

}

extension BackupManager {

	private func encryptData(_ data: Data, password: String) throws -> Data {
		let salt = Data(SHA256.hash(data: password.data(using: .utf8)!))

		let key = SymmetricKey(data: derivedPBKDF2Key(from: password, salt: salt, keySize: .bits256))
		return try AES.GCM.seal(data, using: key).combined!
	}

	private func decryptData(_ data: Data, password: String) throws -> Data {
		let salt = Data(SHA256.hash(data: password.data(using: .utf8)!))

		let key = SymmetricKey(data: derivedPBKDF2Key(from: password, salt: salt, keySize: .bits256))
		let sealedBox = try AES.GCM.SealedBox(combined: data)
		return try AES.GCM.open(sealedBox, using: key)
	}

	private func derivedPBKDF2Key(from password: String, salt saltData: Data, keySize: SymmetricKeySize) -> Data {
		let derivedKeyByteLength = keySize.bitCount / 8
		var derivedKeyData = Data(repeating: 0, count: derivedKeyByteLength)

		let derivationStatus: Int32 = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
			saltData.withUnsafeBytes { saltBytes in
				let keyBuffer: UnsafeMutablePointer<UInt8> = derivedKeyBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
				let saltBuffer: UnsafePointer<UInt8> = saltBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
				return CCKeyDerivationPBKDF(
					CCPBKDFAlgorithm(kCCPBKDF2),
					password,
					Data(password.utf8).count,
					saltBuffer,
					saltData.count,
					CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
					UInt32(600_000),
					keyBuffer,
					derivedKeyByteLength
				)
			}
		}

		guard derivationStatus == kCCSuccess else { return Data() }
		return derivedKeyData
	}

}
