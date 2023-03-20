import UIKit


final class AzureToastView: UIView {

	private var bottomAnchorConstraint: NSLayoutConstraint?

	private lazy var toastView: UIView = {
		let view = UIView()
		view.alpha = 0
		view.backgroundColor = .kAzureMintTintColor
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 20
		addSubview(view)
		return view
	}()

	private lazy var toastViewLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.textColor = .label
		label.numberOfLines = 0
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		toastView.addSubview(label)
		return label
	}()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupToastView()
	}

	// ! Private

	private func setupToastView() {
		translatesAutoresizingMaskIntoConstraints = false

		setupHorizontalConstraints(forView: toastView, leadingConstant: 10, trailingConstant: -10)
		toastView.heightAnchor.constraint(equalToConstant: 40).isActive = true

		toastView.centerViewOnBothAxes(toastViewLabel)
		toastView.setupHorizontalConstraints(forView: toastViewLabel, leadingConstant: 10, trailingConstant: -10)

		let guide = safeAreaLayoutGuide
		bottomAnchorConstraint = toastView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 50)
		bottomAnchorConstraint?.isActive = true
	}

	private func fadeInOutToastView(withFinalDelay delay: TimeInterval) {
		animateView(animations: {
			self.animateToastView(withConstraintConstant: -20, alpha: 1)
		}, completion: { _ in
			self.animateView(withDelay: 0.2, animations: {
				self.makeRotationTransform(forViews: [self.toastView, self.toastViewLabel])
			}, completion: { _ in
				self.animateView(withDelay: delay, animations: {
					self.animateToastView(withConstraintConstant: 50, alpha: 0)
				}, completion: { _ in
					self.toastView.layer.transform = CATransform3DIdentity
					self.toastViewLabel.layer.transform = CATransform3DIdentity
				})
			})
		})
	}

	private func animateToastView(withConstraintConstant constant: CGFloat, alpha: CGFloat) {
		bottomAnchorConstraint?.constant = constant
		toastView.alpha = alpha
		layoutIfNeeded()
	}

}

extension AzureToastView {

	// ! Public

	func fadeInOutToastView(withMessage message: String, finalDelay delay: TimeInterval) {
		toastViewLabel.text = message
		fadeInOutToastView(withFinalDelay: delay)
	}

}
