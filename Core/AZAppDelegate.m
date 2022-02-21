#import "AZAppDelegate.h"


@implementation AZAppDelegate {

	UIWindow *window;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	allocateClass(strongClass);

	window = [UIWindow new];
	window.frame = UIScreen.mainScreen.bounds;
	window.tintColor = kAzureTintColor;
	window.rootViewController = [strongClass new];
	[window makeKeyAndVisible];

	strongWindow = window;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL usesBiometrics = [defaults boolForKey: @"useBiometrics"];
	if(usesBiometrics) unsafePortalDispatch();
	else {
		window.rootViewController = [AzureRootVC new];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			checkIfJailbroken();
		});
	}

 	UINavigationBar.appearance.shadowImage = [UIImage new];
	UINavigationBar.appearance.translucent = NO;
	UINavigationBar.appearance.barTintColor = UIColor.systemBackgroundColor;

	return YES;

}

static void allocateClass(Class theClass) {

	theClass = strongClass;
	strongClass = objc_allocateClassPair([UIViewController class], "NotAuthenticatedVC", 0);
	Method vDLMethod = class_getInstanceMethod([UIViewController class], @selector(viewDidLoad));
	const char *types = method_getTypeEncoding(vDLMethod);
	class_addMethod(
		strongClass,
		@selector(viewDidLoad),
		(IMP) overrideVDL,
		types
	);
	objc_registerClassPair(strongClass);

}

static void overrideVDL(UIViewController *self, SEL _cmd) {

	// Do any additional setup after loading the view, typically from a nib.

    /*--- idfk how to call super at runtime yet so I'll leave it like this for now,
    but it doesn't really matter anyways, since I just want a plain vanilla view controller ---*/

    // edit: I found out how, yet what I tried crashes so far, hmmm

	self.view.backgroundColor = UIColor.systemBackgroundColor;

	addressLabel = [UILabel new];
	addressLabel.alpha = 0;
	addressLabel.font = [UIFont systemFontOfSize: 12];
	addressLabel.text = [NSString stringWithFormat: @"%p", &self];
	addressLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
	addressLabel.textColor = UIColor.systemGrayColor;
	addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: addressLabel];

	[addressLabel.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;
	[addressLabel.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -30].active = YES;

	quitButton = [UIButton new];
	quitButton.alpha = 0;
	quitButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
	quitButton.backgroundColor = kAzureTintColor;
	quitButton.layer.cornerCurve = kCACornerCurveContinuous;
	quitButton.layer.cornerRadius = 20;
	quitButton.translatesAutoresizingMaskIntoConstraints = NO;
	[quitButton setTitle:@"Quit" forState: UIControlStateNormal];
	[quitButton addTarget:(AZAppDelegate *)([[UIApplication sharedApplication] delegate]) action:@selector(didTapQuitButton) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: quitButton];

	[quitButton.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;
	[quitButton.centerYAnchor constraintEqualToAnchor: self.view.centerYAnchor].active = YES;
	[quitButton.widthAnchor constraintEqualToConstant: 120].active = YES;
	[quitButton.heightAnchor constraintEqualToConstant: 40].active = YES;

}

- (void)didTapQuitButton { abort(); }

static void unsafePortalDispatch() {

	LAContext *context = [LAContext new];

	[context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Azure needs you to authenticate in order to access the app." reply:^(BOOL success, NSError *error) {

		dispatch_async(dispatch_get_main_queue(), ^{

			if(!success) {

				strongWindow.rootViewController = [strongClass new];

				[UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{

					addressLabel.alpha = 0.5;
					quitButton.alpha = 1;
					quitButton.transform = CGAffineTransformMakeScale(1, 1);
					addressLabel.transform = CGAffineTransformMakeScale(1, 1);

				} completion: nil];

			}

			else {

				strongWindow.rootViewController = [AzureRootVC new];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
					checkIfJailbroken();
				});

			}

		});

	}];

}

static void checkIfJailbroken() {

	NSFileManager *fileM = [NSFileManager defaultManager];

	// very basic, but tbh idrgaf to get crazy about it, so this will suffice

	if(![fileM fileExistsAtPath: kCheckra1n]
		&& ![fileM fileExistsAtPath: kTaurine]
		&& ![fileM fileExistsAtPath: kUnc0ver]) return;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults boolForKey: @"jailbrokenSheetAppearedOnce"]) return;

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:@"Oop, looks like you're jailbroken. Don't worry, I won't lock you out or prevent you from using the app, that's bullshit I don't believe in, and whoever does that can go fuck themselves. That being said, be aware that your device could be more prone to attacks or vulnerabilities and your data could get compromised, proceed with caution." preferredStyle: UIAlertControllerStyleActionSheet];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"I understand" style:UIAlertActionStyleDestructive handler:nil];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { abort(); }];
	[alertController addAction: confirmAction];
	[alertController addAction: cancelAction];
	[strongWindow.rootViewController presentViewController:alertController animated:YES completion:nil];

	[defaults setBool:YES forKey: @"jailbrokenSheetAppearedOnce"];

}

@end
