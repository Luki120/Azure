#import "AzurePinCodeCell.h"


@interface AzurePinCodeCell () <CAAnimationDelegate>
@end


@implementation AzurePinCodeCell {

	UIStackView *issuersStackView;
	UILabel *pinLabel;
	UIButton *copyPinButton;
	UIButton *infoButton;
	UIStackView *buttonsStackView;
	TOTPGenerator *generator;
	UIView *circleProgressView;
	CAShapeLayer *circleLayer;
	NSInteger duration;
	NSDate *lastActiveTimestamp;

}

// ! Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(!self) return nil;

	// Custom initialization
	[self setupUI];
	[self initializeTimers];

	return self;

}


- (void)layoutSubviews {

	[super layoutSubviews];
	[self layoutUI];

}


- (void)prepareForReuse {

	[super prepareForReuse];
	issuerImageView.image = nil;

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];
	circleLayer.shadowColor = kAzureMintTintColor.CGColor;

}


- (void)initializeTimers {

	NSInteger timestamp = ceil([NSDate.date timeIntervalSince1970]);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 - timestamp % 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[self performSelector:@selector(startTimer) withObject:self afterDelay:30 - timestamp % 30];
		[NSTimer scheduledTimerWithTimeInterval:30 - timestamp % 30 target:self selector:@selector(regeneratePIN) userInfo:nil repeats:NO];

	});

}


- (void)setupUI {

	NSString *pinCode = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self getLastUNIXTimetamp]]];

	issuersStackView = [self setupStackView];
	buttonsStackView = [self setupStackView];

	issuerImageView = [UIImageView new];
	issuerImageView.contentMode = UIViewContentModeScaleAspectFit;
	issuerImageView.clipsToBounds = YES;
	issuerImageView.translatesAutoresizingMaskIntoConstraints = NO;
	[issuersStackView addArrangedSubview: issuerImageView];

	pinLabel = [UILabel new];
	pinLabel.font = [UIFont systemFontOfSize: 18];
	pinLabel.text = pinCode;
	pinLabel.textAlignment = NSTextAlignmentCenter;
	[issuersStackView addArrangedSubview: pinLabel];

	copyPinButton = [self setupButtonWithImage:[UIImage systemImageNamed:@"paperclip"]
		forSelector:@selector(didTapCopyPinButton)
	];
	infoButton = [self setupButtonWithImage:[UIImage systemImageNamed:@"info.circle"]
		forSelector:@selector(didTapInfoButton)
	];

	[buttonsStackView addArrangedSubview: copyPinButton];
	[buttonsStackView addArrangedSubview: infoButton];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell)];
	[self.contentView addGestureRecognizer: tapRecognizer];

	[self setupCircularProgressView];

}


- (void)layoutUI {

	[issuersStackView.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor constant: 15].active = YES;
	[issuersStackView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;

	[issuerImageView.widthAnchor constraintEqualToConstant: 30].active = YES;
	[issuerImageView.heightAnchor constraintEqualToConstant: 30].active = YES;

	[buttonsStackView.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor constant : -15].active = YES;
	[buttonsStackView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;

	[circleProgressView.widthAnchor constraintEqualToConstant: 20].active = YES;
	[circleProgressView.heightAnchor constraintEqualToConstant: 20].active = YES;

}


- (void)didTapCell { [self.delegate azurePinCodeCellDidTapCell: self]; }


- (void)didTapCopyPinButton {

	// no need to delegate this call since the cell is handling the data by itself
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = pinLabel.text;
	[self.delegate azurePinCodeCellShouldFadeInOutToastView];

}


- (void)didTapInfoButton { [self.delegate azurePinCodeCellDidTapInfoButton: self]; }

// ! NSTimer

- (void)regeneratePIN {

	pinLabel.text = @"";

	CATransition *transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.duration = 0.8f;
	transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	[pinLabel.layer addAnimation:transition forKey:nil];

	pinLabel.text = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self getLastUNIXTimetamp]]];

}


- (void)startTimer {

	[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(regeneratePIN) userInfo:nil repeats:YES];

}


// ! Pin code generation logic

- (NSInteger)getLastUNIXTimetamp {

	NSInteger timestamp = ceil([NSDate.date timeIntervalSince1970]);
	if(timestamp % 30 != 0) timestamp -= timestamp % 30;
	return timestamp;

}


- (void)setSecret:(NSString *)secret withAlgorithm:(NSString *)algorithm allowingForTransition:(BOOL)allowed {

	NSData *secretData = [NSData dataWithBase32String: secret];
	generator = [[TOTPGenerator alloc] initWithSecret:secretData algorithm:algorithm digits:6 period:30];
	if(allowed) [self regeneratePIN];
	else [self regeneratePINWithoutTransitions];

}


- (void)regeneratePINWithoutTransitions {

	pinLabel.text = @"";
	pinLabel.text = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self getLastUNIXTimetamp]]];

}

// ! Circular progress view

- (void)setupCircularProgressView {

	circleProgressView = [UIView new];
	circleProgressView.translatesAutoresizingMaskIntoConstraints = NO;
	[buttonsStackView addArrangedSubview: circleProgressView];

	circleLayer = [CAShapeLayer layer];
	circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(10, 10) radius:10 startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
	circleLayer.lineCap = kCALineCapRound;
	circleLayer.lineWidth = 5;
	circleLayer.fillColor = UIColor.clearColor.CGColor;
	circleLayer.strokeColor = kAzureMintTintColor.CGColor;
	circleLayer.shadowColor = kAzureMintTintColor.CGColor;
	circleLayer.shadowRadius = 5;
	circleLayer.shadowOffset = CGSizeMake(1, 1);
	circleLayer.shadowOpacity = 0.8;
	[circleProgressView.layer addSublayer: circleLayer];

	duration = 30;

	NSInteger currentUNIXTimestampOffset = (int)(ceil([NSDate.date timeIntervalSince1970])) % 30;
	duration = 30 - currentUNIXTimestampOffset;
	CGFloat startingPoint = currentUNIXTimestampOffset / 30.0;

	CABasicAnimation *singleAnimation = [self setupAnimationWithDuration:duration
		fromValue:[NSNumber numberWithFloat: startingPoint]
		repeatCount:1
	];

	singleAnimation.delegate = self;
	[circleLayer addAnimation:singleAnimation forKey: nil];

}

// ! Reusable funcs

- (CABasicAnimation *)setupAnimationWithDuration:(CGFloat)animDuration
	fromValue:(NSNumber *)value
	repeatCount:(CGFloat)repeatCount {

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
	animation.duration = animDuration;
	animation.fromValue = value;
	animation.toValue = @1;
	animation.repeatCount = repeatCount;
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.removedOnCompletion = NO;
	return animation;

}

- (UIButton *)setupButtonWithImage:(UIImage *)image forSelector:(SEL)selector {

	UIButton *button = [UIButton new];
	button.tintColor = UIColor.labelColor;
	[button setImage:image forState: UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents: UIControlEventTouchUpInside];
	return button;

}


- (UIStackView *)setupStackView {

	UIStackView *stackView = [UIStackView new];
	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.spacing = 10;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview: stackView];
	return stackView;

}

// ! CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {

	if(!finished) return;
	CABasicAnimation *infiniteAnimation = [self setupAnimationWithDuration:30
		fromValue:@0
		repeatCount:HUGE_VALF
	];
	[circleLayer addAnimation:infiniteAnimation forKey: nil];

}

@end
