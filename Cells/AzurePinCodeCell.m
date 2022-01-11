#import "AzurePinCodeCell.h"


@implementation AzurePinCodeCell {

	UIStackView *issuersStackView;
	UILabel *pinLabel;
	UIButton *infoButton;
	UIButton *copyPinButton;
	PieView *pieView;
	UIStackView *buttonsStackView;
	TOTPGenerator *generator;

}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if(self) {

		// Custom initialization

		[self setupUI];

		NSInteger timestamp = ceil((long)[NSDate.date timeIntervalSince1970]);

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 - timestamp % 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

			[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(regeneratePIN) userInfo:nil repeats:YES];

		});

	}

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

	issuersStackView = [UIStackView new];
	issuersStackView.axis = UILayoutConstraintAxisHorizontal;
	issuersStackView.spacing = 10;
	issuersStackView.distribution = UIStackViewDistributionFill;
	issuersStackView.translatesAutoresizingMaskIntoConstraints = NO;
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

	pieView = [[PieView alloc] initWithFrame: CGRectMake(0,0,12,12) fromAngle: -90 toAngle: 270 strokeColor: kAzureTintColor];
	[buttonsStackView addArrangedSubview: pieView];

	[pieView animateShapeLayer];

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


- (void)didTapButton {

	[self.delegate didTapInfoButton: self];

}


- (void)didTapCopyPinButton {

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = pinLabel.text;

	[NSNotificationCenter.defaultCenter postNotificationName: @"fadeInOutToast" object: nil];

}


// MARK: NSTimer

- (void)regeneratePIN {

	pinLabel.text = @"";

	CATransition *transition = [CATransition animation];
	transition.type = kCATransitionFade;
	transition.duration = 0.8f;
	transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];

	[pinLabel.layer addAnimation: transition forKey: nil];

	pinLabel.text = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970: [self generateTimestamp]]];

}


@end
