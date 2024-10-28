import UIKit


protocol NewIssuerViewDelegate: AnyObject {
	func shouldDismissVC(in newIssuerView: NewIssuerView)
}

/// Class to represent the new issuer view
final class NewIssuerView: UIView {

	private let toastView = ToastView()
	private let viewModel = NewIssuerViewViewModel()

	private let newIssuerTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.isScrollEnabled = false
		tableView.register(NewIssuerFormCell.self, forCellReuseIdentifier: NewIssuerFormCell.identifier)
		tableView.register(NewIssuerAlgorithmCell.self, forCellReuseIdentifier: NewIssuerAlgorithmCell.identifier)
		return tableView
	}()

	weak var delegate: NewIssuerViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubviews(newIssuerTableView, toastView)
		pinViewToAllEdges(newIssuerTableView)
		pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)

		newIssuerTableView.delegate = viewModel

		viewModel.delegate = self
		viewModel.setupTableView(newIssuerTableView)
	}

}

// ! NewIssuerViewViewModelDelegate

extension NewIssuerView: NewIssuerViewViewModelDelegate {

	func didFadeInOutToastView(isDuplicateItem: Bool) {
		if isDuplicateItem {
			toastView.fadeInOutToastView(withMessage: "Item already exists.", finalDelay: 1.5)
		}
		else {
			toastView.fadeInOutToastView(withMessage: "Fill out all forms.", finalDelay: 1.5)
		}
	}

	func shouldDismissVC() {
		delegate?.shouldDismissVC(in: self)
	}

}
