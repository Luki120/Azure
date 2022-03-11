import UIKit


/*--- https://stackoverflow.com/questions/44886406/ios-animating-a-circle-slice-into-a-wider-one ---*/

@objc public class PieView: UIView {

	private let circleLayer = CAShapeLayer()
	private let π = Double.pi
	private var persistentAnimations:[String: CAAnimation] = [:]
	private var persistentSpeed:Float = 0.0
	private var fromAngle:Double = 0
	private var strokeColor = UIColor.kAzureMintTintColor

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupShapeLayer()
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: Notification.Name("pauseSliceAnimation"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: Notification.Name("resumeSliceAnimation"), object: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	@objc public convenience init(frame:CGRect, fromAngle:Double, strokeColor:UIColor) {
		self.init(frame: frame)
		self.fromAngle = fromAngle
		self.strokeColor = strokeColor
	}

	deinit { NotificationCenter.default.removeObserver(self) }

	override public func layoutSubviews() {

		super.layoutSubviews()

		let startAngle:CGFloat = CGFloat(-0.5 * π)
		let endAngle:CGFloat = CGFloat(1.5 * π)
		let center = CGPoint(x: 12, y: 12)
		let radius:CGFloat = 6
		let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

		circleLayer.path = path.cgPath
		circleLayer.lineWidth = radius * 2

	}

	private func setupShapeLayer() {

		circleLayer.fillColor = UIColor.clear.cgColor
		circleLayer.strokeColor = strokeColor.cgColor
		layer.addSublayer(circleLayer)

	}

	private func setupAnimation(_ animation: CABasicAnimation,
		withDuration: Double,
		fromValue: Double,
		repeatCount: Float
	) {

		animation.duration = withDuration;
		animation.fromValue = fromValue;
		animation.toValue = 1.0;
		animation.repeatCount = repeatCount

	}

	@objc public func animateShapeLayer() {

		let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
		pathAnimation.delegate = self
		setupAnimation(pathAnimation,
			withDuration: 30 - (30 * (fromAngle / 360.0)),
			fromValue: fromAngle / 360.0,
			repeatCount: 1
		)
		circleLayer.add(pathAnimation, forKey: "strokeEndAnimation")

	}

}


extension PieView: CAAnimationDelegate {

	public func animationDidStop(_ anim: CAAnimation, finished isFinished: Bool) {

		guard isFinished else { return }
		let newAnimation = CABasicAnimation(keyPath: "strokeEnd")
		setupAnimation(newAnimation,
			withDuration: 30,
			fromValue: 0.0,
			repeatCount: .infinity
		)
		circleLayer.add(newAnimation, forKey: "newAnimation")

	}

}


private extension UIColor {

	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)

}

// ! Pause/Resume CABasicAnimation
// https://stackoverflow.com/a/43934498

private extension PieView {

	@objc private func willResignActive() {

		persistentSpeed = circleLayer.speed

		circleLayer.speed = 1.0 // in case layer was paused from outside, set speed to 1.0 to get all animations
		persistAnimations(withKeys: circleLayer.animationKeys())
		circleLayer.speed = persistentSpeed // restore original speed
		circleLayer.pauseAnimation()

	}

	@objc private func didBecomeActive() {

		restoreAnimations(withKeys: Array(persistentAnimations.keys))
		self.persistentAnimations.removeAll()
		guard self.persistentSpeed == 1.0 else { return } // if layer was playing before background, resume it
		circleLayer.resumeAnimation()

	}

	private func persistAnimations(withKeys: [String]?) {
		withKeys?.forEach { key in
			guard let animation = circleLayer.animation(forKey: key) else {
				return
			}
			persistentAnimations[key] = animation
		}
	}

	private func restoreAnimations(withKeys: [String]?) {
		withKeys?.forEach { key in
			guard let persistentAnimation = persistentAnimations[key] else {
				return
			}
			circleLayer.add(persistentAnimation, forKey: key)
		}
	}
	
}


private extension CALayer {

	private func isPaused() -> Bool { return self.speed == 0.0 }

	func pauseAnimation() {

		guard !isPaused() else { return }
		let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
		self.speed = 0.0
		self.timeOffset = pausedTime

	}

	func resumeAnimation() {

		let pausedTime: CFTimeInterval = self.timeOffset
		self.speed = 1.0
		self.beginTime = 0.0
		self.timeOffset = 0.0
		let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
		self.beginTime = timeSincePause

	}

}
