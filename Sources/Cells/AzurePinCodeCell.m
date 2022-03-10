#import "AzurePinCodeCell.h"


@implementation AzurePinCodeCell {

	UIStackView *issuersStackView;
	UILabel *pinLabel;
	UIButton *copyPinButton;
	UIButton *infoButton;
	PieView *pieView;
	UIStackView *buttonsStackView;
	TOTPGenerator *generator;

}

// ! Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if(!self) return nil;

	// Custom initialization
	[self setupUI];

	NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 - timestamp % 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[pieView animateShapeLayer];
		[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(regeneratePIN) userInfo:nil repeats:YES];

	});

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


- (void)setupUI {

	NSString *pinCode = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self getLastUNIXTimetamp]]];

	issuersStackView = [UIStackView new];
	[self createStackViewWithStackView: issuersStackView];
	[self.contentView addSubview: issuersStackView];

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

	buttonsStackView = [UIStackView new];
	[self createStackViewWithStackView: buttonsStackView];
	[self.contentView addSubview: buttonsStackView];

	copyPinButton = [UIButton new];
	infoButton = [UIButton new];
	[self createButtonWithButton:copyPinButton
		withImage:[UIImage systemImageNamed: @"paperclip"]
		forSelector:@selector(didTapCopyPinButton)
	];
	[buttonsStackView addArrangedSubview: copyPinButton];
	[self createButtonWithButton:infoButton
		withImage:[UIImage systemImageNamed: @"info.circle"]
		forSelector:@selector(didTapButton)
	];

	[buttonsStackView addArrangedSubview: infoButton];

	NSInteger currentUNIXTimestamp = ceil((long)[NSDate.date timeIntervalSince1970]);
	CGFloat startingSliceAngle = ((currentUNIXTimestamp - [self getLastUNIXTimetamp]) * 360.0) / 30.0;

	pieView = [[PieView alloc] initWithFrame:CGRectMake(0,0,12,12) fromAngle: -startingSliceAngle toAngle: 360 - startingSliceAngle strokeColor: kAzureMintTintColor];
	[buttonsStackView addArrangedSubview: pieView];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell)];
	[self.contentView addGestureRecognizer: tapRecognizer];

}


- (void)layoutUI {

	[issuersStackView.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor constant: 15].active = YES;
	[issuersStackView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;

	[issuerImageView.widthAnchor constraintEqualToConstant: 30].active = YES;
	[issuerImageView.heightAnchor constraintEqualToConstant: 30].active = YES;

	[buttonsStackView.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor constant : - 15].active = YES;
	[buttonsStackView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = YES;
	[buttonsStackView.widthAnchor constraintEqualToConstant: 80].active = YES;

}


- (void)didTapCopyPinButton {

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = pinLabel.text;
	[NSNotificationCenter.defaultCenter postNotificationName:@"fadeInOutCopyPinToast" object:nil];

}


- (void)didTapCell {

	[self.delegate didTapCell: self];

}


- (void)didTapButton {

	[self.delegate didTapInfoButton: self];

}

// ! NSTimer

- (void)regeneratePIN {

	pinLabel.text = @"";

	CATransition *transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.duration = 0.8f;
	transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	[pinLabel.layer addAnimation: transition forKey: nil];

	pinLabel.text = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self getLastUNIXTimetamp]]];

}

// ! Pin code generation logic

- (NSInteger)getLastUNIXTimetamp {

	NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);
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

// ! Reusable funcs

- (void)createStackViewWithStackView:(UIStackView *)stackView {

	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.spacing = 10;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void)createButtonWithButton:(UIButton *)button withImage:(UIImage *)image forSelector:(SEL)selector {

	button.tintColor = UIColor.labelColor;
	[button setImage: image forState: UIControlStateNormal];
	[button addTarget: self action:selector forControlEvents: UIControlEventTouchUpInside];

}

@end
