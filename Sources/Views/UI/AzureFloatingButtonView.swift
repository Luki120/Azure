import UIKit


@objc public protocol AzureFloatingButtonViewDelegate: AnyObject {
	func azureFloatingButtonViewDidTapFloatingButton()
}

@objc public class AzureFloatingButtonView: UIView {

	@objc public weak var delegate: AzureFloatingButtonViewDelegate?

	private lazy var floatingButton: UIButton = {
		let button = UIButton()
		button.tintColor = .label
		button.backgroundColor = .kAzureMintTintColor
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.shadowColor = UIColor.label.cgColor
		button.layer.cornerRadius = 30
		button.layer.shadowRadius = 8
		button.layer.shadowOffset = CGSize(width: 0, height: 1)
		button.layer.shadowOpacity = 0.5
		button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
		button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
		addSubview(button)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFloatingButton()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		floatingButton.layer.shadowColor = UIColor.label.cgColor
	}

	private func setupFloatingButton() {
		translatesAutoresizingMaskIntoConstraints = false
		pinViewToAllEdges(floatingButton)
	}

	@objc private func didTapButton() { delegate?.azureFloatingButtonViewDidTapFloatingButton() }
	@objc public func animateViewWithAlpha(_ alpha: CGFloat, translateX tx: CGFloat, translateY ty: CGFloat) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .transitionCrossDissolve, animations: {
			self.alpha = alpha
			self.transform = CGAffineTransform(translationX: tx, y: ty)
		})
	}

}
