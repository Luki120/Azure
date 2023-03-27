import UIKit


final class IssuersVCView: UIView {

	private var kUserInterfaceStyle: Bool { return traitCollection.userInterfaceStyle == .dark }

	private(set) lazy var issuersTableView: UITableView = {
		let tableView = UITableView()
		tableView.separatorStyle = .none
		tableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground
		tableView.register(IssuerCell.self, forCellReuseIdentifier: IssuerCell.identifier)
		return tableView
	}()

	private(set) var floatingButtonView = FloatingButtonView()
	private(set) var toastView = ToastView()

	private lazy var noIssuersLabel = UILabel()
	private lazy var noResultsLabel = UILabel()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/// Designated initializer
	/// - Parameters:
	///     - dataSource: The object that will conform to the table view's data source
	///		- delegate: The object that will conform to the table view's data delegate
	///		- floatingButtonViewDelegate: The object that will conform to the floating button view's delegate
	init(
		dataSource: UITableViewDataSource,
		delegate: UITableViewDelegate,
		floatingButtonViewDelegate: FloatingButtonViewDelegate
	) {
		super.init(frame: .zero)
		setupViews()

		issuersTableView.dataSource = dataSource
		issuersTableView.delegate = delegate
		floatingButtonView.delegate = floatingButtonViewDelegate
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutViews()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		issuersTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground
	}

	// ! Private

	private func setupViews() {
		noIssuersLabel = createLabel(withText: "No issuers were added yet. Tap the + button in order to add one.")
		noResultsLabel = createLabel(withText: "No results were found for this query.", initialAlpha: 0)

		addSubviews(issuersTableView, floatingButtonView, toastView, noIssuersLabel, noResultsLabel)
	}

	private func layoutViews() {
		pinViewToAllEdgesIncludingSafeAreas(issuersTableView)
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

extension IssuersVCView {

	// ! Public

	/// Function to animate the no issuers label when the data source is empty
	func animateNoIssuersLabel() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
			if IssuerManager.sharedInstance.issuers.count == 0 {
				self.issuersTableView.alpha = 0
				self.noIssuersLabel.alpha = 1
				self.noIssuersLabel.transform = .init(scaleX: 1, y: 1)
			}
			else {
				self.issuersTableView.alpha = 1
				self.noIssuersLabel.alpha = 0
				self.noIssuersLabel.transform = .init(scaleX: 0.1, y: 0.1)
			}
		}
	}

	/// Function to animate the no search results label when the conditions are met
	/// - Parameters:
	///     - forArray: The filtered array object
	///		- isFiltering: A boolean to check if we're currently filtering
	func animateNoSearchResultsLabel(forArray array: [Issuer], isFiltering: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if array.count == 0 && IssuerManager.sharedInstance.issuers.count > 0 && isFiltering {
				self.noResultsLabel.alpha = 1
			}
			else { self.noResultsLabel.alpha = 0 }
		}
	}

}
