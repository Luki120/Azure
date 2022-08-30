import UIKit


protocol AzurePinCodeCellDelegate: AnyObject {
	func azurePinCodeCellDidTapCell(_ cell: AzurePinCodeCell)
	func azurePinCodeCellDidTapInfoButton(_ cell: AzurePinCodeCell)
	func azurePinCodeCellShouldFadeInOutToastView()
}

final class AzurePinCodeCell: UITableViewCell {

 	private var issuersStackView: UIStackView!
	private var copyPinButton: UIButton!
	private var infoButton: UIButton!
	private var buttonsStackView: UIStackView!
	private var generator: TOTPGenerator?
	private var circleProgressView: UIView!
	private var duration = 0

	private let π = Double.pi

	var issuer = ""
	var hashString = ""

	weak var delegate: AzurePinCodeCellDelegate?

 	lazy var issuerImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let pinLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18)
		label.textAlignment = .center
		return label
	}()

 	private lazy var circleLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.path = UIBezierPath(arcCenter: CGPoint(x: 10, y: 10), radius: 10, startAngle: -0.5 * π, endAngle: 1.5 * π, clockwise: true).cgPath
		layer.lineCap = .round
		layer.lineWidth = 5
		layer.fillColor = UIColor.clear.cgColor
		layer.strokeColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowRadius = 5
		layer.shadowOffset = CGSize(width: 1, height: 1)
		layer.shadowOpacity = 0.8
		circleProgressView.layer.addSublayer(layer)
		return layer
	}()

	// ! Lifecycle

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
		initializeTimers()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		issuerImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		circleLayer.shadowColor = UIColor.kAzureMintTintColor.cgColor
	}

 	private func initializeTimers() {
		let timestamp = Int(ceil(Date().timeIntervalSince1970))
		DispatchQueue.main.asyncAfter(deadline: .now() + Double(30 - timestamp % 30), execute: {
			self.perform(#selector(self.startTimer), with: self, afterDelay: Double(30 - timestamp % 30))
			Timer.scheduledTimer(timeInterval: Double(30 - timestamp % 30), target: self, selector: #selector(self.regeneratePIN), userInfo: nil, repeats: false)
		})
	}

	private func setupUI() {
		let pinCode = generator?.generateOTP(for: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))
		pinLabel.text = pinCode

		issuersStackView = setupStackView()
		issuersStackView.addArrangedSubview(issuerImageView)
		issuersStackView.addArrangedSubview(pinLabel)
		buttonsStackView = setupStackView()

		copyPinButton = setupButton(
 			withImage: UIImage(systemName: "paperclip") ?? UIImage(),
			forSelector: #selector(didTapCopyPinButton)
		)
		infoButton = setupButton(
			withImage: UIImage(systemName: "info.circle") ?? UIImage(),
			forSelector: #selector(didTapInfoButton)
		)

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
		contentView.addGestureRecognizer(tapRecognizer)

		setupCircularProgressView()
	}

 	private func setupCircularProgressView() {
		circleProgressView = UIView()
		circleProgressView.translatesAutoresizingMaskIntoConstraints = false
		buttonsStackView.addArrangedSubview(circleProgressView)

		duration = 30

		let currentUNIXTimestampOffset = Int(ceil(Date().timeIntervalSince1970)) % 30
		duration = 30 - currentUNIXTimestampOffset
		let startingPoint = CGFloat(currentUNIXTimestampOffset / 30)

		let singleAnimation = setupAnimation(withDuration: CGFloat(duration), fromValue: startingPoint, repeatCount: 1)
		singleAnimation.delegate = self
		circleLayer.add(singleAnimation, forKey: nil)
	}

	private func layoutUI() {
		issuersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
		issuersStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

		issuerImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
		issuerImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

		buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
		buttonsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

		circleProgressView.widthAnchor.constraint(equalToConstant: 20).isActive = true
		circleProgressView.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}

	@objc private func didTapCell() { delegate?.azurePinCodeCellDidTapCell(self) }

	@objc private func didTapCopyPinButton() {
 		let pasteboard = UIPasteboard.general
		pasteboard.string = pinLabel.text
		delegate?.azurePinCodeCellShouldFadeInOutToastView()
	}

	@objc private func didTapInfoButton() { delegate?.azurePinCodeCellDidTapInfoButton(self) }

	// ! Timer

 	@objc private func startTimer() {
		Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(regeneratePIN), userInfo: nil, repeats: true)
	}

	@objc private func regeneratePIN() {
		pinLabel.text = ""

		let transition = CATransition()
		transition.type = .fade
		transition.duration = 0.8
		transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		pinLabel.layer.add(transition, forKey: nil)

		pinLabel.text = generator?.generateOTP(for: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))
	}

	private func getLastUNIXTimestamp() -> Int {
		var timestamp = Int(ceil(Date().timeIntervalSince1970))
		if(timestamp % 30 != 0) { timestamp -= timestamp % 30 }
		return timestamp
	} 

 	private func regeneratePINWithoutTransitions() {
		pinLabel.text = ""
		pinLabel.text = generator?.generateOTP(for: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))
	}

	// ! Reusable

	private func setupAnimation(
		withDuration duration: CGFloat,
		fromValue value: CGFloat,
		repeatCount: Float
	) -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.duration = duration
		animation.fromValue = value
		animation.toValue = 1
		animation.repeatCount = repeatCount
		animation.timingFunction = CAMediaTimingFunction(name: .linear)
		animation.isRemovedOnCompletion = false
		return animation
	}

	private func setupButton(withImage image: UIImage, forSelector selector: Selector) -> UIButton {
		let button = UIButton()
		button.tintColor = .label
		button.setImage(image, for: .normal)
		button.addTarget(self, action: selector, for: .touchUpInside)
		buttonsStackView.addArrangedSubview(button)
		return button
	}

	private func setupStackView() -> UIStackView {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 10
		stackView.distribution = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stackView)
		return stackView
	}

}

extension AzurePinCodeCell {

	// ! Public

	func setSecret(_ secret: String, withAlgorithm algorithm: String, allowingForTransition allows: Bool) {
 		let secretData = Data(NSData(base32String: secret))
		generator = TOTPGenerator(secret: secretData, algorithm: algorithm, digits: 6, period: 30)
		if(allows) { regeneratePIN() }
		else { regeneratePINWithoutTransitions() }
	}

}

extension AzurePinCodeCell: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		guard flag else { return }
		let infiniteAnimation = setupAnimation(withDuration: 30, fromValue: 0, repeatCount: .infinity)
		circleLayer.add(infiniteAnimation, forKey: nil)
	}

}
