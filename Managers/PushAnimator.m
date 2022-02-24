#import "PushAnimator.h"


@implementation PushAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

	UIViewController *toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
	UIViewController *fromViewController = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
	toViewController.view.alpha = 0;
	[[transitionContext containerView] addSubview: toViewController.view];

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
