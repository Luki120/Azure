import UIKit

/// Class to represent the issuer cell
final class IssuerCell: UICollectionViewCell {

	static let identifier = "IssuerCell"

	var pinCodeText: String { pinCodeLabel.text ?? "" }
	var secret: String { return .base32EncodedString(viewModel.secret) }

	private var isTinyDevice: Bool {
		if UIScreen.main.nativeBounds.size.height <= 1334 { return true }
		else { return false }
	}

	private var clearContentView, darkContentView, circleProgressView: UIView!
	private var viewModel: IssuerCellViewModel!

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
		label.numberOfLines = 2
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

	private var progress: CGFloat = 0 {
		didSet {
			circleLayer.strokeEnd = min(max(progress, 0), 1)
		}
	}

	private lazy var circleLayer: CAShapeLayer = {
		let axisValue: Double = isTinyDevice ? 40 : 50
		let x: Double = axisValue / 2
		let y: Double = axisValue / 2
		let π: Double = .pi

		let radius = max(x, y)

		let path = CGMutablePath()
		path.move(to: .init(x: x, y: y - radius / 2))
		path.addArc(center: .init(x: x, y: y), radius: radius / 2, startAngle: -π / 2, endAngle: 3 * π / 2, clockwise: false)

		let layer = CAShapeLayer()
		layer.path = path
		layer.lineCap = .round
		layer.lineWidth = isTinyDevice ? 6.5 : 8
		layer.fillColor = UIColor.clear.cgColor
		layer.strokeEnd = progress
		layer.shadowRadius = isTinyDevice ? 6.5 : 8
		layer.shadowOffset = .init(width: 1, height: 1)
		layer.shadowOpacity = 0.8
		circleProgressView.layer.addSublayer(layer)
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
		layoutUI()

		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 14
		contentView.layer.masksToBounds = true
		setupCleanShadowLayer()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		issuerImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		darkContentView.backgroundColor = kUserInterfaceStyle == .dark ? .darkColor : .lightColor

		layer.backgroundColor = kUserInterfaceStyle == .dark ? .darkBackgroundColor : .lightBackgroundColor
		layer.shadowColor = kUserInterfaceStyle == .dark ? .darkShadowColor : .lightShadowColor
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
		Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCircleProgress), userInfo: nil, repeats: true)
	}

	private func setupFormattedPinCodeText() -> String {
		var pinText = viewModel.generateOTP()
		pinText.insert(" ", at: pinText.index(pinText.startIndex, offsetBy: 3))

		return pinText
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

		updateCircleProgress()

		contentView.addSubviews(clearContentView, darkContentView, circleProgressView)
	}

	private func layoutUI() {
		let constant: CGFloat = isTinyDevice ? 20 : 25

		NSLayoutConstraint.activate([
			clearContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
			clearContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			clearContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			clearContentView.trailingAnchor.constraint(equalTo: circleProgressView.leadingAnchor, constant: constant),

			circleProgressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 30),
			circleProgressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			darkContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
			darkContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			darkContentView.leadingAnchor.constraint(equalTo: circleProgressView.trailingAnchor, constant: -constant),
			darkContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			issuerImageView.leadingAnchor.constraint(equalTo: clearContentView.leadingAnchor, constant: 15),
			issuerImageView.centerYAnchor.constraint(equalTo: clearContentView.centerYAnchor),

			issuerLabel.leadingAnchor.constraint(equalTo: issuerImageView.trailingAnchor, constant: 15),
			issuerLabel.trailingAnchor.constraint(equalTo: circleProgressView.leadingAnchor, constant: -5),
			issuerLabel.centerYAnchor.constraint(equalTo: issuerImageView.centerYAnchor),

			pinCodeLabel.centerYAnchor.constraint(equalTo: circleProgressView.centerYAnchor),
			pinCodeLabel.leadingAnchor.constraint(equalTo: circleProgressView.trailingAnchor, constant: 15),
			pinCodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
		])

		setupSizeConstraints(forView: circleProgressView, width: isTinyDevice ? 40 : 50, height: isTinyDevice ? 40 : 50)
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

	@objc private func updateCircleProgress() {
		progress = getProgress()

		circleLayer.shadowColor = timeIntervalRemaining() <= 5 ? UIColor.systemRed.cgColor : UIColor.kAzureMintTintColor.cgColor
		circleLayer.strokeColor = timeIntervalRemaining() <= 5 ? UIColor.systemRed.cgColor : UIColor.kAzureMintTintColor.cgColor

		func getProgress() -> Double {
			return timeIntervalRemaining() / Double(30)
		}

		func timeIntervalRemaining() -> Double {
			let period = Double(30)
			return period - (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 30))
		}
	}

}

extension IssuerCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: IssuerCellViewModel) {
		self.viewModel = viewModel

		issuerLabel.attributedText = NSMutableAttributedString(
			fullString: "\(viewModel.name)\n\(viewModel.account)",
			subString: "\(viewModel.account)"
		)

		issuerImageView.image = viewModel.image
		issuerImageView.tintColor = .kAzureMintTintColor

		pinCodeLabel.text = ""
		pinCodeLabel.text = setupFormattedPinCodeText()
	}

}
