#import "AzureRootVC.h"


@implementation AzureRootVC {

	BOOL isSelected;

}

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

	UIImage *lockImage = [UIImage imageNamed: @"lock"];
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
	NSUInteger vcIndex = [tabViewControllers indexOfObject: viewController];

	UIView *fromView = tabBarController.selectedViewController.view;
	UIView *toView = [[tabViewControllers objectAtIndex:vcIndex] view];

	if(fromView == toView || isSelected) return NO;

	CGRect viewSize = fromView.frame;
	BOOL scrollRight = vcIndex > tabBarController.selectedIndex;

	[fromView.superview addSubview: toView];
	toView.frame = CGRectMake((scrollRight ? 320 : -320), viewSize.origin.y, viewSize.size.width, viewSize.size.height);

	isSelected = YES;

	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		fromView.alpha = 0;
		toView.alpha = 1;

		fromView.frame = CGRectMake((scrollRight ? -320 : 320), viewSize.origin.y, viewSize.size.width, viewSize.size.height);
		toView.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);

	} completion:^(BOOL finished) {

		if(!finished) return;
		[fromView removeFromSuperview];
		tabBarController.selectedIndex = vcIndex;

		isSelected = NO;

	}];

	return YES;

}

@end
