import UIKit


final class IssuersVCView: UIView {

	var floatingButtonView = FloatingButtonView()
	var issuersTableView = UITableView()
	var toastView = ToastView()

	private var kUserInterfaceStyle: Bool { return traitCollection.userInterfaceStyle == .dark }

	private lazy var noIssuersLabel = UILabel()
	private lazy var noResultsLabel = UILabel()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init(
		dataSource: UITableViewDataSource,
		tableViewDelegate: UITableViewDelegate,
		floatingButtonViewDelegate: FloatingButtonViewDelegate
	) {
		super.init(frame: .zero)

		setupViews()
		issuersTableView.dataSource = dataSource
		issuersTableView.delegate = tableViewDelegate
		floatingButtonView.delegate = floatingButtonViewDelegate

		issuersTableView.register(IssuerCell.self, forCellReuseIdentifier: IssuerCell.identifier)
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
		issuersTableView.separatorStyle = .none
		issuersTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground

		noIssuersLabel = createLabel(withText: "No issuers were added yet. Tap the + button in order to add one.")
		noResultsLabel = createLabel(withText: "No results were found for this query.")
		noResultsLabel.alpha = 0

		addSubview(issuersTableView)
		addSubview(floatingButtonView)
		addSubview(toastView)
		addSubview(noIssuersLabel)
		addSubview(noResultsLabel)
	}

	private func layoutViews() {
		pinViewToAllEdgesIncludingSafeAreas(issuersTableView)
		pinAzureToastToTheBottomCenteredOnTheXAxis(toastView, bottomConstant: -5)

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

	private func createLabel(withText text: String) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.text = text
		label.textColor = .placeholderText
		label.numberOfLines = 0
		label.textAlignment = .center
		addSubview(label)
		return label
	}

}

extension IssuersVCView {

	// ! Public

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

	func animateNoSearchResultsLabel(forArray array: [Issuer], isFiltering: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if array.count == 0 && IssuerManager.sharedInstance.issuers.count > 0 && isFiltering {
				self.noResultsLabel.alpha = 1
			}
			else { self.noResultsLabel.alpha = 0 }
		}
	}

}
