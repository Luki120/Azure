import UIKit


protocol ModalChildViewDelegate: AnyObject {
	func didTapScanQRCodeButton(in modalChildView: ModalChildView)
	func didTapImportQRImageButton(in modalChildView: ModalChildView)
	func didTapEnterManuallyButton(in modalChildView: ModalChildView)
	func didTapDimmedView(in modalChildView: ModalChildView)
	func modalChildView(
		_ modalChildView: ModalChildView,
		didPanWithGesture gesture: UIPanGestureRecognizer,
		modifyingConstraint constraint: NSLayoutConstraint
	)

}

/// Class that'll show a modal sheet view
final class ModalChildView: UIView {

	let kDefaultHeight: CGFloat = 300
	let kDismissableHeight: CGFloat = 215

	var headerView: NewIssuerOptionsHeaderView { return newIssuerOptionsHeaderView }
	var tableView: UITableView { return newIssuerOptionsTableView }

	private var containerViewBottomConstraint, containerViewHeightConstraint: NSLayoutConstraint!
	private var newIssuerOptionsHeaderView: NewIssuerOptionsHeaderView!

	private(set) var currentSheetHeight: CGFloat = 300

	weak var delegate: ModalChildViewDelegate?

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
		tableView.isScrollEnabled = false
		tableView.separatorStyle = .none
		tableView.backgroundColor = .secondarySystemGroupedBackground
		tableView.register(NewIssuerOptionsCell.self, forCellReuseIdentifier: NewIssuerOptionsCell.identifier)
		containerView.addSubview(tableView)
		return tableView
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/// Designated initializer
	/// - Parameters:
	///     - dataSource: The object that will conform to the table view's data source
	init(dataSource: UITableViewDataSource? = nil) {
		super.init(frame: .zero)
		setupUI()

		newIssuerOptionsTableView.dataSource = dataSource
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

		newIssuerOptionsHeaderView = .init()
		newIssuerOptionsTableView.tableHeaderView = newIssuerOptionsHeaderView
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

	// ! Animations

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

	@objc func didTapScanQRCodeButton() {
		delegate?.didTapScanQRCodeButton(in: self)
	}

	@objc func didTapImportQRImageButton() {
		delegate?.didTapImportQRImageButton(in: self)
	}

	@objc func didTapEnterManuallyButton() {
		delegate?.didTapEnterManuallyButton(in: self)
	}

	@objc private func didTapView() {
		delegate?.didTapDimmedView(in: self)
	}

	@objc private func didPan(_ gesture: UIPanGestureRecognizer) {
		delegate?.modalChildView(self, didPanWithGesture: gesture, modifyingConstraint: containerViewHeightConstraint)
	}

}

extension ModalChildView {

	// ! Public

	/// Function to animate the views
	func animateViews() {
		animateSheet()
	}

	/// Function to animate the sheet's height constraint
	/// - Parameters:
	///     - height: A CGFloat that represents the height
	func animateSheetHeight(_ height: CGFloat) {
		animateViews(withDuration: 0.3) {
			self.dimmedView.alpha = 0.6
			self.containerViewHeightConstraint.constant = height
			self.layoutIfNeeded()
		}

		currentSheetHeight = height
	}

	/// Function to animate the dismissal of the modal sheet view
	/// - Parameters:
	///     - withCompletion: Optional closure that takes a Bool as argument & returns nothing
	func animateDismiss(withCompletion completion: ((Bool) -> ())?) {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0
			self.containerViewBottomConstraint.constant = self.kDefaultHeight
			self.layoutIfNeeded()
		}, completion: completion)
	}

	/// Function to calculate & set the dimmed view's alpha based on the translation of the pan gesture
	/// - Parameters:
	///     - basedOnTranslation: A CGPoint that represents the translation
	func calculateAlpha(basedOnTranslation translation: CGPoint) {
		let alpha = translation.y / dimmedView.frame.height
		dimmedView.alpha = 0.6 - alpha
	}

	/// Function to reload the modal sheet view's table view data
	func reloadData() {
		newIssuerOptionsTableView.reloadData()
	}

}
