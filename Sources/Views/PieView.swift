import UIKit


/*--- https://stackoverflow.com/questions/44886406/ios-animating-a-circle-slice-into-a-wider-one ---*/

@objc public class PieView: UIView {

	private let circleLayer = CAShapeLayer()

	private var fromAngle:CGFloat = 0
	private var toAngle:CGFloat = 0
	private var strokeColor = UIColor.systemTeal

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupShapeLayer()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	@objc public convenience init(frame:CGRect, fromAngle:CGFloat, toAngle:CGFloat, strokeColor:UIColor) {
		self.init(frame: frame)
		self.fromAngle = fromAngle
		self.toAngle = toAngle
		self.strokeColor = strokeColor
	}

	override public func layoutSubviews() {

		super.layoutSubviews()

		let startAngle:CGFloat = fromAngle.toRadians()
		let endAngle:CGFloat = toAngle.toRadians()
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
		pathAnimation.duration = 30;
		pathAnimation.fromValue = 0.0;
		pathAnimation.toValue = 1.0;
		pathAnimation.repeatCount = .infinity
		pathAnimation.isRemovedOnCompletion = false

		circleLayer.add(pathAnimation, forKey: "strokeEndAnimation")

	}

}


private extension CGFloat {

	func toRadians() -> CGFloat {

		return self * CGFloat(Double.pi) / 180.0

	}

}
