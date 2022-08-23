import UIKit


@objc public class AzureTableVCView: UIView {

	@objc public var azureFloatingButtonView: AzureFloatingButtonView!
	@objc public var azureTableView: UITableView!
	@objc public var azureToastView: AzureToastView!

	private var kUserInterfaceStyle: Bool { return traitCollection.userInterfaceStyle == .dark }

	@objc public lazy var placeholderLabel: UILabel = {
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

	@objc public init(
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

	override public func layoutSubviews() {
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

	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

}
