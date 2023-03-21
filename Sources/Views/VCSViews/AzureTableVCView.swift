import UIKit


final class AzureTableVCView: UIView {

	var azureFloatingButtonView = AzureFloatingButtonView()
	var azureTableView = UITableView()
	var azureToastView = AzureToastView()

	private var kUserInterfaceStyle: Bool { return traitCollection.userInterfaceStyle == .dark }

	private lazy var noIssuersLabel = UILabel()
	private lazy var noResultsLabel = UILabel()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init(
		dataSource: UITableViewDataSource,
		tableViewDelegate: UITableViewDelegate,
		floatingButtonViewDelegate: AzureFloatingButtonViewDelegate
	) {
		super.init(frame: .zero)

		setupViews()
		azureTableView.dataSource = dataSource
		azureTableView.delegate = tableViewDelegate
		azureFloatingButtonView.delegate = floatingButtonViewDelegate

		azureTableView.register(AzurePinCodeCell.self, forCellReuseIdentifier: AzurePinCodeCell.identifier)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutViews()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		azureTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground
	}

	// ! Private

	private func setupViews() {
		azureTableView.separatorStyle = .none
		azureTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground

		noIssuersLabel = createLabel(withText: "No issuers were added yet. Tap the + button in order to add one.")
		noResultsLabel = createLabel(withText: "No results were found for this query.")
		noResultsLabel.alpha = 0

		addSubview(azureTableView)
		addSubview(azureFloatingButtonView)
		addSubview(azureToastView)
		addSubview(noIssuersLabel)
		addSubview(noResultsLabel)
	}

	private func layoutViews() {
		pinViewToAllEdgesIncludingSafeAreas(azureTableView)
		pinAzureToastToTheBottomCenteredOnTheXAxis(azureToastView, bottomConstant: -5)

		let guide = safeAreaLayoutGuide

		azureFloatingButtonView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -25).isActive = true
		azureFloatingButtonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
		setupSizeConstraints(forView: azureFloatingButtonView, width: 60, height: 60)

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

extension AzureTableVCView {

	// ! Public

	func animateNoIssuersLabel() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
			if TOTPManager.sharedInstance.issuers.count == 0 {
				self.azureTableView.alpha = 0
				self.noIssuersLabel.alpha = 1
				self.noIssuersLabel.transform = .init(scaleX: 1, y: 1)
			}
			else {
				self.azureTableView.alpha = 1
				self.noIssuersLabel.alpha = 0
				self.noIssuersLabel.transform = .init(scaleX: 0.1, y: 0.1)
			}
		}
	}

	func animateNoSearchResultsLabel(forArray array: [Issuer], isFiltering: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if array.count == 0 && TOTPManager.sharedInstance.issuers.count > 0 && isFiltering {
				self.noResultsLabel.alpha = 1
			}
			else { self.noResultsLabel.alpha = 0 }
		}
	}

}
