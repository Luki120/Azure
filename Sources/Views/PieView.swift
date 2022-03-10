import UIKit


/*--- https://stackoverflow.com/questions/44886406/ios-animating-a-circle-slice-into-a-wider-one ---*/

@objc public class PieView: UIView {

	private let circleLayer = CAShapeLayer()
	private let π = Double.pi

	private var fromAngle:Double = 0
	private var strokeColor = UIColor.kAzureMintTintColor

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupShapeLayer()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	@objc public convenience init(frame:CGRect, fromAngle:Double, strokeColor:UIColor) {
		self.init(frame: frame)
		self.fromAngle = fromAngle
		self.strokeColor = strokeColor
	}

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

	@objc public func animateShapeLayer() {

        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.delegate = self
        setupAnimation(pathAnimation,
            withDuration: 30 - (30 * (fromAngle / 360.0)),
            fromValue: fromAngle / 360.0,
            repeatCount: 1,
            removedOnCompletion: true
        )
        circleLayer.add(pathAnimation, forKey: "strokeEndAnimation")

    }

	private func setupAnimation(_ animation: CABasicAnimation,
        withDuration: Double,
        fromValue: Double,
        repeatCount: Float,
        removedOnCompletion: Bool
    ) {

        animation.duration = withDuration;
        animation.fromValue = fromValue;
        animation.toValue = 1.0;
        animation.repeatCount = repeatCount
        animation.isRemovedOnCompletion = removedOnCompletion

    }

}


extension PieView: CAAnimationDelegate {

    public func animationDidStop(_ anim: CAAnimation, finished isFinished: Bool) {

        guard isFinished else { return }
        let newAnimation = CABasicAnimation(keyPath: "strokeEnd")
        setupAnimation(newAnimation,
            withDuration: 30,
            fromValue: 0.0,
            repeatCount: .infinity,
            removedOnCompletion: false
        )
        circleLayer.add(newAnimation, forKey: "newAnimation")

    }

}

private extension UIColor {

	static let kAzureMintTintColor = UIColor(red: 0.40, green: 0.81, blue: 0.73, alpha: 1.0)

}
