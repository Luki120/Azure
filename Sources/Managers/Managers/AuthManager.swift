import Foundation
import LocalAuthentication


final class AuthManager {

	enum Reason {
		case sensitiveOperation, unlockApp

		var reason: String {
			switch self {
				case .sensitiveOperation: return "Azure needs you to authenticate for a sensitive operation."
				case .unlockApp: return "Azure needs you to authenticate in order to access the app."
			}
		}
	}

	func setupAuth(withReason reason: Reason, reply: @escaping (Bool, Error?) -> ()) {
		LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason.reason, reply: reply)
	}

	func shouldUseBiometrics() -> Bool {
		var systemInfo = utsname()
		uname(&systemInfo)
		let deviceModel = String(cString: &systemInfo.machine.0)
		if FileManager.default.fileExists(atPath: .kCheckra1n)
			&& deviceModel == "iPhone10,1"
			|| deviceModel == "iPhone10,4"
			|| deviceModel == "iPhone10,2"
			|| deviceModel == "iPhone10,5"
			|| deviceModel == "iPhone10,3"
			|| deviceModel == "iPhone10,6" { return false }

		return true
	}

}
