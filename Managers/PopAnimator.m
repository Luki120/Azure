#import "PopAnimator.h"

// https://stackoverflow.com/a/26569703

@implementation PopAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

	UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
	toViewController.view.alpha = 0;
	[[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];

	[UIView animateWithDuration:[self transitionDuration: transitionContext] animations:^{

		fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
		toViewController.view.alpha = 1;

	} completion:^(BOOL finished) {

		fromViewController.view.transform = CGAffineTransformIdentity;
		[transitionContext completeTransition: ![transitionContext transitionWasCancelled]];

	}];

}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {

	return 0.5;

}

@end
