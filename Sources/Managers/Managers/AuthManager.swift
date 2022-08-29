import Foundation
import LocalAuthentication


@objc public class AuthManager: NSObject {
	override init() {
		super.init()
	}

	@objc public func setupAuth(withReason reason: String, reply: @escaping (Bool, Error?) -> ()) {
		LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason:reason, reply: reply)
	}

	@objc public func shouldUseBiometrics() -> Bool {
		var systemInfo = utsname()
		uname(&systemInfo)
		let deviceModel = String(cString: &systemInfo.machine.0)
		if(FileManager.default.fileExists(atPath: .kCheckra1n)
			&& deviceModel == "iPhone10,1"
			|| deviceModel == "iPhone10,4"
			|| deviceModel == "iPhone10,2"
			|| deviceModel == "iPhone10,5"
			|| deviceModel == "iPhone10,3"
			|| deviceModel == "iPhone10,6") { return false }

		return true
	}

}
