import Foundation
import LocalAuthentication

/// Manager to handle authentication
final class AuthManager {

	/// Enum representing a reason of why authentication is being requested
	enum Reason {
		case sensitiveOperation, unlockApp

		var reason: String {
			switch self {
				case .sensitiveOperation: return "Azure needs you to authenticate for a sensitive operation."
				case .unlockApp: return "Azure needs you to authenticate in order to access the app."
			}
		}
	}

	/// Function to setup the authentication
	/// - Parameters:
	///		- withReason: The reason for requesting authentication
	///		- reply: Escaping closure taking a Bool & an optional Error as arguments which returns nothing
	func setupAuth(withReason reason: Reason, reply: @escaping (Bool, Error?) -> ()) {
		LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason.reason, reply: reply)
	}

	/// Function to verify wether authentication should be requested or not
	/// - Returns: A bool value
	func shouldUseBiometrics() -> Bool {
		var systemInfo = utsname()
		uname(&systemInfo)

		let deviceModel = withUnsafePointer(to: &systemInfo.machine.0) { String(cString: $0) }

		if FileManager.default.fileExists(atPath: "/var/checkra1n.dmg")
			&& deviceModel == "iPhone10,1"
			|| deviceModel == "iPhone10,4"
			|| deviceModel == "iPhone10,2"
			|| deviceModel == "iPhone10,5"
			|| deviceModel == "iPhone10,3"
			|| deviceModel == "iPhone10,6" { return false }

		return true
	}

}
