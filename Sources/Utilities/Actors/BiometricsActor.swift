import Foundation
import LocalAuthentication

/// Actor to handle authentication
final actor BiometricsActor {
	static let sharedInstance = BiometricsActor()
	private init() {}

	/// Enum representing a reason for authentication
	enum Reason {
		case sensitiveOperation, unlockApp

		var description: String {
			switch self {
				case .sensitiveOperation: return "Azure needs you to authenticate for a sensitive operation."
				case .unlockApp: return "Azure needs you to authenticate in order to access the app."
			}
		}
	}

	/// Async function to setup authentication
	/// - Parameter reason: The `Reason` for requesting authentication
	/// - Throws: `LAError`
	/// - Returns: `Bool`
	func setupAuth(reason: Reason) async throws -> Bool {
		return try await LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason.description)
	}

	/// Function to verify wether authentication should be requested or not
	/// - Returns: `Bool`
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
