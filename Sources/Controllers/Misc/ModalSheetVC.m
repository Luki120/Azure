#import "Sources/Controllers/Misc/ModalSheetVC.h"


@implementation ModalSheetVC {

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
	PinCodeVC *pinCodeVC;
	UINavigationController *navVC;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	pinCodeVC = [PinCodeVC new];
	pinCodeVC.delegate = self;

	[self setupViews];
	[self setupObservers];

	return self;

}


- (void)setupObservers {

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(createIssuerOutOfQRCode) name:@"qrCodeScanDone" object:nil];

}


- (void)configureEncryptionType {

	[[TOTPManager sharedInstance] configureEncryptionType];

}


- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear: animated];
	[self animateDimmedView];
	[self animateContainer];

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:
		CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300)
		byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
		cornerRadii:(CGSize){16, 16}].CGPath;

	containerView.layer.mask = maskLayer;
	containerView.layer.cornerCurve = kCACornerCurveContinuous;

}


- (void)setupViews {

	self.view.backgroundColor = UIColor.clearColor;

	// TODO: refactor to address the 'fat view controller' issue by moving all the view code to a subclass

	dimmedView = [UIView new];
	dimmedView.alpha = 0;
	dimmedView.backgroundColor = UIColor.blackColor;
	dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: dimmedView];

	containerView = [UIView new];
	containerView.backgroundColor = UIColor.secondarySystemBackgroundColor;
	containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: containerView];

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


- (void)layoutUI {

	[dimmedView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
	[dimmedView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
	[dimmedView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[dimmedView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;

	[containerView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[containerView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;

	containerViewHeightConstraint = [containerView.heightAnchor constraintEqualToConstant: kDefaultHeight];
	containerViewHeightConstraint.active = YES;

	containerViewBottomConstraint = [containerView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: kDefaultHeight];
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


- (void)activateConstraintsForView:(UIImageView *)view {

	[view.heightAnchor constraintEqualToConstant: 25].active = YES;
	[view.widthAnchor constraintEqualToConstant: 25].active = YES;

}


- (void)setupGestures {

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
	[dimmedView addGestureRecognizer: tapRecognizer];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	[self.view addGestureRecognizer: panRecognizer];

}


- (void)didTapView { [self animateDismiss]; }


- (void)didPan:(UIPanGestureRecognizer *)panRecognizer {

	CGPoint translation = [panRecognizer translationInView: self.view];
	CGFloat newHeight = kDefaultHeight - translation.y;

	switch(panRecognizer.state) {

		case UIGestureRecognizerStateChanged:

			if(newHeight < kDefaultHeight) {
				containerViewHeightConstraint.constant = newHeight;
				containerViewHeightConstraint.active = YES;
				[self.view layoutIfNeeded];
			}
			break;

		case UIGestureRecognizerStateEnded:

			if(newHeight < kDismissableHeight) [self animateDismiss];
			break;

		default: break;

	}

}

// ! Animations

- (void)animateContainer {

	[self animateViewsWithDuration:0.3 animations:^{

		containerViewBottomConstraint.constant = 0;
		[self.view layoutIfNeeded];

	} completion:^(BOOL finished) {

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

	}];

}


- (void)animateDimmedView {

	[self animateViewsWithDuration:0.3 animations:^{ dimmedView.alpha = 0.6; } completion:nil];

}


- (void)animateDismiss {

	[self animateViewsWithDuration:0.3 animations:^{

		dimmedView.alpha = 0;
		containerViewBottomConstraint.constant = kDefaultHeight;
		[self.view layoutIfNeeded];

	} completion:^(BOOL finished) {

		[self dismissViewControllerAnimated:YES completion:nil];

	}];

}

// ! NSNotificationCenter

- (void)createIssuerOutOfQRCode {

	[NSNotificationCenter.defaultCenter postNotificationName:@"reloadData" object:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self animateDismiss];
	});

}

// ! Reusable funcs

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


- (void)configureVC:(UIViewController *)vc
	withTitle:(NSString *)title
	withItemImage:(UIImage *)image
	forSelector:(SEL)selector
	isLeftBarButtonItem:(BOOL)leftItem {

	navVC = [[UINavigationController alloc] initWithRootViewController: vc];
	vc.title = title;
	if(leftItem) vc.navigationItem.leftBarButtonItem = [UIBarButtonItem
		getBarButtonItemWithImage:image
		forTarget:self
		forSelector:selector
	];
	else vc.navigationItem.rightBarButtonItem = [UIBarButtonItem
		getBarButtonItemWithImage:image
		forTarget:self
		forSelector:selector
	];
	navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	navVC.modalPresentationStyle = UIModalPresentationFullScreen;

}

- (void)dismissVC {

	[self dismissViewControllerAnimated:YES completion:nil];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self animateDismiss];
	});

}

// ! Selectors

- (void)didTapScanQRCodeButton {

	QRCodeVC *qrCodeVC = [QRCodeVC new];
	[self configureVC:qrCodeVC
		withTitle:@"Scan QR Code"
		withItemImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
		forSelector:@selector(didTapDismissButton)
		isLeftBarButtonItem:YES
	];
	[self presentViewController:navVC animated:YES completion:nil];

}


- (void)didTapDismissButton { [self dismissVC]; }


- (void)didTapImportQRImageButton {

	UIImagePickerController *pickerC = [UIImagePickerController new];
	pickerC.delegate = self;
	pickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:pickerC animated:YES completion:nil];

}


- (void)didTapEnterManuallyButton {

	[self configureVC:pinCodeVC
		withTitle:@"Enter QR Code"
		withItemImage:[UIImage systemImageNamed: @"checkmark.circle.fill"]
		forSelector:@selector(didTapComposeButton)
		isLeftBarButtonItem:NO
	];
	pinCodeVC.navigationItem.leftBarButtonItem = [UIBarButtonItem
		getBarButtonItemWithImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
		forTarget:self
		forSelector:@selector(didTapDismissButton)
	];
	[self presentViewController:navVC animated:YES completion:nil];

}


- (void)didTapComposeButton {

	[NSNotificationCenter.defaultCenter postNotificationName:@"checkIfDataShouldBeSaved" object:nil];
	[self configureEncryptionType];

}

// ! PinCodeVCDelegate

- (void)pushAlgorithmVC {

	AlgorithmVC *algorithmVC = [AlgorithmVC new];
	algorithmVC.title = @"Algorithm";
	[navVC pushViewController:algorithmVC animated:YES];

}


- (void)shouldDismissVC {

	[NSNotificationCenter.defaultCenter postNotificationName:@"reloadData" object:nil];
	[self dismissVC];

}

// ! UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];

	CIImage *ciImage = [[CIImage alloc] initWithImage: chosenImage];
	NSDictionary *options = @{ CIDetectorAccuracy: CIDetectorAccuracyHigh };
	CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];

	NSArray *features = [qrDetector featuresInImage:ciImage options:options];
	if(features == nil || features.count == 0) return;

	for(CIQRCodeFeature *qrCodeFeature in features) {

		[[TOTPManager sharedInstance] makeURLOutOfOtPauthString: qrCodeFeature.messageString];
		[NSNotificationCenter.defaultCenter postNotificationName:@"reloadData" object:nil];
	}

	[self dismissVC];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker { [self dismissVC]; }

@end
