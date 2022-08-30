import UIKit


final class AzureTableVCView: UIView {

	var azureFloatingButtonView: AzureFloatingButtonView!
	var azureTableView: UITableView!
	var azureToastView: AzureToastView!

	private var kUserInterfaceStyle: Bool { return traitCollection.userInterfaceStyle == .dark }

	private lazy var placeholderLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.text = "No issuers were added yet. Tap the + button in order to add one."
		label.textColor = .placeholderText
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		return label
	}()

	init(
		withDataSource dataSource: UITableViewDataSource,
		tableViewDelegate: UITableViewDelegate,
		floatingButtonViewDelegate: AzureFloatingButtonViewDelegate
	) {
		super.init(frame: .zero)
		setupViews()
		azureTableView.dataSource = dataSource
		azureTableView.delegate = tableViewDelegate
		azureFloatingButtonView.delegate = floatingButtonViewDelegate
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdgesIncludingSafeAreas(azureTableView, bottomConstant: -50)
		pinAzureToastToTheBottomCenteredOnTheXAxis(azureToastView, bottomConstant: -55)

		let guide = safeAreaLayoutGuide

		azureFloatingButtonView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -74).isActive = true
		azureFloatingButtonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
		azureFloatingButtonView.widthAnchor.constraint(equalToConstant: 60).isActive = true
		azureFloatingButtonView.heightAnchor.constraint(equalToConstant: 60).isActive = true

		placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
		placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true

	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		azureTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground
	}

	private func setupViews() {
		azureTableView = UITableView()
		azureTableView.separatorStyle = .none
		azureTableView.backgroundColor = kUserInterfaceStyle ? .systemBackground : .secondarySystemBackground
		addSubview(azureTableView)

		azureFloatingButtonView = AzureFloatingButtonView()
		azureToastView = AzureToastView()

		addSubview(azureFloatingButtonView)
		addSubview(azureToastView)
	}

	func animateViewsWhenNecessary() {
		UIView.animate(withDuration:0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
			if TOTPManager.sharedInstance.entriesArray.count == 0 {
				self.azureTableView.alpha = 0
				self.placeholderLabel.alpha = 1
				self.placeholderLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
			}
			else {
				self.azureTableView.alpha = 1
				self.placeholderLabel.alpha = 0
				self.placeholderLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			}
		}, completion: nil)
	}

}
