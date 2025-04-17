import UIKit


protocol FloatingButtonViewDelegate: AnyObject {
	func didTapFloatingButton(in floatingButtonView: FloatingButtonView)
}

/// Class that'll show a floating button view on top of the issuers view
final class FloatingButtonView: UIView {

	private lazy var floatingButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.backgroundColor = .kAzureMintTintColor
		button.layer.shadowColor = UIColor.label.cgColor
		button.layer.cornerRadius = 30
		button.layer.shadowRadius = 8
		button.layer.shadowOffset = .init(width: 0, height: 0)
		button.layer.shadowOpacity = 0.5
		button.setImage(.init(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
		addSubview(button)
		return button
	}()

	weak var delegate: FloatingButtonViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFloatingButton()

		NotificationCenter.default.addObserver(self, selector: #selector(didTapUseFloatingButton), name: .shouldUseFloatingButtonNotification, object: nil)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		floatingButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupFloatingButton() {
		isHidden = !UserDefaults.standard.bool(forKey: "useFloatingButton") ? true : false

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
		delegate?.didTapFloatingButton(in: self)
	}

	@objc private func didTapUseFloatingButton() {
		isHidden = !UserDefaults.standard.bool(forKey: "useFloatingButton") ? true : false
	}
}

extension FloatingButtonView {

	// ! Public

	/// Function to animate the button's alpha & transform properties
	/// - Parameters:
	///		- withAlpha: A CGFloat that represents the button's alpha
	///		- translateY: A CGFloat that represents the button's translation Y value
	func animateView(withAlpha alpha: CGFloat, translateY ty: CGFloat) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .transitionCrossDissolve) {
			self.alpha = alpha
			self.transform = .init(translationX: 0, y: ty)
		}
	}

}
