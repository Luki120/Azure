import UIKit


protocol IssuerCellDelegate: AnyObject {
	func issuerCellDidTapCell(_ cell: IssuerCell)
	func issuerCellDidTapInfoButton(_ cell: IssuerCell)
	func issuerCellShouldFadeInOutToastView()
}

/// Class to represent the issuer cell
final class IssuerCell: UITableViewCell {

	static let identifier = "IssuerCell"

	private var issuer: Issuer?
	private var copyPinButton, infoButton: UIButton!
	private var issuersStackView, buttonsStackView: UIStackView!
	private var circleProgressView: UIView!
	private var duration = 30

	private let π = Double.pi

	private(set) var name = ""
	private(set) var secret = ""

	weak var delegate: IssuerCellDelegate?

	let issuerImageView: UIImageView = {
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
		layer.path = UIBezierPath(arcCenter: .init(x: 10, y: 10), radius: 10, startAngle: -0.5 * π, endAngle: 1.5 * π, clockwise: true).cgPath
		layer.lineCap = .round
		layer.lineWidth = 5
		layer.fillColor = UIColor.clear.cgColor
		layer.strokeColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowRadius = 5
		layer.shadowOffset = .init(width: 1, height: 1)
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
		DispatchQueue.main.async {
			self.perform(#selector(self.startTimer), with: self, afterDelay: delay)
			Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.regeneratePIN), userInfo: nil, repeats: false)
		}
	}

	private func setupUI() {
		pinLabel.text = issuer?.generateOTP(forDate: .init(timeIntervalSince1970: getLastUNIXTimestamp()))

		issuersStackView = setupStackView()
		issuersStackView.addArrangedSubviews(issuerImageView, pinLabel)

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
		buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
		buttonsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

		setupSizeConstraints(forView: issuerImageView, width: 30, height: 30)
		setupSizeConstraints(forView: circleProgressView, width: 20, height: 20)
	}

	private func getLastUNIXTimestamp() -> Double {
		let timestamp = Int(Date().timeIntervalSince1970)
		return Double(timestamp - timestamp % 30)
	} 

	private func regeneratePINWithoutTransition() {
		pinLabel.text = ""
		pinLabel.text = issuer?.generateOTP(forDate: .init(timeIntervalSince1970: getLastUNIXTimestamp()))
	}

	@objc private func didTapCell() { delegate?.issuerCellDidTapCell(self) }

	@objc private func didTapCopyPinButton() {
		UIPasteboard.general.string = pinLabel.text
		delegate?.issuerCellShouldFadeInOutToastView()
	}

	@objc private func didTapInfoButton() { delegate?.issuerCellDidTapInfoButton(self) }

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

		pinLabel.text = issuer?.generateOTP(forDate: .init(timeIntervalSince1970: getLastUNIXTimestamp()))
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
		animation.timingFunction = .init(name: .linear)
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

extension IssuerCell {

	// ! Public

	/// Function to set the issuer for the cell
	/// - Parameters:
	///		- withName: A string representing the issuer's name
	///		- secret: The secret hash
	///		- algorithm: The algorithm type
	func setIssuer(withName name: String, secret: Data, algorithm: Issuer.Algorithm) {
		self.name = name
		self.secret = .base32EncodedString(secret)
		issuer = .init(name: name, secret: secret, algorithm: algorithm)

		regeneratePINWithoutTransition()
	}

}

// ! CAAnimationDelegate

extension IssuerCell: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		guard flag else { return }
		let infiniteAnimation = setupAnimation(withDuration: 30, fromValue: 0, repeatCount: .infinity)
		circleLayer.add(infiniteAnimation, forKey: nil)
	}

}
