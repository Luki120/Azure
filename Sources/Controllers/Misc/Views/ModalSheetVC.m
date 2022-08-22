#import "ModalSheetVC.h"


@implementation ModalSheetVC {

	ModalChildView *modalChildView;
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

	return self;

}


- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	[modalChildView animateViews];

}


- (void)setupViews {

	self.view.backgroundColor = UIColor.clearColor;

	modalChildView = [ModalChildView new];
	modalChildView.delegate = self;
	[self.view addSubview: modalChildView];

	[self layoutUI];

}

// ! Designated initializers

- (void)setupChildWithTitle:(NSString *)title
	subtitle:(NSString *)subtitle
	buttonTitle:(NSString *)buttonTitle
	forTarget:(id)target
	forSelector:(SEL)selector
	secondButtonTitle:(NSString *)secondTitle
	forTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	thirdStackView:(BOOL)thirdSV
	thirdButtonTitle:(NSString *)thirdTitle
	forTarget:(id)thirdTarget
	forSelector:(SEL)thirdSelector
	accessoryImage:(UIImage *)accessoryImage
	secondAccessoryImage:(UIImage *)secondAccessoryImg
	thirdAccessoryImage:(UIImage *)thirdAccessoryImg
	prepareForReuse:(BOOL)prepare
	scaleAnimation:(BOOL)scaleAnim {

	[modalChildView setupModalChildWithTitle:title
		subtitle:subtitle
		buttonTitle:buttonTitle
		forTarget:target
		forSelector:selector
		secondButtonTitle:secondTitle
		forTarget:secondTarget
		forSelector:secondSelector
		thirdStackView:thirdSV
		thirdButtonTitle:thirdTitle
		forTarget:thirdTarget
		forSelector:thirdSelector
		accessoryImage:accessoryImage
		secondAccessoryImage:secondAccessoryImg
		thirdAccessoryImage:thirdAccessoryImg
		prepareForReuse:prepare
		scaleAnimation:scaleAnim
	];

}


- (void)setupChildWithTitle:(NSString *)title
	subtitle:(NSString *)subtitle
	buttonTitle:(NSString *)buttonTitle
	forTarget:(id)target
	forSelector:(SEL)selector
	secondButtonTitle:(NSString *)secondTitle
	forTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	accessoryImage:(UIImage *)accessoryImage
	secondAccessoryImage:(UIImage *)secondAccessoryImg
	prepareForReuse:(BOOL)prepare
	scaleAnimation:(BOOL)scaleAnim {

	[modalChildView setupModalChildWithTitle:title
		subtitle:subtitle
		buttonTitle:buttonTitle
		forTarget:target
		forSelector:selector
		secondButtonTitle:secondTitle
		forTarget:secondTarget
		forSelector:secondSelector
		thirdStackView:NO
		thirdButtonTitle:nil
		forTarget:nil
		forSelector:nil
		accessoryImage:accessoryImage
		secondAccessoryImage:secondAccessoryImg
		thirdAccessoryImage:nil
		prepareForReuse:prepare
		scaleAnimation:scaleAnim
	];

}


- (void)shouldCrossDissolveChildSubviews { [modalChildView shouldCrossDissolveSubviews]; }
- (void)layoutUI { [self.view pinViewToAllEdges: modalChildView]; }
- (void)vcNeedsDismissal {

	[modalChildView animateDismissWithCompletion:^(BOOL finished) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];

}

// ! Reusable funcs

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
		[modalChildView animateDismissWithCompletion:^(BOOL finished) {
			[self dismissViewControllerAnimated:YES completion:nil];
		}];
	});

}

// ! ModalChildViewDelegate

- (void)modalChildViewDidTapScanQRCodeButton {

	QRCodeVC *qrCodeVC = [QRCodeVC new];
	qrCodeVC.delegate = self;
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


- (void)modalChildViewDidTapDimmedView {

	[modalChildView animateDismissWithCompletion:^(BOOL finished) {

		[self dismissViewControllerAnimated:YES completion:nil];

	}];

}


- (void)modalChildViewDidPanWithGesture:(UIPanGestureRecognizer *)panRecognizer
	modifyingConstraint:(NSLayoutConstraint *)constraint {

	CGPoint translation = [panRecognizer translationInView: self.view];
	CGFloat newHeight = modalChildView.currentSheetHeight - translation.y;

	switch(panRecognizer.state) {

		case UIGestureRecognizerStateChanged:

			if(newHeight < modalChildView.kDefaultHeight) {
				constraint.constant = newHeight;
				constraint.active = YES;

				[modalChildView calculateAlphaBasedOnTranslation: translation];

				[self.view layoutIfNeeded];
			}
			break;

		case UIGestureRecognizerStateEnded:

			if(newHeight < modalChildView.kDismissableHeight) [modalChildView animateDismissWithCompletion:^(BOOL finished) {
				[self dismissVC];
			}];
			else if(newHeight < modalChildView.kDefaultHeight) [modalChildView animateSheetHeight: modalChildView.kDefaultHeight];
			break;

		default: break;

	}

}

// ! PinCodeVCDelegate

- (void)pinCodeVCShouldDismissVC {

	[self.delegate modalSheetVCShouldReloadData];
	[self dismissVC];

}


- (void)pinCodeVCShouldPushAlgorithmVC {

	AlgorithmVC *algorithmVC = [AlgorithmVC new];
	algorithmVC.title = @"Algorithm";
	[navVC pushViewController:algorithmVC animated:YES];

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
		[self.delegate modalSheetVCShouldReloadData];
	}

	[self dismissVC];

}

// ! QRCodeVCDelegate

- (void)qrCodeVCDidCreateIssuerOutOfQRCode {

	[self.delegate modalSheetVCShouldReloadData];
	[self dismissVC];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker { [self dismissVC]; }

// ! Selectors

- (void)didTapComposeButton {

	[NSNotificationCenter.defaultCenter postNotificationName:@"checkIfDataShouldBeSaved" object:nil];

}


- (void)didTapDismissButton { [self dismissVC]; }

@end
