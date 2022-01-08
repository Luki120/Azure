#import "AzureRootVC.h"


@implementation AzureRootVC


- (id)initWithNibName:(NSString *)aNib bundle:(NSBundle *)aBundle {

	self = [super initWithNibName:aNib bundle:aBundle];

	if(self) {

		// Custom initialization

		AzureTableVC *firstVC = [AzureTableVC new];
		UIViewController *secondVC = [[SettingsVC new] makeSettingsViewUI];
		firstVC.title = @"Home";
		secondVC.title = @"Settings";

		UINavigationController *firstNav = [[UINavigationController alloc] initWithRootViewController: firstVC];
		UINavigationController *secondNav = [[UINavigationController alloc] initWithRootViewController: secondVC];

		firstNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage systemImageNamed:@"lock.shield.fill"] tag:0];
		secondNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage systemImageNamed:@"gear"] tag:1];

		NSArray *tabBarControllers = @[firstNav, secondNav];
		self.viewControllers = tabBarControllers;

	}

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.

	self.tabBar.translucent = NO;
	self.tabBar.barTintColor = UIColor.systemBackgroundColor;

	self.tabBar.clipsToBounds = YES;
	self.tabBar.layer.borderWidth = 0;

}


@end