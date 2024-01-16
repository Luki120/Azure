import Foundation

/// Manager to handle importing & exporting backups
final class BackupManager {

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
	func decodeData() {
		if !fileM.fileExists(atPath: .kAzurePath) && !fileM.fileExists(atPath: kAzureJailedPathURL.path) { return }
		let kAzurePathURL = URL(fileURLWithPath: .kAzurePath)

		guard let data = try? Data(contentsOf: isJailbroken() ? kAzurePathURL : kAzureJailedPathURL),
			let issuers = try? JSONDecoder().decode([Issuer].self, from: data) else { return }

		IssuerManager.sharedInstance.setIssuers(issuers)
	}

	/// Function to encode the data & export it
	func encodeData() {
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

		fileHandle?.write(encodedData)
		fileHandle?.closeFile()
	}

}
