#import "Sources/Categories/UIView+Animations.h"


@implementation UIView (Animations)

+ (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion {

	[UIView animateWithDuration:0.5 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animations completion:completion];

}

+ (void)makeRotationTransformForView:(UIView *)view andLabel:(UILabel *)label {

	CATransform3D rotation = CATransform3DIdentity;
	rotation.m34 = 1.0 / -500; // idfk what this does but ok :lul:
	rotation = CATransform3DRotate(rotation, 180.0 * M_PI / 180, 0, 1, 0);
	view.layer.transform = rotation;
	label.layer.transform = rotation;

}

@end
