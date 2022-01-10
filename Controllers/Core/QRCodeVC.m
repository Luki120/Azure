#import "QRCodeVC.h"


@implementation QRCodeVC {

	AVAudioPlayer *audioPlayer;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *videoPreviewLayer;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.

	[self setupScanner];
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


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

	NSString *outputString = nil;

	if(metadataObjects != nil && metadataObjects.count > 0) {

		AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
		outputString = [metadataObject stringValue];

	}

	[captureSession stopRunning];
	[videoPreviewLayer removeFromSuperlayer];

 	if(outputString) {

		NSURL *url = [[NSURL alloc] initWithString: outputString];
		NSURLComponents *components = [NSURLComponents componentsWithURL: url resolvingAgainstBaseURL: NO];
		NSArray *queryItems = components.queryItems;

		for(NSURLQueryItem *queryItem in queryItems) {

			if([queryItem.name isEqualToString: @"secret"]) {

				NSString *secretHash = queryItem.value;
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = secretHash;

			}

		}

		[NSNotificationCenter.defaultCenter postNotificationName: @"qrCodeScanDone" object: nil];

	}

}


@end
