import UIKit


protocol NewIssuerOptionsViewDelegate: AnyObject {
	func didTapScanQRCodeCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapImportQRImageCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapEnterManuallyCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapLoadBackupCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapMakeBackupCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapViewInFilesOrFilzaCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapDismissCell(in newIssuerOptionsView: NewIssuerOptionsView)
	func didTapDimmedView(in newIssuerOptionsView: NewIssuerOptionsView)
	func newIssuerOptionsView(
		_ newIssuerOptionsView: NewIssuerOptionsView,
		didPanWithGesture gesture: UIPanGestureRecognizer,
		modifyingConstraint constraint: NSLayoutConstraint
	)
}

/// Class that'll show the new issuer options view
final class NewIssuerOptionsView: UIView {

	let kDefaultHeight: CGFloat = 300
	let kDismissableHeight: CGFloat = 215

	private let newIssuerOptionsHeaderView = NewIssuerOptionsHeaderView()
	private let viewModel = NewIssuerOptionsViewViewModel()

	var tableView: UITableView { return newIssuerOptionsTableView }

	private var containerViewBottomConstraint, containerViewHeightConstraint: NSLayoutConstraint!

	private(set) var currentSheetHeight: CGFloat = 300

	weak var delegate: NewIssuerOptionsViewDelegate?

	private lazy var dimmedView: UIView = {
		let view = UIView()
		view.alpha = 0
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		return view
	}()

	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemBackground
		addSubview(view)
		return view
	}()

	private lazy var newIssuerOptionsTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.delegate = viewModel
		tableView.dataSource = viewModel
		tableView.separatorStyle = .none
		tableView.backgroundColor = .secondarySystemGroupedBackground
		tableView.isScrollEnabled = false
		tableView.tableHeaderView = newIssuerOptionsHeaderView
		tableView.register(NewIssuerOptionsCell.self, forCellReuseIdentifier: NewIssuerOptionsCell.identifier)
		containerView.addSubview(tableView)
		return tableView
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		viewModel.delegate = self
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(
			roundedRect: .init(x: 0, y: 0, width: frame.width, height: 300),
			byRoundingCorners: [.topLeft, .topRight],
			cornerRadii: .init(width: 16, height: 16)
		).cgPath

		containerView.layer.mask = maskLayer
		containerView.layer.cornerCurve = .continuous
	}

	// ! Private

	private func setupUI() {
		setupGestures()
		layoutUI()
	}

	private func setupGestures() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
		dimmedView.addGestureRecognizer(tapGesture)

		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
		addGestureRecognizer(panGesture)
	}

	private func layoutUI() {
		pinViewToAllEdges(dimmedView)

		setupHorizontalConstraints(forView: containerView)

		containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: kDefaultHeight)
		containerViewHeightConstraint.isActive = true

		containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: kDefaultHeight)
		containerViewBottomConstraint.isActive = true

		containerView.pinViewToAllEdges(newIssuerOptionsTableView)
	}

	private func animateSheet() {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0.6
			self.containerViewBottomConstraint.constant = 0
			self.layoutIfNeeded()
		}) { _ in
			self.newIssuerOptionsHeaderView.animateHeaderView()
		}
	}

	// ! Reusable

	private func animateViews(
		withDuration duration: TimeInterval,
		animations: @escaping () -> Void,
		completion: ((Bool) -> ())? = { _ in }
	) {
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: .curveEaseIn,
			animations: animations,
			completion: completion
		)
	}

	// ! Selectors

	@objc private func didTapView() {
		delegate?.didTapDimmedView(in: self)
	}

	@objc private func didPan(_ gesture: UIPanGestureRecognizer) {
		delegate?.newIssuerOptionsView(self, didPanWithGesture: gesture, modifyingConstraint: containerViewHeightConstraint)
	}

}

// ! NewIssuerOptionsViewViewModelDelegate

extension NewIssuerOptionsView: NewIssuerOptionsViewViewModelDelegate {

	func didTapScanQRCodeCell() {
		delegate?.didTapScanQRCodeCell(in: self)
	}

	func didTapImportQRImageCell() {
		delegate?.didTapImportQRImageCell(in: self)
	}

 	func didTapEnterManuallyCell() {
		delegate?.didTapEnterManuallyCell(in: self)
	}

	func didTapLoadBackupCell() {
		delegate?.didTapLoadBackupCell(in: self)
	}

	func didTapMakeBackupCell() {
		delegate?.didTapMakeBackupCell(in: self)
	}

	func didTapViewInFilesOrFilzaCell() {
		delegate?.didTapViewInFilesOrFilzaCell(in: self)
	}

	func didTapDismissCell() {
		delegate?.didTapDismissCell(in: self)
	}

}

extension NewIssuerOptionsView {

	// ! Public

	/// Function to animate the views
	func animateViews() {
		animateSheet()
	}

	/// Function to animate the sheet's height constraint
	/// - Parameters:
	///		- height: A CGFloat that represents the height
	func animateSheetHeight(_ height: CGFloat) {
		animateViews(withDuration: 0.3) {
			self.dimmedView.alpha = 0.6
			self.containerViewHeightConstraint.constant = height
			self.layoutIfNeeded()
		}

		currentSheetHeight = height
	}

	/// Function to animate the dismissal of the sheet view
	/// - Parameters:
	///		- withCompletion: Optional closure that takes a Bool as argument & returns nothing
	func animateDismiss(withCompletion completion: ((Bool) -> ())?) {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0
			self.containerViewBottomConstraint.constant = self.kDefaultHeight
			self.layoutIfNeeded()
		}, completion: completion)
	}

	/// Function to calculate & set the dimmed view's alpha based on the translation of the pan gesture
	/// - Parameters:
	///		- basedOnTranslation: A CGPoint that represents the translation
	func calculateAlpha(basedOnTranslation translation: CGPoint) {
		let alpha = translation.y / dimmedView.frame.height
		dimmedView.alpha = 0.6 - alpha
	}

	/// Function to configure the header
	/// - Parameters:
	///		- isDefaultConfiguration: A Bool to check if we should set the header with the default configuration
	///		- isBackupOptions: A Bool to check if we should set the header for the backup options data source
	func configureHeader(isDefaultConfiguration: Bool, isBackupOptions: Bool) {
		if isDefaultConfiguration {
			newIssuerOptionsHeaderView.configure(with: .init())
		}
		else if isBackupOptions {
			newIssuerOptionsHeaderView.configure(with:
				.init(
					height: 110,
					title: "Backup options",
					subtitle: "Choose between loading a backup from file or making a new one."
				)
			)
		}
		else {
			newIssuerOptionsHeaderView.configure(with:
				.init(
					height: 110,
					title: "Make backup actions",
					subtitle: "Do you want to view your backup in \(isJailbroken() ? "Filza" : "Files") now?",
					prepareForReuse: true
				)
			)

		}
	}

	/// Function to reload the new issuer options view's table view data
	func reloadData() {
		newIssuerOptionsTableView.reloadData()
	}

	/// Function to setup the backup options data source
	func setupBackupOptionsDataSource() {
		viewModel.setupBackupOptionsDataSource()
	}

	/// Function to setup the make backup options data source
	func setupMakeBackupOptionsDataSource() {
		viewModel.setupMakeBackupOptionsDataSource()
	}

}
