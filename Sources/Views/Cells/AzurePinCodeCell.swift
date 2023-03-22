import UIKit


protocol AzurePinCodeCellDelegate: AnyObject {
	func azurePinCodeCellDidTapCell(_ cell: AzurePinCodeCell)
	func azurePinCodeCellDidTapInfoButton(_ cell: AzurePinCodeCell)
	func azurePinCodeCellShouldFadeInOutToastView()
}

final class AzurePinCodeCell: UITableViewCell {

	static let identifier = "AzurePinCodeCell"

	private var issuer: Issuer?
	private var copyPinButton, infoButton: UIButton!
	private var issuersStackView, buttonsStackView: UIStackView!
	private var circleProgressView: UIView!
	private var duration = 30

	private let π = Double.pi

	private(set) var name = ""
	private(set) var secret = ""

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

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
		initializeTimers()
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

	// ! Private

	private func initializeTimers() {
		let delay = TimeInterval(30 - Int(Date().timeIntervalSince1970) % 30)
		DispatchQueue.main.async() {
			self.perform(#selector(self.startTimer), with: self, afterDelay: delay)
			Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.regeneratePIN), userInfo: nil, repeats: false)
		}
	}

	private func setupUI() {
		pinLabel.text = issuer?.generateOTP(forDate: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))

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

		let currentUNIXTimestampOffset = Int(Date().timeIntervalSince1970) % 30
		let duration = TimeInterval(30 - currentUNIXTimestampOffset)
		let startingPoint = CGFloat(currentUNIXTimestampOffset) / 30.0

		let singleAnimation = setupAnimation(withDuration: duration, fromValue: startingPoint, repeatCount: 1)
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
		transition.timingFunction = .init(name: .easeInEaseOut)
		pinLabel.layer.add(transition, forKey: nil)

		pinLabel.text = issuer?.generateOTP(forDate: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))
	}

	private func getLastUNIXTimestamp() -> Int {
		let timestamp = Int(Date().timeIntervalSince1970)
		return timestamp - timestamp % 30
	} 

	private func regeneratePINWithoutTransitions() {
		pinLabel.text = ""
		pinLabel.text = issuer?.generateOTP(forDate: Date(timeIntervalSince1970: Double(getLastUNIXTimestamp())))
	}

	// ! Reusable

	private func setupAnimation(
		withDuration duration: TimeInterval,
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
		stackView.spacing = 10
		stackView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stackView)
		return stackView
	}

}

extension AzurePinCodeCell {

	// ! Public

	func setIssuer(withName name: String, secret: Data, algorithm: Issuer.Algorithm, withTransition transition: Bool) {
		self.name = name
		self.secret = .base32EncodedString(secret)
		issuer = Issuer(name: name, secret: secret, algorithm: algorithm)

		if(transition) { regeneratePIN() }
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
