import Foundation


@objc public class BackupManager: NSObject {

	private let fileM = FileManager.default
	private var kDocumentsPathURL: URL!
	private var kAzureJailedPathURL: URL!

	override init() {
		super.init()
		kDocumentsPathURL = fileM.urls(for: .documentDirectory, in: .userDomainMask)[0]
		kAzureJailedPathURL = kDocumentsPathURL.appendingPathComponent("AzureBackup.json")
	}

	@objc public func isJailbroken() -> Bool {
		if(fileM.fileExists(atPath: .kCheckra1n)
			|| fileM.fileExists(atPath: .kTaurine)
			|| fileM.fileExists(atPath: .kUnc0ver)) { return true }

		return false
	}

	@objc public func makeDataOutOfJSON() {
		let kAzurePathURL = URL(fileURLWithPath: .kAzurePath)

		let data = try? Data(contentsOf: isJailbroken() ? kAzurePathURL: kAzureJailedPathURL)
		let jsonArray = try! JSONSerialization.jsonObject(with: data ?? Data(), options: .mutableContainers) as? NSMutableArray ?? []
		TOTPManager.sharedInstance.entriesArray = jsonArray
		TOTPManager.sharedInstance.saveDefaults()
	}

	@objc public func makeJSONOutOfData() {
		if isJailbroken() {
			if !fileM.fileExists(atPath: .kAzureDir) {
				try? fileM.createDirectory(atPath: .kAzureDir, withIntermediateDirectories: false, attributes: nil)
			}
			createFile(atPath: .kAzurePath)
		}
		else { createFile(atPath: kAzureJailedPathURL.absoluteString) }

 		let fileHandle = FileHandle(forWritingAtPath: isJailbroken() ? .kAzurePath : kAzureJailedPathURL.absoluteString)
		fileHandle?.seekToEndOfFile()

		let serializedData = try! JSONSerialization.data(withJSONObject: TOTPManager.sharedInstance.entriesArray ?? [])
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
