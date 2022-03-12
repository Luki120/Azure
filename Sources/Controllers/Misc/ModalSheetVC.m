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
	[self setupObservers];

	return self;

}


- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	[modalChildView animateViews];

}


- (void)setupObservers {

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(createIssuerOutOfQRCode) name:@"qrCodeScanDone" object:nil];

}


- (void)setupViews {

	self.view.backgroundColor = UIColor.clearColor;

	modalChildView = [ModalChildView new];
	modalChildView.delegate = self;
	[self.view addSubview: modalChildView];

	[self layoutUI];

}


- (void)layoutUI {

	[modalChildView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
	[modalChildView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
	[modalChildView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[modalChildView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;

}

// ! NSNotificationCenter

- (void)createIssuerOutOfQRCode {

	[NSNotificationCenter.defaultCenter postNotificationName:@"reloadData" object:nil];
	[self dismissVC];

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
	modifyingConstraintForView:(NSLayoutConstraint *)constraint {

	CGPoint translation = [panRecognizer translationInView: self.view];
	CGFloat newHeight = kDefaultHeight - translation.y;

	switch(panRecognizer.state) {

		case UIGestureRecognizerStateChanged:

			if(newHeight < kDefaultHeight) {
				constraint.constant = newHeight;
				constraint.active = YES;
				[self.view layoutIfNeeded];
			}
			break;

		case UIGestureRecognizerStateEnded:

			if(newHeight < kDismissableHeight) [modalChildView animateDismissWithCompletion:^(BOOL finished) {

				[self dismissVC];

			}];
			break;

		default: break;

	}

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
