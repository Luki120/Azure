#import "AZAppDelegate.h"


@implementation AZAppDelegate {

	UIWindow *window;

}

// can't use self before the app delegate is initialized so I can't make ivars :frSmh:
static Class strongClass;
static UIButton *quitButton;
static UILabel *addressLabel;
static UIWindow *strongWindow;
static AuthManager *authManager;

#define kAzureLilacTintColor [UIColor colorWithRed: 0.70 green: 0.56 blue: 1.0 alpha: 1.0]
#define kAzureMintTintColor [UIColor colorWithRed: 0.40 green: 0.81 blue: 0.73 alpha: 1.0]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	allocateClass(strongClass);

	authManager = [AuthManager new];
	window = [UIWindow new];
	window.tintColor = kAzureLilacTintColor;
	window.backgroundColor = UIColor.systemBackgroundColor;
	window.rootViewController = [strongClass new];
	[window makeKeyAndVisible];

	strongWindow = window;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL usesBiometrics = [defaults boolForKey: @"useBiometrics"];
	if(usesBiometrics && [authManager shouldUseBiometrics]) unsafePortalDispatch();
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
	quitButton.backgroundColor = kAzureMintTintColor;
	quitButton.layer.cornerCurve = kCACornerCurveContinuous;
	quitButton.layer.cornerRadius = 20;
	quitButton.translatesAutoresizingMaskIntoConstraints = NO;
	[quitButton setTitle:@"Quit" forState: UIControlStateNormal];
	[quitButton addTarget:(AZAppDelegate *)(UIApplication.sharedApplication.delegate) action:@selector(didTapQuitButton) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: quitButton];

	[quitButton.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;
	[quitButton.centerYAnchor constraintEqualToAnchor: self.view.centerYAnchor].active = YES;
	[quitButton.widthAnchor constraintEqualToConstant: 120].active = YES;
	[quitButton.heightAnchor constraintEqualToConstant: 40].active = YES;

}

static void unsafePortalDispatch() {

	[authManager setupAuthWithReason:@"Azure needs you to authenticate in order to access the app."
		reply:^(BOOL success, NSError *error) {

			dispatch_async(dispatch_get_main_queue(), ^{

				if(!success && error.code != -5) {

					strongWindow.rootViewController = [strongClass new];

					[UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{

						addressLabel.alpha = 0.5;
						quitButton.alpha = 1;
						quitButton.transform = CGAffineTransformMakeScale(1, 1);
						addressLabel.transform = CGAffineTransformMakeScale(1, 1);

					} completion: nil];

				}

				else strongWindow.rootViewController = [AzureRootVC new];

			});

		}

	];

}


- (void)didTapQuitButton { abort(); }

@end
