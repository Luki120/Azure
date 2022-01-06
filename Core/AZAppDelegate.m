#import "AZAppDelegate.h"


@implementation AZAppDelegate {

	UIWindow *window;

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
	window.tintColor = kAzureTintColor;
	window.rootViewController = [NotAuthenticatedVC new];
	[window makeKeyAndVisible];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL state = [defaults boolForKey: @"useBiometrics"];
	if(state) [self verifyAuthentication];
	else window.rootViewController = [AzureRootVC new];

 	UINavigationBar.appearance.shadowImage = [UIImage new];
	UINavigationBar.appearance.translucent = NO;
	UINavigationBar.appearance.barTintColor = UIColor.systemBackgroundColor;

	return YES;

}


- (void)verifyAuthentication {

	LAContext *context = [LAContext new];

	[context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Azure needs you to authenticate in order to access the app." reply:^(BOOL success, NSError *error) {

		dispatch_async(dispatch_get_main_queue(), ^{

			if(success) window.rootViewController = [AzureRootVC new];
			else abort(); // :nfr:

		});

	}];

}


@end
