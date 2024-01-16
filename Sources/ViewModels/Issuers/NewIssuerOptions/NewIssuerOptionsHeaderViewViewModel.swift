import Foundation

/// View model struct for NewIssuerOptionsHeaderView
struct NewIssuerOptionsHeaderViewViewModel {

	private(set) var height: Double = 120
	private(set) var title = "Add issuer"
	private(set) var subtitle = "Add an issuer by scanning a QR code, importing a QR image or entering the secret manually."
	private(set) var prepareForReuse = false

}
