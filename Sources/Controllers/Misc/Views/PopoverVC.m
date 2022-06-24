#import "PopoverVC.h"


@implementation PopoverVC {

	UILabel *infoLabel;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// do any additional setup after loading the view, typically from a nib.
	UIColor *firstColor = kAzureMintTintColor;
	UIColor *secondColor = [UIColor colorWithRed:0.40 green:0.81 blue:0.78 alpha: 1.0];
	NSArray *gradientColors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];

	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.colors = gradientColors;
	gradientLayer.frame = self.view.bounds;
	gradientLayer.startPoint = CGPointMake(0, 0);
	gradientLayer.endPoint = CGPointMake(1, 1);
	[self.view.layer addSublayer: gradientLayer];

	infoLabel = [UILabel new];
	infoLabel.font = [UIFont systemFontOfSize: 12];
	infoLabel.alpha = 0;
	infoLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
	infoLabel.numberOfLines = 0;
	infoLabel.textAlignment = NSTextAlignmentCenter;
	infoLabel.adjustsFontSizeToFitWidth = YES;
	infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: infoLabel];

	[infoLabel.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor constant: 5].active = YES;
	[infoLabel.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor constant: 5].active = YES;
	[infoLabel.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor constant: -5].active = YES;
	[infoLabel.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;

}


- (void)fadeInPopoverWithMessage:(NSString *)message {

	infoLabel.text = message;

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];

	self.popoverPresentationController.containerView.alpha = 0;
	self.popoverPresentationController.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			self.popoverPresentationController.containerView.alpha = 1;
			self.popoverPresentationController.containerView.transform = CGAffineTransformMakeScale(1, 1);

		} completion:^(BOOL finished) {

			[UIView animateWithDuration:0.5 delay:0.5 usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

				infoLabel.alpha = 1;
				infoLabel.transform = CGAffineTransformMakeScale(1, 1);

			} completion:^(BOOL finished) {

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

					[self dismissViewControllerAnimated:YES completion:nil];

				});

			}];

		}];

	});

}

@end
