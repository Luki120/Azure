import UIKit

/// View model struct for NewIssuerAlgorithmCell
struct NewIssuerAlgorithmCellViewModel: Hashable {

	let algorithmText: String
	let items: [String]
	var selectedSegmentIndex = 0

}
