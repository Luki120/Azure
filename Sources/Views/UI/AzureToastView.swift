import UIKit


final class AzureToastView: UIView {

	private var bottomAnchorConstraint: NSLayoutConstraint?

	private lazy var toastView: UIView = {
		let view = UIView()
		view.alpha = 0
		view.backgroundColor = .kAzureMintTintColor
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 20
		view.translatesAutoresizingMaskIntoConstraints = false
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
		label.translatesAutoresizingMaskIntoConstraints = false
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
		NSLayoutConstraint.activate([
			toastView.centerXAnchor.constraint(equalTo: centerXAnchor),
			toastView.widthAnchor.constraint(equalToConstant: 120),
			toastView.heightAnchor.constraint(equalToConstant: 40),

			toastViewLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor),
			toastViewLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
			toastViewLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
			toastViewLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10)
		])
		let guide = safeAreaLayoutGuide	
		bottomAnchorConstraint = toastView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 50)
		bottomAnchorConstraint?.isActive = true
	}

	private func fadeInOutToastView(withFinalDelay delay: TimeInterval) {
		animateViewWithDelay(0, withAnimations: {
			self.animateToastViewWithConstraintConstant(-20, andAlpha: 1)
		}, withCompletion: { _ in
			self.animateViewWithDelay(0.2, withAnimations: {
				self.makeRotationTransformForView(self.toastView, andLabel: self.toastViewLabel)
				self.layoutIfNeeded()
			}, withCompletion: { _ in
				self.animateViewWithDelay(delay, withAnimations: {
					self.animateToastViewWithConstraintConstant(50, andAlpha: 0)
				}, withCompletion: { _ in
					self.toastView.layer.transform = CATransform3DIdentity
					self.toastViewLabel.layer.transform = CATransform3DIdentity
				})
			})
		})
	}

	private func animateToastViewWithConstraintConstant(_ constant: CGFloat, andAlpha alpha: CGFloat) {
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
