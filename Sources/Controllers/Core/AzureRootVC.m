#import "AzureRootVC.h"


@implementation AzureRootVC

- (id)initWithNibName:(NSString *)aNib bundle:(NSBundle *)aBundle {

	self = [super initWithNibName:aNib bundle:aBundle];

	if(!self) return nil;

	// Custom initialization

	AzureTableVC *firstVC = [AzureTableVC new];
	UIViewController *secondVC = [[SettingsVC new] makeSettingsViewUI];
	firstVC.title = @"Home";
	secondVC.title = @"Settings";

	UINavigationController *firstNav = [[UINavigationController alloc] initWithRootViewController: firstVC];
	UINavigationController *secondNav = [[UINavigationController alloc] initWithRootViewController: secondVC];

	UIImage *lockImage = [UIImage imageWithContentsOfFile: kImagePath];
	UIImage *gearImage = [[UIImage systemImageNamed: @"gearshape.fill"] imageWithConfiguration: [UIImageSymbolConfiguration configurationWithPointSize:18]];

	firstNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:lockImage tag:0];
	secondNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:gearImage tag:1];

	NSArray *tabBarControllers = @[firstNav, secondNav];
	self.viewControllers = tabBarControllers;

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.delegate = self;
	self.tabBar.translucent = NO;
	self.tabBar.barTintColor = UIColor.systemBackgroundColor;
	self.tabBar.clipsToBounds = YES;
	self.tabBar.layer.borderWidth = 0;

}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

	NSArray *tabViewControllers = tabBarController.viewControllers;	
	UIView *fromView = tabBarController.selectedViewController.view;
	UIView *toView = viewController.view;

	NSUInteger fromIndex = [tabViewControllers indexOfObject: tabBarController.selectedViewController];
	NSUInteger toIndex = [tabViewControllers indexOfObject: viewController];

	if(fromView == toView) return NO;

	[UIView transitionFromView:fromView
		toView:toView
		duration:0.5
		options:fromIndex > toIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
		completion:^(BOOL finished) {
			if(finished) tabBarController.selectedIndex = toIndex;
		}];

	return YES;

}

@end
