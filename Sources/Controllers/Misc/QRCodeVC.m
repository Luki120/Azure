#import "QRCodeVC.h"


@implementation QRCodeVC {

	AVAudioPlayer *audioPlayer;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *videoPreviewLayer;
	PopAnimator *popAnimator;
	PushAnimator *pushAnimator;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	[self setupScanner];

	popAnimator = [PopAnimator new];
	pushAnimator = [PushAnimator new];
	self.navigationController.delegate = self;
	self.view.backgroundColor = UIColor.systemBackgroundColor;
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];
	if(!captureSession.isRunning) [captureSession startRunning];

}


- (void)viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear: animated];
	if(captureSession.isRunning) [captureSession stopRunning];

}


- (void)setupScanner {

	captureSession = [AVCaptureSession new];
	AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];

	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

	if(!input) NSLog(@"Error: %@", error.localizedDescription);
	[captureSession addInput: input];

	AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
	[captureSession addOutput: captureMetadataOutput];

	[captureMetadataOutput setMetadataObjectsDelegate:self queue: dispatch_get_main_queue()];
	[captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject: AVMetadataObjectTypeQRCode]];

	videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: captureSession];
	videoPreviewLayer.frame = self.view.layer.bounds;
	videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer: videoPreviewLayer];

	[captureSession startRunning];

}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
	didOutputMetadataObjects:(NSArray *)metadataObjects
	fromConnection:(AVCaptureConnection *)connection {

	NSString *outputString = nil;
	if(metadataObjects == nil || metadataObjects.count <= 0) return;

	AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
	outputString = [metadataObject stringValue];

	[captureSession stopRunning];
	[videoPreviewLayer removeFromSuperlayer];

	if(!outputString) return;

	[[TOTPManager sharedInstance] makeURLOutOfOtPauthString: outputString];
	[NSNotificationCenter.defaultCenter postNotificationName:@"qrCodeScanDone" object:nil];

}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
	animationControllerForOperation:(UINavigationControllerOperation)operation
	fromViewController:(UIViewController *)fromVC
	toViewController:(UIViewController *)toVC {

	if(operation == UINavigationControllerOperationPop) return popAnimator;
	if(operation == UINavigationControllerOperationPush) return pushAnimator;

	return nil;

}

@end
