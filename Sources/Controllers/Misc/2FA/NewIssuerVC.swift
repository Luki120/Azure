import UIKit


protocol NewIssuerVCDelegate: AnyObject {
	func shouldDismissVC(in newIssuerVC: NewIssuerVC)
}

/// Controller that'll show the new issuer view
final class NewIssuerVC: UIViewController {

	private let newIssuerView = NewIssuerView()

	weak var delegate: NewIssuerVCDelegate?

	// ! Lifecycle

	override func loadView() { view = newIssuerView }

	override func viewDidLoad() {
		super.viewDidLoad()
		newIssuerView.delegate = self
		newIssuerView.backgroundColor = .systemBackground
	}

}

// ! NewIssuerViewDelegate

extension NewIssuerVC: NewIssuerViewDelegate {

	func shouldDismissVC(in newIssuerView: NewIssuerView) {
		delegate?.shouldDismissVC(in: self)
	}

}
