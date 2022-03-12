#import "ModalChildView.h"


@implementation ModalChildView {

	UIView *containerView;
	UIView *dimmedView;
	NSLayoutConstraint *containerViewBottomConstraint;
	NSLayoutConstraint *containerViewHeightConstraint;
	UIStackView *titleStackView;
	UIStackView *buttonsStackView;
	UIStackView *scanQRCodeStackView;
	UIStackView *importQRStackView;
	UIStackView *enterManuallyStackView;
	UILabel *titleLabel;
	UILabel *subtitleLabel;
	UIButton *scanQRCodeButton;
	UIButton *importQRButton;
	UIButton *enterManuallyButton;
	UIImageView *scanQRCodeImageView;
	UIImageView *importQRImageView;
	UIImageView *enterManuallyImageView;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	[self setupViews];

	return self;

}


- (void)setupViews {

	self.translatesAutoresizingMaskIntoConstraints = NO;

	dimmedView = [UIView new];
	dimmedView.alpha = 0;
	dimmedView.backgroundColor = UIColor.blackColor;
	dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: dimmedView];

	containerView = [UIView new];
	containerView.backgroundColor = UIColor.secondarySystemBackgroundColor;
	containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: containerView];

	/* ********** STACK VIEWS ********** */

	titleStackView = [UIStackView new];
	buttonsStackView = [UIStackView new];
	scanQRCodeStackView = [UIStackView new];
	importQRStackView = [UIStackView new];
	enterManuallyStackView = [UIStackView new];
	[self createStackViewWithStackView:titleStackView
		withAxis:UILayoutConstraintAxisVertical
		withSpacing:10
	];
	[self createStackViewWithStackView:buttonsStackView
		withAxis:UILayoutConstraintAxisVertical
		withSpacing:20
	];
	[self createStackViewWithStackView:scanQRCodeStackView
		withAxis:UILayoutConstraintAxisHorizontal
		withSpacing:10
	];
	[self createStackViewWithStackView:importQRStackView
		withAxis:UILayoutConstraintAxisHorizontal
		withSpacing:10
	];
	[self createStackViewWithStackView:enterManuallyStackView
		withAxis:UILayoutConstraintAxisHorizontal
		withSpacing:10
	];

	buttonsStackView.alpha = 0;
	buttonsStackView.transform = CGAffineTransformMakeScale(0.1, 0.1);
	titleStackView.alpha = 0;
	titleStackView.transform = CGAffineTransformMakeScale(0.1, 0.1);

	[containerView addSubview: titleStackView];
	[containerView addSubview: buttonsStackView];
	[buttonsStackView addArrangedSubview: scanQRCodeStackView];
	[buttonsStackView addArrangedSubview: importQRStackView];
	[buttonsStackView addArrangedSubview: enterManuallyStackView];

	/* ********** LABELS ********** */

	titleLabel = [UILabel new];
	[self createLabelWithLabel:titleLabel
		withFont:[UIFont systemFontOfSize: 16]
		withText:@"Add issuer"
		textColor:UIColor.labelColor
	];
	subtitleLabel = [UILabel new];
	[self createLabelWithLabel:subtitleLabel
		withFont:[UIFont systemFontOfSize: 12]
		withText:@"Add an issuer by scanning a QR code, importing a QR image or entering the secret manually."
		textColor:UIColor.secondaryLabelColor
	];

	/* ********** IMAGE VIEWS ********** */

	scanQRCodeImageView = [UIImageView new];
	[self createImageView:scanQRCodeImageView withImage:[UIImage systemImageNamed: @"qrcode"]];

	importQRImageView = [UIImageView new];
	[self createImageView:importQRImageView withImage:[UIImage systemImageNamed: @"square.and.arrow.up"]];

	enterManuallyImageView = [UIImageView new];
	[self createImageView:enterManuallyImageView withImage:[UIImage systemImageNamed: @"square.and.pencil"]];

	/* ********** BUTTONS ********** */

	scanQRCodeButton = [UIButton new];
	[self createButtonWithButton:scanQRCodeButton
		withTitleLabel:@"Scan QR Code"
		forSelector:@selector(didTapScanQRCodeButton)
	];
	importQRButton = [UIButton new];
	[self createButtonWithButton:importQRButton
		withTitleLabel:@"Import QR Image"
		forSelector:@selector(didTapImportQRImageButton)
	];
	enterManuallyButton = [UIButton new];
	[self createButtonWithButton:enterManuallyButton
		withTitleLabel:@"Enter Manually"
		forSelector:@selector(didTapEnterManuallyButton)
	];

	[titleStackView addArrangedSubview: titleLabel];
	[titleStackView addArrangedSubview: subtitleLabel];
	[scanQRCodeStackView addArrangedSubview: scanQRCodeImageView];
	[scanQRCodeStackView addArrangedSubview: scanQRCodeButton];
	[importQRStackView addArrangedSubview: importQRImageView];
	[importQRStackView addArrangedSubview: importQRButton];
	[enterManuallyStackView addArrangedSubview: enterManuallyImageView];
	[enterManuallyStackView addArrangedSubview: enterManuallyButton];

	[self setupGestures];
	[self layoutUI];

}


- (void)setupGestures {

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
	[dimmedView addGestureRecognizer: tapRecognizer];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	[self addGestureRecognizer: panRecognizer];

}


- (void)layoutSubviews {

	[super layoutSubviews];

	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:
		CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)
		byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
		cornerRadii:(CGSize){16, 16}].CGPath;

	containerView.layer.mask = maskLayer;
	containerView.layer.cornerCurve = kCACornerCurveContinuous;

}


- (void)layoutUI {

	[dimmedView.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;
	[dimmedView.bottomAnchor constraintEqualToAnchor: self.bottomAnchor].active = YES;
	[dimmedView.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[dimmedView.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

	[containerView.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[containerView.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

	containerViewHeightConstraint = [containerView.heightAnchor constraintEqualToConstant: kDefaultHeight];
	containerViewHeightConstraint.active = YES;

	containerViewBottomConstraint = [containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant: kDefaultHeight];
	containerViewBottomConstraint.active = YES;

	[titleStackView.topAnchor constraintEqualToAnchor: containerView.topAnchor constant: 30].active = YES;
	[titleStackView.centerXAnchor constraintEqualToAnchor: containerView.centerXAnchor].active = YES;
	[titleStackView.leadingAnchor constraintEqualToAnchor: containerView.leadingAnchor constant: 30].active = YES;
	[titleStackView.trailingAnchor constraintEqualToAnchor: containerView.trailingAnchor constant: -30].active = YES;

	[buttonsStackView.topAnchor constraintEqualToAnchor: titleStackView.bottomAnchor constant: 30].active = YES;
	[buttonsStackView.leadingAnchor constraintEqualToAnchor: containerView.leadingAnchor constant: 20].active = YES;

	[self activateConstraintsForView: scanQRCodeImageView];
	[self activateConstraintsForView: importQRImageView];
	[self activateConstraintsForView: enterManuallyImageView];

}

// ! Animations

- (void)animateViews {

	[self animateDimmedView];
	[self animateContainer];

}

- (void)animateContainer {

	[self animateViewsWithDuration:0.3 animations:^{

		containerViewBottomConstraint.constant = 0;
		[self layoutIfNeeded];

	} completion:^(BOOL finished) { [self animateSubviews]; }];

}


- (void)animateDimmedView {

	[self animateViewsWithDuration:0.3 animations:^{ dimmedView.alpha = 0.6; } completion:nil];

}


- (void)animateDismissWithCompletion:(void(^)(BOOL finished))completion {

	[self animateViewsWithDuration:0.3 animations:^{

		dimmedView.alpha = 0;
		containerViewBottomConstraint.constant = kDefaultHeight;
		[self layoutIfNeeded];

	} completion:completion];

}


- (void)animateSubviews {

	[UIView animateWithDuration:0.5 delay:0.008 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		titleStackView.alpha = 1;
		titleStackView.transform = CGAffineTransformMakeScale(1, 1);

	} completion:^(BOOL finished) {

		[UIView animateWithDuration:0.5 delay:0.004 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			buttonsStackView.alpha = 1;
			buttonsStackView.transform = CGAffineTransformMakeScale(1, 1);

		} completion:^(BOOL finished) {

			titleStackView.transform = CGAffineTransformIdentity;
			buttonsStackView.transform = CGAffineTransformIdentity;

		}];

	}];

}

// ! Reusable funcs

- (void)activateConstraintsForView:(UIImageView *)view {

	[view.widthAnchor constraintEqualToConstant: 25].active = YES;
	[view.heightAnchor constraintEqualToConstant: 25].active = YES;

}


- (void)animateViewsWithDuration:(CGFloat)duration
	animations:(void (^)(void))animations
	completion:(void(^)(BOOL finished))completion {

	[UIView animateWithDuration:duration
		delay:0
		options:UIViewAnimationOptionCurveEaseIn
		animations:animations
		completion:completion
	];

}


- (void)createStackViewWithStackView:(UIStackView *)stackView
	withAxis:(UILayoutConstraintAxis)axis
	withSpacing:(CGFloat)spacing {

	stackView.axis = axis;
	stackView.spacing = spacing;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void)createButtonWithButton:(UIButton *)button
	withTitleLabel:(NSString *)title
	forSelector:(SEL)selector {

	button.titleLabel.font = [UIFont systemFontOfSize: 16];
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[button setTitle:title forState: UIControlStateNormal];
	[button setTitleColor:UIColor.labelColor forState: UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents: UIControlEventTouchUpInside];

}


- (void)createLabelWithLabel:(UILabel *)label
	withFont:(UIFont *)font
	withText:(NSString *)text
	textColor:(UIColor *)textColor {

	label.font = font;
	label.text = text;
	label.textColor = textColor;
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;

}


- (void)createImageView:(UIImageView *)imageView withImage:(UIImage *)image {

	imageView.image = image;
	imageView.tintColor = kAzureMintTintColor;
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.clipsToBounds = YES;
	imageView.translatesAutoresizingMaskIntoConstraints = NO;

}

// ! Selectors

- (void)didTapScanQRCodeButton {

	[self.delegate modalChildViewDidTapScanQRCodeButton];

}


- (void)didTapImportQRImageButton {

	[self.delegate modalChildViewDidTapImportQRImageButton];

}


- (void)didTapEnterManuallyButton {

	[self.delegate modalChildViewDidTapEnterManuallyButton];

}


- (void)didTapView { [self.delegate modalChildViewDidTapDimmedView]; }


- (void)didPan:(UIPanGestureRecognizer *)panRecognizer {

	[self.delegate modalChildViewDidPanWithGesture: panRecognizer
		modifyingConstraintForView:containerViewHeightConstraint
	];

}

@end
