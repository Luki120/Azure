import UIKit


final class PopoverVC: UIViewController {

	private lazy var gradientLayer: CAGradientLayer = {
		let firstColor = UIColor.kAzureMintTintColor
		let secondColor = UIColor(red: 0.40, green: 0.81, blue: 0.78, alpha: 1.0)
		let gradientColors = [firstColor.cgColor, secondColor.cgColor]
		let layer = CAGradientLayer()
		layer.colors = gradientColors
		layer.frame = view.bounds
		layer.startPoint = CGPoint(x: 0, y: 0)
		layer.endPoint = CGPoint(x: 1, y: 1)
		return layer
	}()

	private lazy var infoLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.alpha = 0
		label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(label)
		return label
	}()

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.layer.insertSublayer(gradientLayer, at: 0)

		infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
		infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
		infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
		infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		popoverPresentationController?.containerView?.alpha = 0
		popoverPresentationController?.containerView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
			UIView.animate(withDuration: 0.5, animations: {
				self.popoverPresentationController?.containerView?.alpha = 1
				self.popoverPresentationController?.containerView?.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: { _ in
				UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, animations: {
					self.infoLabel.alpha = 1
					self.infoLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
				}, completion: { _ in
					DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
						self.dismiss(animated: true)
					})
				})
			})
		})
	}

	func fadeInPopover(withMessage message: String) { infoLabel.text = message }

}
