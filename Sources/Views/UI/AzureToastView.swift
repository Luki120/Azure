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

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupToastView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private func setupToastView() {
		translatesAutoresizingMaskIntoConstraints = false

		setupSizeConstraints(forView: toastView, width: 120, height: 40)
		toastView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

		centerViewOnBothAxes(toastViewLabel)
		toastViewLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10).isActive = true
		toastViewLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10).isActive = true

		let guide = safeAreaLayoutGuide	
		bottomAnchorConstraint = toastView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 50)
		bottomAnchorConstraint?.isActive = true
	}

	private func fadeInOutToastView(withFinalDelay delay: TimeInterval) {
		animateView(withDelay: 0, animations: {
			self.animateToastView(withConstraintConstant: -20, alpha: 1)
		}, completion: { _ in
			self.animateView(withDelay: 0.2, animations: {
				self.makeRotationTransform(forView: self.toastView, andLabel: self.toastViewLabel)
				self.layoutIfNeeded()
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
