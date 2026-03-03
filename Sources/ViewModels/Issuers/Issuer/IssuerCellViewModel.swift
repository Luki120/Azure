import Foundation
import UIKit.UIImage

/// View model struct for `IssuerCell`
struct IssuerCellViewModel {
	var issuer: Issuer
	var name, account: String
	let secret: Data

	var image: UIImage?

	init(_ issuer: Issuer) {
		self.issuer = issuer
		self.name = issuer.name
		self.account = issuer.account
		self.secret = issuer.secret
	}

	private func getLastUNIXTimestamp() -> Double {
		let timestamp = Int(Date().timeIntervalSince1970)
		return Double(timestamp - timestamp % 30)
	}
}

// ! Public

extension IssuerCellViewModel {
	/// Function to generate a TOTP code
	///	- Returns: `String`
	func generateOTP() -> String {
		return issuer.generateOTP(forDate: .init(timeIntervalSince1970: getLastUNIXTimestamp()))
	}
}
