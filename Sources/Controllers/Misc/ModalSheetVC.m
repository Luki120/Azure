#import "ModalSheetVC.h"


@implementation ModalSheetVC {

	UIView *containerView;
	UIView *dimmedView;
	ModalChildView *modalChildView;
	NSLayoutConstraint *containerViewBottomConstraint;
	NSLayoutConstraint *containerViewHeightConstraint;
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

	modalChildView = [ModalChildView new];
	modalChildView.delegate = self;
	[containerView addSubview: modalChildView];

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

	[modalChildView.topAnchor constraintEqualToAnchor: containerView.topAnchor].active = YES;
	[modalChildView.bottomAnchor constraintEqualToAnchor: containerView.bottomAnchor].active = YES;
	[modalChildView.leadingAnchor constraintEqualToAnchor: containerView.leadingAnchor].active = YES;
	[modalChildView.trailingAnchor constraintEqualToAnchor: containerView.trailingAnchor].active = YES;

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

	} completion:^(BOOL finished) { [modalChildView animateSubviews]; }];

}


- (void)animateDimmedView {

	[self animateViewsWithDuration:0.3 animations:^{ dimmedView.alpha = 0.6; } completion:nil];

}


- (void)animateDismiss {

	[self animateViewsWithDuration:0.3 animations:^{

		dimmedView.alpha = 0;
		containerViewBottomConstraint.constant = kDefaultHeight;
		[self.view layoutIfNeeded];

	} completion:^(BOOL finished) { [self dismissViewControllerAnimated:YES completion:nil]; }];

}

// ! NSNotificationCenter

- (void)createIssuerOutOfQRCode {

	[NSNotificationCenter.defaultCenter postNotificationName:@"reloadData" object:nil];
	[self dismissVC];

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

// ! ModalChildViewDelegate

- (void)modalChildViewDidTapScanQRCodeButton {

	QRCodeVC *qrCodeVC = [QRCodeVC new];
	[self configureVC:qrCodeVC
		withTitle:@"Scan QR Code"
		withItemImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
		forSelector:@selector(didTapDismissButton)
		isLeftBarButtonItem:YES
	];
	[self presentViewController:navVC animated:YES completion:nil];

}


- (void)modalChildViewDidTapImportQRImageButton {

	UIImagePickerController *pickerC = [UIImagePickerController new];
	pickerC.delegate = self;
	pickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:pickerC animated:YES completion:nil];

}


- (void)modalChildViewDidTapEnterManuallyButton {

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

// ! Selectors

- (void)didTapComposeButton {

	[NSNotificationCenter.defaultCenter postNotificationName:@"checkIfDataShouldBeSaved" object:nil];

}


- (void)didTapDismissButton { [self dismissVC]; }

@end
