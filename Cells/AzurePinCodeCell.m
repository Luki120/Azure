#import "AzurePinCodeCell.h"


@implementation AzurePinCodeCell {

	UILabel *pinLabel;
	UIButton *infoButton;
	UIButton *copyPinButton;
	UIView *circleProgressView;
	CAShapeLayer *circleLayer;
	UILabel *progressLabel;
	NSInteger duration;
	UIStackView *buttonsStackView;
	TOTPGenerator *generator;
	NSDate *fireDate;
	NSTimer *progressLabelTimer;

}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {	

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if(self) {

		// Custom initialization

		[self setupUI];

		NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 - timestamp % 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

			[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(regeneratePIN) userInfo:nil repeats:YES];
			progressLabelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressLabel) userInfo:nil repeats:YES];

		});

		[NSNotificationCenter.defaultCenter removeObserver:self];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(cacheTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resumeTimer) name:UIApplicationDidBecomeActiveNotification object:nil];

	}

	return self;

}


- (void)layoutSubviews {

	[super layoutSubviews];

	[self layoutUI];

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];

	circleLayer.strokeColor = UIColor.labelColor.CGColor;

}


- (NSInteger)generateTimestamp {

	NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);

	if(timestamp % 30 != 0) timestamp -= timestamp % 30;

	return timestamp;

}


- (void)setSecret:(NSString *)secret {

	NSData *secretData = [NSData dataWithBase32String: secret];

	generator = [[TOTPGenerator alloc] initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:6 period:30];

	[self regeneratePIN];

}


- (void)setupUI {

	NSString *pinCode = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self generateTimestamp]]];

	pinLabel = [UILabel new];
	pinLabel.font = [UIFont systemFontOfSize: 18];
	pinLabel.text = pinCode;
	pinLabel.textAlignment = NSTextAlignmentCenter;
	pinLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview: pinLabel];

	buttonsStackView = [UIStackView new];
	buttonsStackView.axis = UILayoutConstraintAxisHorizontal;
	buttonsStackView.spacing = 10;
	buttonsStackView.distribution = UIStackViewDistributionFill;
	buttonsStackView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview: buttonsStackView];

	infoButton = [UIButton new];
	infoButton.tintColor = UIColor.labelColor;
	[infoButton setImage: [UIImage systemImageNamed:@"info.circle"] forState: UIControlStateNormal];
	[infoButton addTarget: self action:@selector(didTapButton) forControlEvents: UIControlEventTouchUpInside];
	[buttonsStackView addArrangedSubview: infoButton];

	copyPinButton = [UIButton new];
	copyPinButton.tintColor = UIColor.labelColor;
	[copyPinButton setImage: [UIImage systemImageNamed:@"paperclip"] forState: UIControlStateNormal];
	[copyPinButton addTarget: self action:@selector(didTapCopyPinButton) forControlEvents: UIControlEventTouchUpInside];
	[buttonsStackView addArrangedSubview: copyPinButton];

	circleProgressView = [UIView new];
	circleProgressView.translatesAutoresizingMaskIntoConstraints = NO;
	[buttonsStackView addArrangedSubview: circleProgressView];

	circleLayer = [CAShapeLayer layer];
	circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15, 15) radius:15 startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
	circleLayer.lineCap = kCALineCapRound;
	circleLayer.lineWidth = 4;
	circleLayer.fillColor = UIColor.clearColor.CGColor;
	circleLayer.strokeColor = UIColor.labelColor.CGColor;

	duration = 30;

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
	animation.duration = duration;
	animation.fromValue = @(0);
	animation.toValue = @(1);
	animation.repeatCount = HUGE_VALF;
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.removedOnCompletion = NO;
	[circleLayer addAnimation: animation forKey: @"drawCircleAnimation"];

	[circleProgressView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[circleProgressView.layer addSublayer: circleLayer];

	progressLabel = [UILabel new];
	progressLabel.font = [UIFont systemFontOfSize: 10];
	progressLabel.text = [NSString stringWithFormat: @"%ld", duration];
	progressLabel.textColor = UIColor.labelColor;
	progressLabel.textAlignment = NSTextAlignmentCenter;
	progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[circleProgressView addSubview: progressLabel];

}


- (void)layoutUI {

	[pinLabel.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor constant : 15].active = YES;
	[pinLabel.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;

	[buttonsStackView.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor constant : - 15].active = YES;
	[buttonsStackView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;

	[circleProgressView.widthAnchor constraintEqualToConstant: 30].active = YES;
	[circleProgressView.heightAnchor constraintEqualToConstant: 30].active = YES;

	[progressLabel.centerXAnchor constraintEqualToAnchor: circleProgressView.centerXAnchor].active = YES;
	[progressLabel.centerYAnchor constraintEqualToAnchor: circleProgressView.centerYAnchor].active = YES;

}


- (void)didTapButton {

	[self.delegate didTapInfoButton: self];

}


- (void)didTapCopyPinButton {

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = pinLabel.text;

	[NSNotificationCenter.defaultCenter postNotificationName: @"fadeInOutToastDone" object: nil];

}


// MARK: NSNotificationCenter

- (void)cacheTimer {

	fireDate = progressLabelTimer.fireDate;
	[NSUserDefaults.standardUserDefaults setObject: fireDate forKey: @"firingDate"];

}


 - (void)resumeTimer {

	NSDate *now = [NSDate date];

	fireDate = [NSUserDefaults.standardUserDefaults objectForKey: @"firingDate"];

	if([now compare: fireDate] == NSOrderedDescending) {

		NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (30 - timestamp % 30) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

			[progressLabelTimer invalidate];
			progressLabelTimer = nil;

			progressLabelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressLabel) userInfo:nil repeats:YES];

		});

	}

}


// MARK: NSTimer

- (void)regeneratePIN {

	pinLabel.text = @"";
	pinLabel.text = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self generateTimestamp]]];

}


- (void)updateProgressLabel {

	duration--;

	progressLabel.text = [NSString stringWithFormat: @"%ld", duration];

	if(duration == 0) duration = 30;

}


@end
