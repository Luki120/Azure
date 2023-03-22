import UIKit


protocol FloatingButtonViewDelegate: AnyObject {
	func floatingButtonViewDidTapFloatingButton()
}

final class FloatingButtonView: UIView {

	weak var delegate: FloatingButtonViewDelegate?

	private lazy var floatingButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.backgroundColor = .kAzureMintTintColor
		button.layer.shadowColor = UIColor.label.cgColor
		button.layer.cornerRadius = 30
		button.layer.shadowRadius = 8
		button.layer.shadowOffset = CGSize(width: 0, height: 1)
		button.layer.shadowOpacity = 0.5
		button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
		addSubview(button)
		return button
	}()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFloatingButton()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		floatingButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupFloatingButton() {
		translatesAutoresizingMaskIntoConstraints = false
		pinViewToAllEdges(floatingButton)

		if #available(iOS 15.0, *) { floatingButton.configuration = .plain() }
		else { floatingButton.adjustsImageWhenHighlighted = false }

		floatingButton.addAction(
			UIAction { [weak self] _ in
				self?.didTapButton()
			},
			for: .touchUpInside
		)
	}

	@objc private func didTapButton() {
 		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
			self.transform = .init(scaleX: 0.8, y: 0.8)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
					self.transform = .init(scaleX: 1, y: 1)
				}
			}
		}
		delegate?.floatingButtonViewDidTapFloatingButton()
	}
}

extension FloatingButtonView {

	// ! Public

	func animateView(withAlpha alpha: CGFloat, translateX tx: CGFloat, translateY ty: CGFloat) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .transitionCrossDissolve) {
			self.alpha = alpha
			self.transform = .init(translationX: tx, y: ty)
		}
	}

}
