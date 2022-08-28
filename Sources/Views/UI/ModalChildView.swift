import UIKit


protocol ModalChildViewDelegate: AnyObject {
	func modalChildViewDidTapScanQRCodeButton()
	func modalChildViewDidTapImportQRImageButton()
	func modalChildViewDidTapEnterManuallyButton()
	func modalChildViewDidTapDimmedView()
	func modalChildViewDidPanWithGesture(_ gesture: UIPanGestureRecognizer, modifyingConstraint constraint: NSLayoutConstraint)
}

final class ModalChildView: UIView {

	let kDefaultHeight:CGFloat = 300
	let kDismissableHeight:CGFloat = 215
	var currentSheetHeight:CGFloat = 300
	weak var delegate: ModalChildViewDelegate?

	private var containerViewBottomConstraint: NSLayoutConstraint?
	private var containerViewHeightConstraint: NSLayoutConstraint?

	private var shouldAllowScaleAnim = false
	private var strongTitleStackView: UIStackView?
	private var strongButtonsStackView: UIStackView?

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
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		return view
	}()

	override init (frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(
			roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: 300),
			byRoundingCorners: [.topLeft, .topRight],
			cornerRadii: CGSize(width: 16, height: 16)
		).cgPath
		containerView.layer.mask = maskLayer
		containerView.layer.cornerCurve = .continuous
	}

	private func setupViews() {
		translatesAutoresizingMaskIntoConstraints = false
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

		containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

		containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: kDefaultHeight)
		containerViewHeightConstraint?.isActive = true

		containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: kDefaultHeight)
		containerViewBottomConstraint?.isActive = true

	}

	private func layoutUI(forStackView titleSV: UIStackView, buttonsStackView buttonsSV: UIStackView) {
		titleSV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30).isActive = true
		titleSV.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
		titleSV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30).isActive = true
		titleSV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30).isActive = true

		buttonsSV.topAnchor.constraint(equalTo: titleSV.bottomAnchor, constant: 30).isActive = true
		buttonsSV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
	}

	// MARK: Animations

	private func animateSheet() {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0.6
			self.containerViewBottomConstraint?.constant = 0
			self.layoutIfNeeded()
		}, completion: { _ in
			guard self.shouldAllowScaleAnim else { return }
			self.animateSubviews(titleSV: self.strongTitleStackView ?? UIStackView(), buttonsSV: self.strongButtonsStackView ?? UIStackView())
		})
	}

	private func animateSubviews(titleSV: UIStackView, buttonsSV: UIStackView) {
		UIView.animate(withDuration: 0.5, delay: 0.008, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .transitionCrossDissolve, animations: {
			titleSV.alpha = 1
			titleSV.transform = CGAffineTransform(scaleX: 1, y: 1)
		}, completion: { _ in
			UIView.animate(withDuration: 0.5, delay: 0.008, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .transitionCrossDissolve, animations: {
				buttonsSV.alpha = 1
				buttonsSV.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: { _ in
				titleSV.transform = CGAffineTransform.identity
				buttonsSV.transform = CGAffineTransform.identity
			})
		})
	}

	// MARK: Reusable

	private func activateSizeConstraints(forView view: UIImageView) {
		view.widthAnchor.constraint(equalToConstant: 25).isActive = true
		view.heightAnchor.constraint(equalToConstant: 25).isActive = true
	}

	private func animateViews(
		withDuration duration: TimeInterval,
		animations: @escaping () -> (),
		completion: ((Bool) -> ())?
	) {
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: .curveEaseIn,
			animations: animations,
			completion: completion
		)
	}

	private func createButton(withTitle title: String, forTarget target: Any?, action: Selector) -> UIButton {
		let button = UIButton()
		button.titleLabel?.font = .systemFont(ofSize: 16)
		button.setTitle(title, for: .normal)
		button.setTitleColor(.label, for: .normal)
		button.addTarget(target, action: action, for: .touchUpInside)
		return button
	}

	private func createImageView(withImage image: UIImage) -> UIImageView {
		let imageView = UIImageView()
		imageView.image = image
		imageView.tintColor = .kAzureMintTintColor
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}

	private func createLabel(
		withFont font: UIFont,
		text: String,
		textColor: UIColor,
		addToStackView stackView: UIStackView
	) -> UILabel {
		let label = UILabel()
		label.font = font
		label.text = text
		label.textColor = textColor
		label.numberOfLines = 0
		label.textAlignment = .center
		stackView.addArrangedSubview(label)
		return label
	}

	private func createStackView(withAxis axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
		let stackView = UIStackView()
		stackView.axis = axis
		stackView.spacing = spacing
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}

	// MARK: Selectors

	@objc private func didTapView() { delegate?.modalChildViewDidTapDimmedView() }
	@objc private func didPan(_ sender: UIPanGestureRecognizer) {
		delegate?.modalChildViewDidPanWithGesture(sender, modifyingConstraint: containerViewHeightConstraint ?? NSLayoutConstraint())
	}

}


// MARK: Public

extension ModalChildView {

	func animateViews() { animateSheet() }
	func animateSheetHeight(_ height: CGFloat) {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0.6
			self.containerViewHeightConstraint?.constant = height
			self.layoutIfNeeded()
		}, completion: nil)

		currentSheetHeight = height
	}

	func animateDismiss(withCompletion completion: ((Bool) -> ())?) {
		animateViews(withDuration: 0.3, animations: {
			self.dimmedView.alpha = 0
			self.containerViewBottomConstraint?.constant = self.kDefaultHeight
			self.layoutIfNeeded()
		}, completion: completion)
	}

	func shouldCrossDissolveSubviews() {
		UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
			self.strongTitleStackView?.alpha = 0
			self.strongButtonsStackView?.alpha = 0
		}, completion: { _ in
			UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
				self.strongTitleStackView?.alpha = 1
				self.strongButtonsStackView?.alpha = 1
			}, completion: nil)
		})
	}

	func setupModalChildWithTitle(
		_ title: String,
		subtitle: String,
		buttonTitle: String,
		forTarget target: Any?,
		forSelector selector: Selector,
		secondButtonTitle: String,
		forTarget secondTarget: Any?,
		forSelector secondSelector: Selector,
		thirdStackView usesThirdSV: Bool = false,
		thirdButtonTitle: String? = nil,
		forTarget thirdTarget: Any? = nil,
		forSelector thirdSelector: Selector? = nil,
		accessoryImage: UIImage,
		secondAccessoryImage: UIImage,
		thirdAccessoryImage: UIImage? = nil,
		prepareForReuse reuse: Bool,
		scaleAnimation scaleAnim: Bool

	) {

		if reuse {
			strongTitleStackView?.removeFromSuperview()
			strongButtonsStackView?.removeFromSuperview()
		}

		/* ********** STACK VIEWS ********** */
		let titleSV = createStackView(withAxis: .vertical, spacing: 10)
		let buttonsSV = createStackView(withAxis: .vertical, spacing: 20)
		let firstSV = createStackView(withAxis: .horizontal, spacing: 10)
		let secondSV = createStackView(withAxis: .horizontal, spacing: 10)

		var thirdSV: UIStackView?
		if usesThirdSV { thirdSV = createStackView(withAxis: .horizontal, spacing: 10) }

		containerView.addSubview(titleSV)
		containerView.addSubview(buttonsSV)
		buttonsSV.addArrangedSubview(firstSV)
		buttonsSV.addArrangedSubview(secondSV)
		if usesThirdSV { buttonsSV.addArrangedSubview(thirdSV ?? UIStackView()) }

		if scaleAnim {
			buttonsSV.alpha = 0
			buttonsSV.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			titleSV.alpha = 0
			titleSV.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		}

		/* ********** LABELS ********** */
		let _ = createLabel(withFont: .systemFont(ofSize: 16), text: title, textColor: .label, addToStackView: titleSV)
		let _ = createLabel(withFont: .systemFont(ofSize: 12), text: subtitle, textColor: .secondaryLabel, addToStackView: titleSV)

		/* ********** IMAGE VIEWS ********** */
		let firstImageView = createImageView(withImage: accessoryImage)
		let secondImageView = createImageView(withImage: secondAccessoryImage)
		let thirdImageView = createImageView(withImage: thirdAccessoryImage ?? UIImage())

		/* ********** BUTTONS ********** */
		let firstButton = createButton(withTitle: buttonTitle, forTarget: target, action: selector)
		let secondButton = createButton(withTitle: secondButtonTitle, forTarget: secondTarget, action: secondSelector)
		let thirdButton = createButton(withTitle: thirdButtonTitle ?? "", forTarget: thirdTarget, action: thirdSelector ?? secondSelector)

		firstSV.addArrangedSubview(firstImageView)
		firstSV.addArrangedSubview(firstButton)
		secondSV.addArrangedSubview(secondImageView)
		secondSV.addArrangedSubview(secondButton)
		thirdSV?.addArrangedSubview(thirdImageView)
		thirdSV?.addArrangedSubview(thirdButton)

		layoutUI(forStackView: titleSV, buttonsStackView: buttonsSV)
		activateSizeConstraints(forView: firstImageView)
		activateSizeConstraints(forView: secondImageView)
		activateSizeConstraints(forView: thirdImageView)

		strongTitleStackView = titleSV
		strongButtonsStackView = buttonsSV
		shouldAllowScaleAnim = scaleAnim

	}

	func calculateAlpha(basedOnTranslation translation: CGPoint) {
		let y = translation.y
		let alpha = y / dimmedView.frame.height
		dimmedView.alpha = 0.6 - alpha
	}

}
