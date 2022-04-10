#import "ModalChildView.h"


@implementation ModalChildView {

	UIView *containerView;
	UIView *dimmedView;
	NSLayoutConstraint *containerViewBottomConstraint;
	NSLayoutConstraint *containerViewHeightConstraint;
	UIStackView *strongTitleStackView;
	UIStackView *strongButtonsStackView;
	BOOL shouldAllowScaleAnim;

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

	[self pinViewToAllEdges: dimmedView];

	[containerView.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[containerView.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

	containerViewHeightConstraint = [containerView.heightAnchor constraintEqualToConstant: kDefaultHeight];
	containerViewHeightConstraint.active = YES;

	containerViewBottomConstraint = [containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant: kDefaultHeight];
	containerViewBottomConstraint.active = YES;

}


- (void)layoutUIForStackView:(UIStackView *)titleSV buttonsStackView:(UIStackView *)buttonsSV {

	[titleSV.topAnchor constraintEqualToAnchor: containerView.topAnchor constant: 30].active = YES;
	[titleSV.centerXAnchor constraintEqualToAnchor: containerView.centerXAnchor].active = YES;
	[titleSV.leadingAnchor constraintEqualToAnchor: containerView.leadingAnchor constant: 30].active = YES;
	[titleSV.trailingAnchor constraintEqualToAnchor: containerView.trailingAnchor constant: -30].active = YES;

	[buttonsSV.topAnchor constraintEqualToAnchor: titleSV.bottomAnchor constant: 30].active = YES;
	[buttonsSV.leadingAnchor constraintEqualToAnchor: containerView.leadingAnchor constant: 20].active = YES;

}

// ! Animations

- (void)animateViews { [self animateSheet]; }
- (void)animateSheet {

	[self animateViewsWithDuration:0.3 animations:^{

		dimmedView.alpha = 0.6;
		containerViewBottomConstraint.constant = 0;
		[self layoutIfNeeded];

	} completion:^(BOOL finished) {
		if(!shouldAllowScaleAnim) return;
		[self animateSubviews:strongTitleStackView and:strongButtonsStackView];
	}];

}


- (void)animateSheetHeight:(CGFloat)height {

	[self animateViewsWithDuration:0.3 animations:^{

		containerViewHeightConstraint.constant = height;
		[self layoutIfNeeded];

	} completion:nil];

	currentSheetHeight = height;

}


- (void)animateDismissWithCompletion:(void(^)(BOOL finished))completion {

	[self animateViewsWithDuration:0.3 animations:^{

		dimmedView.alpha = 0;
		containerViewBottomConstraint.constant = kDefaultHeight;
		[self layoutIfNeeded];

	} completion:completion];

}


- (void)shouldCrossDissolveSubviews {

	[UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		strongTitleStackView.alpha = 0;
		strongButtonsStackView.alpha = 0;

	} completion:^(BOOL finished) {

		[UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			strongTitleStackView.alpha = 1;
			strongButtonsStackView.alpha = 1;

		} completion:nil];	

	}];

}


- (void)animateSubviews:(UIStackView *)titleSV and:(UIStackView *)buttonsSV {

	[UIView animateWithDuration:0.5 delay:0.008 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		titleSV.alpha = 1;
		titleSV.transform = CGAffineTransformMakeScale(1, 1);

	} completion:^(BOOL finished) {

		[UIView animateWithDuration:0.5 delay:0.004 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			buttonsSV.alpha = 1;
			buttonsSV.transform = CGAffineTransformMakeScale(1, 1);

		} completion:^(BOOL finished) {

			titleSV.transform = CGAffineTransformIdentity;
			buttonsSV.transform = CGAffineTransformIdentity;

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
	withTarget:(id)target
	forSelector:(SEL)selector {

	button.titleLabel.font = [UIFont systemFontOfSize: 16];
	[button setTitle:title forState: UIControlStateNormal];
	[button setTitleColor:UIColor.labelColor forState: UIControlStateNormal];
	[button addTarget:target action:selector forControlEvents: UIControlEventTouchUpInside];

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


- (void)setupModalSheetWithTitle:(NSString *)title
	subtitle:(NSString *)subtitle
	buttonTitle:(NSString *)buttonTitle
	forTarget:(id)target
	forSelector:(SEL)selector
	secondButtonTitle:(NSString *)secondTitle
	forTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	thirdStackView:(BOOL)usesThirdSV
	thirdButtonTitle:(NSString *)thirdTitle
	forTarget:(id)thirdTarget
	forSelector:(SEL)thirdSelector
	accessoryImage:(UIImage *)accessoryImage
	secondAccessoryImage:(UIImage *)secondAccessoryImg
	thirdAccessoryImage:(UIImage *)thirdAccessoryImg
	prepareForReuse:(BOOL)prepare
	scaleAnimation:(BOOL)scaleAnim {

	if(prepare) {
		[strongTitleStackView removeFromSuperview];
		[strongButtonsStackView removeFromSuperview];
	}

	/* ********** STACK VIEWS ********** */

	UIStackView *titleSV = [UIStackView new];
	UIStackView *buttonsSV = [UIStackView new];
	UIStackView *firstSV = [UIStackView new];
	UIStackView *secondSV = [UIStackView new];
	UIStackView *thirdSV = [UIStackView new];

	[self createStackViewWithStackView:titleSV
		withAxis:UILayoutConstraintAxisVertical
		withSpacing:10
	];
	[self createStackViewWithStackView:buttonsSV
		withAxis:UILayoutConstraintAxisVertical
		withSpacing:20
	];
	[self createStackViewWithStackView:firstSV
		withAxis:UILayoutConstraintAxisHorizontal
		withSpacing:10
	];
	[self createStackViewWithStackView:secondSV
		withAxis:UILayoutConstraintAxisHorizontal
		withSpacing:10
	];
	if(usesThirdSV)
		[self createStackViewWithStackView:thirdSV
			withAxis:UILayoutConstraintAxisHorizontal
			withSpacing:10
		];

	[containerView addSubview: titleSV];
	[containerView addSubview: buttonsSV];
	[buttonsSV addArrangedSubview: firstSV];
	[buttonsSV addArrangedSubview: secondSV];
	if(usesThirdSV) [buttonsSV addArrangedSubview: thirdSV];

	if(scaleAnim) {
		buttonsSV.alpha = 0;
		buttonsSV.transform = CGAffineTransformMakeScale(0.1, 0.1);
		titleSV.alpha = 0;
		titleSV.transform = CGAffineTransformMakeScale(0.1, 0.1);
	}

	/* ********** LABELS ********** */

	UILabel *titleL = [UILabel new];
	UILabel *subtitleL = [UILabel new];
	subtitleL.translatesAutoresizingMaskIntoConstraints = NO;

	[self createLabelWithLabel:titleL
		withFont:[UIFont systemFontOfSize: 16]
		withText:title
		textColor:UIColor.labelColor
	];
	[self createLabelWithLabel:subtitleL
		withFont:[UIFont systemFontOfSize: 12]
		withText:subtitle
		textColor:UIColor.secondaryLabelColor
	];

	/* ********** IMAGE VIEWS ********** */

	UIImageView *firstImageView = [UIImageView new];
	UIImageView *secondImageView = [UIImageView new];
	UIImageView *thirdImageView = [UIImageView new];

	[self createImageView:firstImageView withImage:accessoryImage];
	[self createImageView:secondImageView withImage:secondAccessoryImg];
	[self createImageView:thirdImageView withImage:thirdAccessoryImg];

	/* ********** BUTTONS ********** */

	UIButton *firstButton = [UIButton new];
	UIButton *secondButton = [UIButton new];
	UIButton *thirdButton = [UIButton new];

	[self createButtonWithButton:firstButton
		withTitleLabel:title
		withTarget:target
		forSelector:selector
	];
	[self createButtonWithButton:secondButton
		withTitleLabel:secondTitle
		withTarget:secondTarget
		forSelector:secondSelector
	];
	[self createButtonWithButton:thirdButton
		withTitleLabel:thirdTitle
		withTarget:thirdTarget
		forSelector:thirdSelector
	];

	[titleSV addArrangedSubview: titleL];
	[titleSV addArrangedSubview: subtitleL];
	[firstSV addArrangedSubview: firstImageView];
	[firstSV addArrangedSubview: firstButton];
	[secondSV addArrangedSubview: secondImageView];
	[secondSV addArrangedSubview: secondButton];
	[thirdSV addArrangedSubview: thirdImageView];
	[thirdSV addArrangedSubview: thirdButton];

	[self layoutUIForStackView:titleSV buttonsStackView: buttonsSV];
	[self activateConstraintsForView: firstImageView];
	[self activateConstraintsForView: secondImageView];
	[self activateConstraintsForView: thirdImageView];

	strongTitleStackView = titleSV;
	strongButtonsStackView = buttonsSV;
	shouldAllowScaleAnim = scaleAnim;

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

	[self.delegate modalChildViewDidPanWithGesture:panRecognizer
		modifyingConstraintForView:containerViewHeightConstraint
	];

}

@end
