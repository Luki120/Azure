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
	BOOL state = [defaults boolForKey: @"useBiometrics"];
	if(state) verifyAuthentication();
	else window.rootViewController = [AzureRootVC new];

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

	UILabel *addressLabel = [UILabel new];
	addressLabel.text = [NSString stringWithFormat: @"%p", &self];
	addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: addressLabel];

	[addressLabel.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor constant: 30].active = YES;
	[addressLabel.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;

}

static void unsafePortalDispatch(BOOL success) {

	if(!success) abort();
	strongWindow.rootViewController = [AzureRootVC new];
	checkIfJailbroken();

}

static void prepareAuthentication(LAContext *context, LAPolicy policy) {

	[context evaluatePolicy:policy localizedReason:@"Azure needs you to authenticate in order to access the app." reply:^(BOOL success, NSError *error) {

		dispatch_async(dispatch_get_main_queue(), ^{ unsafePortalDispatch(success); });

	}];

}

static void verifyAuthentication() {

	LAContext *context = [LAContext new];
	if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error: nil])

		prepareAuthentication(context, LAPolicyDeviceOwnerAuthenticationWithBiometrics);

	else prepareAuthentication(context, LAPolicyDeviceOwnerAuthentication);

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
