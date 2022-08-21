import UIKit


extension UIView {

	func animateViewWithDelay(_ delay: TimeInterval,
		withAnimations animations: @escaping () -> (),
		withCompletion completion: ((Bool) -> ())?
	) {
		UIView.animate(withDuration: 0.5,
			delay: delay,
			options: .curveEaseIn,
			animations: animations,
			completion: completion
		)
	}

	@objc public func pinViewToAllEdges(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	func makeRotationTransformForView(_ view: UIView, andLabel label: UILabel) {
		var rotation = CATransform3DIdentity
		rotation.m34 = 1.0 / -500.0
		rotation = CATransform3DRotate(rotation, 180 * CGFloat.pi / 180.0, 0.0, 1.0, 0.0)
		view.layer.transform = rotation
		label.layer.transform = rotation
	}

	@objc public func pinViewToAllEdgesIncludingSafeAreas(_ view: UIView, bottomConstant: CGFloat) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: leadingAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	@objc public func pinAzureToastToTheBottomCenteredOnTheXAxis(_ toastView: UIView, bottomConstant: CGFloat) {
		toastView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			toastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			toastView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

}

extension UIColor {

	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)

}
