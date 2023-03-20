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
		if !fileM.fileExists(atPath: .kAzurePath) || !fileM.fileExists(atPath: kAzureJailedPathURL.path) { return }
		let kAzurePathURL = URL(fileURLWithPath: .kAzurePath)

		let data = try? Data(contentsOf: isJailbroken() ? kAzurePathURL : kAzureJailedPathURL)
		let jsonArray = try! JSONSerialization.jsonObject(with: data ?? Data(), options: .mutableContainers) as? [[String:String]] ?? []
		TOTPManager.sharedInstance.entriesArray = jsonArray
		TOTPManager.sharedInstance.saveDefaults()
	}

	func makeJSONOutOfData() {
		guard TOTPManager.sharedInstance.entriesArray.count > 0 else { return }
		if isJailbroken() {
			if !fileM.fileExists(atPath: .kAzureDir) {
				try? fileM.createDirectory(atPath: .kAzureDir, withIntermediateDirectories: false, attributes: nil)
			}
			createFile(atPath: .kAzurePath)
		}
		else { createFile(atPath: kAzureJailedPathURL.path) }

 		let fileHandle = FileHandle(forWritingAtPath: isJailbroken() ? .kAzurePath : kAzureJailedPathURL.path)
		fileHandle?.seekToEndOfFile()

		let serializedData = try! JSONSerialization.data(withJSONObject: TOTPManager.sharedInstance.entriesArray, options: .prettyPrinted)
		fileHandle?.write(serializedData)
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
