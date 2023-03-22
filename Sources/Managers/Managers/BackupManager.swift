import Foundation


final class BackupManager {

	private let fileM = FileManager.default
	private var kDocumentsPathURL: URL!
	private var kAzureJailedPathURL: URL!

	init() {
		kDocumentsPathURL = fileM.urls(for: .documentDirectory, in: .userDomainMask)[0]
		kAzureJailedPathURL = kDocumentsPathURL.appendingPathComponent("AzureBackup.json")
	}

	func makeDataOutOfJSON() {
		if !fileM.fileExists(atPath: .kAzurePath) && !fileM.fileExists(atPath: kAzureJailedPathURL.path) { return }
		let kAzurePathURL = URL(fileURLWithPath: .kAzurePath)

		guard let data = try? Data(contentsOf: isJailbroken() ? kAzurePathURL : kAzureJailedPathURL) else { return }
		let issuers = try! JSONDecoder().decode([Issuer].self, from: data)

		TOTPManager.sharedInstance.issuers = issuers
		TOTPManager.sharedInstance.saveIssuers()
	}

	func makeJSONOutOfData() {
		guard TOTPManager.sharedInstance.issuers.count > 0 else { return }
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
		guard let encodedData = try? encoder.encode(TOTPManager.sharedInstance.issuers) else { return }

		fileHandle?.write(encodedData)
		fileHandle?.closeFile()
	}

	private func createFile(atPath path: String) {
		if !fileM.fileExists(atPath: path) { fileM.createFile(atPath: path, contents: nil) }
		else {
			try? fileM.removeItem(atPath: path)
			fileM.createFile(atPath: path, contents: nil)
		}
	}
}
