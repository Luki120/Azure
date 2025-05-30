import UIKit


protocol IssuersViewDelegate: AnyObject {
	func didTapCopyPinCode(in issuersView: IssuersView)
	func didTapCopySecret(in issuersView: IssuersView)
	func issuersView(_ issuersView: IssuersView, didTapDeleteAndPresent alertController: UIAlertController)
	func issuersView(_ issuersView: IssuersView, didTapAddToSystemAndOpen url: URL)
	func issuersView(_ issuersView: IssuersView, didPresent alertController: UIAlertController)
}

/// Class to represent the issuers view
final class IssuersView: UIView {

	let toastView = ToastView()
	private let floatingButtonView = FloatingButtonView()

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		group.edgeSpacing = .init(leading: nil, top: .fixed(10), trailing: nil, bottom: .fixed(10))

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
		return UICollectionViewCompositionalLayout(section: section)
	}()

	private lazy var issuersCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.dragInteractionEnabled = true
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(IssuerCell.self, forCellWithReuseIdentifier: IssuerCell.identifier)
		return collectionView
	}()

	private lazy var noIssuersLabel = UILabel()
	private lazy var noResultsLabel = UILabel()

	private var viewModel: IssuersViewViewModel!

	weak var delegate: IssuersViewDelegate?

	var reloadData: Void {
		return issuersCollectionView.reloadData()
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/// Designated initializer
	/// - Parameters:
	///		- floatingButtonViewDelegate: The object that will conform to the floating button view delegate
	init(floatingButtonViewDelegate: FloatingButtonViewDelegate) {
		super.init(frame: .zero)
		setupViews()
		setupDataSource()

		floatingButtonView.delegate = floatingButtonViewDelegate
	}

	// ! Private

	private func setupViews() {
		noIssuersLabel = createLabel(withText: "No issuers were added yet. Tap the + button in order to add one.")
		noResultsLabel = createLabel(withText: "No results were found for this query.", initialAlpha: 0)

		addSubviews(issuersCollectionView, floatingButtonView, toastView, noIssuersLabel, noResultsLabel)

		layoutViews()
	}

	private func setupDataSource() {
		viewModel = IssuersViewViewModel(collectionView: issuersCollectionView)
		viewModel.delegate = self

		issuersCollectionView.dataSource = viewModel
		issuersCollectionView.delegate = viewModel
		issuersCollectionView.dragDelegate = viewModel
		issuersCollectionView.dropDelegate = viewModel
	}

	private func layoutViews() {
		pinViewToAllEdgesIncludingSafeAreas(issuersCollectionView)
		pinToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)

		let guide = safeAreaLayoutGuide

		floatingButtonView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -25).isActive = true
		floatingButtonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
		setupSizeConstraints(forView: floatingButtonView, width: 60, height: 60)

		[noIssuersLabel, noResultsLabel].forEach {
			centerViewOnBothAxes($0)
			setupHorizontalConstraints(forView: $0, leadingConstant: 10, trailingConstant: -10)
		}
	}

	private func animateNoIssuersLabel() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
			if IssuerManager.sharedInstance.issuers.count == 0 {
				self.issuersCollectionView.alpha = 0
				self.noIssuersLabel.alpha = 1
				self.noIssuersLabel.transform = .init(scaleX: 1, y: 1)
			}
			else {
				self.issuersCollectionView.alpha = 1
				self.noIssuersLabel.alpha = 0
				self.noIssuersLabel.transform = .init(scaleX: 0.1, y: 0.1)
			}
		}
	}

	private func animateNoSearchResultsLabel(forViewModels viewModels: [IssuerCellViewModel], isFiltering: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if viewModels.count == 0 && IssuerManager.sharedInstance.issuers.count > 0 && isFiltering {
				self.noResultsLabel.alpha = 1
			}
			else {
				self.noResultsLabel.alpha = 0
			}
		}
	}

	// ! Reusable

	private func createLabel(withText text: String, initialAlpha alpha: CGFloat = 1) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.text = text
		label.alpha = alpha
		label.textColor = .placeholderText
		label.numberOfLines = 0
		label.textAlignment = .center
		addSubview(label)
		return label
	}

}

extension IssuersView {

	// ! Public

	/// Function to setup the search controller for the issuers view controller
	/// - Parameters:
	///		- for: The issuers view controller
	func setupSearchController(for issuersVC: IssuersVC) {
		let searchController = UISearchController()
		searchController.searchResultsUpdater = viewModel
		searchController.obscuresBackgroundDuringPresentation = false

		issuersVC.navigationItem.searchController = searchController
	}

}

// ! IssuersViewViewModelDelegate

extension IssuersView: IssuersViewViewModelDelegate {

	func didTapCopyPinCode() {
		delegate?.didTapCopyPinCode(in: self)
	}

	func didTapCopySecret() {
		delegate?.didTapCopySecret(in: self)
	}

	func didTapDeleteAndPresent(alertController: UIAlertController) {
		delegate?.issuersView(self, didTapDeleteAndPresent: alertController)
	}

	func didTapAddToSystemAndOpen(url: URL) {
		delegate?.issuersView(self, didTapAddToSystemAndOpen: url)
	}

	func didAnimateFloatingButton(in scrollView: UIScrollView) {
		if scrollView.contentOffset.y >= safeAreaInsets.bottom + 60 {
			floatingButtonView.animateView(withAlpha: 0, translateY: 100)
		}
		else {
			floatingButtonView.animateView(withAlpha: 1, translateY: 0)
		}
	}

	func didPresent(alertController: UIAlertController) {
		delegate?.issuersView(self, didPresent: alertController)
	}

	func shouldAnimateNoIssuersLabel() {
		animateNoIssuersLabel()
	}

	func shouldAnimateNoSearchResultsLabel(forViewModels viewModels: [IssuerCellViewModel], isFiltering: Bool) {
		animateNoSearchResultsLabel(forViewModels: viewModels, isFiltering: isFiltering)
	}

}
