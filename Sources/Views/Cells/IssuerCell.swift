import UIKit

/// Class to represent the issuer cell
final class IssuerCell: UICollectionViewCell {

	static let identifier = "IssuerCell"

	var pinCodeText: String { pinCodeLabel.text ?? "" }
	var secret: String { return .base32EncodedString(issuer.secret) }

	private var issuer: Issuer!

	private var isTinyDevice: Bool {
		if UIScreen.main.nativeBounds.size.height <= 1334 { return true }
		else { return false }
	}
	private var kUserInterfaceStyle: UIUserInterfaceStyle { return traitCollection.userInterfaceStyle }

	private var clearContentView, darkContentView, circleProgressView: UIView!

	private lazy var issuerImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 8
		clearContentView.addSubview(imageView)
		return imageView
	}()

	private lazy var issuerLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		clearContentView.addSubview(label)
		return label
	}()

	private lazy var pinCodeLabel: UILabel = {
		let label = UILabel()
		label.font = .monospacedSystemFont(ofSize: 20, weight: .medium)
		label.numberOfLines = 1
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		darkContentView.addSubview(label)
		return label
	}()

	private lazy var circleLayer: CAShapeLayer = {
		let π: Double = .pi
		let axisValue: Double = isTinyDevice ? 12.5 : 15

		let layer = CAShapeLayer()
		layer.path = UIBezierPath(arcCenter: .init(x: axisValue, y: axisValue), radius: isTinyDevice ? 12.5 : 15, startAngle: -0.5 * π, endAngle: 1.5 * π, clockwise: true).cgPath
		layer.lineCap = .round
		layer.lineWidth = isTinyDevice ? 6.25 : 7.5
		layer.fillColor = UIColor.clear.cgColor
		layer.strokeColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowColor = UIColor.kAzureMintTintColor.cgColor
		layer.shadowRadius = isTinyDevice ? 6.25 : 7.5
		layer.shadowOffset = .init(width: 1, height: 1)
		layer.shadowOpacity = 0.8
		circleProgressView.layer.addSublayer(layer)
		return layer
	}()

	private lazy var cleanShadowLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.cornerCurve = .continuous
		layer.cornerRadius = 14
		layer.backgroundColor = kUserInterfaceStyle == .dark ? .darkBackgroundColor : .lightBackgroundColor
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 14).cgPath
		layer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowOpacity = 1
		layer.shadowRadius = 3.5
		return layer
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		initializeTimers()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		layer.masksToBounds = false
		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 14
		contentView.layer.masksToBounds = true

		layoutUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		issuerImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		darkContentView.backgroundColor = kUserInterfaceStyle == .dark ? .darkColor : .lightColor

		cleanShadowLayer.backgroundColor = kUserInterfaceStyle == .dark ? .darkBackgroundColor : .lightBackgroundColor
		cleanShadowLayer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor
	}	

	override func dragStateDidChange(_ dragState: UICollectionViewCell.DragState) {
		super.dragStateDidChange(dragState)

		switch dragState {
			case .lifting, .dragging: layer.opacity = 0
			case .none: layer.opacity = 1
			@unknown default: layer.opacity = 1
		}
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
		clearContentView = UIView()
		clearContentView.backgroundColor = .tertiarySystemBackground

		circleProgressView = UIView()

		darkContentView = UIView()
		darkContentView.backgroundColor = kUserInterfaceStyle == .dark ? .darkColor : .lightColor

		[clearContentView, circleProgressView, darkContentView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		setupAnimation()

		contentView.addSubviews(clearContentView, darkContentView, circleProgressView)
		layer.insertSublayer(cleanShadowLayer, at: 0)
	}

	private func setupAnimation() {
		let currentUNIXTimestampOffset = Int(Date().timeIntervalSince1970) % 30
		let duration = TimeInterval(30 - currentUNIXTimestampOffset)
		let startingPoint = CGFloat(currentUNIXTimestampOffset) / 30.0

		let singleAnimation = setupAnimation(withDuration: duration, fromValue: startingPoint, repeatCount: 1)
		singleAnimation.delegate = self
		circleLayer.add(singleAnimation, forKey: nil)
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			clearContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
			clearContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			clearContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			clearContentView.trailingAnchor.constraint(equalTo: circleProgressView.leadingAnchor, constant: 15),

			circleProgressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 30),
			circleProgressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			darkContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
			darkContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			darkContentView.leadingAnchor.constraint(equalTo: circleProgressView.trailingAnchor, constant: -15),
			darkContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			issuerImageView.leadingAnchor.constraint(equalTo: clearContentView.leadingAnchor, constant: 15),
			issuerImageView.centerYAnchor.constraint(equalTo: clearContentView.centerYAnchor),

			issuerLabel.leadingAnchor.constraint(equalTo: issuerImageView.trailingAnchor, constant: 15),
			issuerLabel.centerYAnchor.constraint(equalTo: issuerImageView.centerYAnchor),

			pinCodeLabel.centerYAnchor.constraint(equalTo: circleProgressView.centerYAnchor),
			pinCodeLabel.leadingAnchor.constraint(equalTo: circleProgressView.trailingAnchor, constant: 15),
			pinCodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
		])

		setupSizeConstraints(forView: circleProgressView, width: isTinyDevice ? 25 : 30, height: isTinyDevice ? 25 : 30)
		setupSizeConstraints(forView: issuerImageView, width: 40, height: 40)
	}

	// ! Timer

	@objc private func startTimer() {
		Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(regeneratePIN), userInfo: nil, repeats: true)
	}

	@objc private func regeneratePIN() {
		pinCodeLabel.text = ""

		let transition = CATransition()
		transition.type = .fade
		transition.duration = 0.8
		transition.timingFunction = .init(name: .easeInEaseOut)
		pinCodeLabel.layer.add(transition, forKey: nil)

		pinCodeLabel.text = setupFormattedPinCodeText()
	}

	private func regeneratePINWithoutTransition() {
		pinCodeLabel.text = ""
		pinCodeLabel.text = setupFormattedPinCodeText()
	}

	private func getLastUNIXTimestamp() -> Double {
		let timestamp = Int(Date().timeIntervalSince1970)
		return Double(timestamp - timestamp % 30)
	}

	private func setupFormattedPinCodeText() -> String {
		var pinText = issuer.generateOTP(forDate: .init(timeIntervalSince1970: getLastUNIXTimestamp()))
		pinText.insert(" ", at: pinText.index(pinText.startIndex, offsetBy: 3))

		return pinText
	}

	// ! Reusable

	private func setupAnimation(
		withDuration duration: TimeInterval,
		fromValue value: CGFloat,
		repeatCount: Float
	) -> CAAnimationGroup {

		let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
		strokeEndAnimation.fromValue = value
		strokeEndAnimation.toValue = 1

		let strokeColorAnimation = setupColorAnimation(withKeyPath: #keyPath(CAShapeLayer.strokeColor))
		let shadowColorAnimation = setupColorAnimation(withKeyPath: #keyPath(CAShapeLayer.shadowColor))

		let progressAndColorAnimation = CAAnimationGroup()
		progressAndColorAnimation.duration = duration
		progressAndColorAnimation.animations = [strokeEndAnimation, strokeColorAnimation, shadowColorAnimation]
		progressAndColorAnimation.repeatCount = repeatCount
		progressAndColorAnimation.timingFunction = .init(name: .linear)
		progressAndColorAnimation.isRemovedOnCompletion = false
		circleLayer.add(progressAndColorAnimation, forKey: nil)

		return progressAndColorAnimation
	}

	private func setupColorAnimation(withKeyPath keyPath: String) -> CABasicAnimation {
		let currentUNIXTimestampOffset = Int(Date().timeIntervalSince1970) % 30
		let duration = TimeInterval(30 - currentUNIXTimestampOffset)

		let animation = CABasicAnimation()
		animation.keyPath = keyPath
		animation.fromValue = UIColor.kAzureMintTintColor
		animation.toValue = UIColor.systemRed.cgColor
		animation.fillMode = .forwards
		animation.duration = 0.5
		animation.beginTime = duration * 0.75
		return animation
	}

}

extension IssuerCell {

	// ! Public

	/// Function to configure the cell with its respective model
	/// - Parameters:
	/// 	- with: The cell's model
	func configure(with issuer: Issuer) {
		self.issuer = issuer

		issuerLabel.attributedText = NSMutableAttributedString(
			fullString: "\(issuer.name)\nLuki",
			subString: "Luki"
		)

		let image = IssuerManager.sharedInstance.imagesDict[issuer.name.lowercased()]
		let placeholderImage = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)

		issuerImageView.image = image != nil ? image : placeholderImage
		issuerImageView.tintColor = image != nil ? nil : .kAzureMintTintColor

		regeneratePINWithoutTransition()
	}

}

// ! CAAnimationDelegate

extension IssuerCell: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished: Bool) {
		guard finished else { return }
		let infiniteAnimation = setupAnimation(withDuration: 30, fromValue: 0, repeatCount: .infinity)
		circleLayer.add(infiniteAnimation, forKey: nil)
	}

}
