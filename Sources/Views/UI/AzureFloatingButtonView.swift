import UIKit


protocol AzureFloatingButtonViewDelegate: AnyObject {
	func azureFloatingButtonViewDidTapFloatingButton()
}

final class AzureFloatingButtonView: UIView {

	weak var delegate: AzureFloatingButtonViewDelegate?

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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		floatingButton.layer.shadowColor = UIColor.label.cgColor
	}

	private func setupFloatingButton() {
		translatesAutoresizingMaskIntoConstraints = false
		pinViewToAllEdges(floatingButton)

		if #available(iOS 15.0, *) { floatingButton.configuration = .plain() }
		else { floatingButton.adjustsImageWhenHighlighted = false }
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
		delegate?.azureFloatingButtonViewDidTapFloatingButton()
	}
}

extension AzureFloatingButtonView {

	// ! Public

	func animateView(withAlpha alpha: CGFloat, translateX tx: CGFloat, translateY ty: CGFloat) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .transitionCrossDissolve, animations: {
			self.alpha = alpha
			self.transform = .init(translationX: tx, y: ty)
		})
	}

}
