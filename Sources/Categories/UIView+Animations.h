@import UIKit;


@interface UIView (Animations)
+ (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion;
+ (void)makeRotationTransformForView:(UIView *)view andLabel:(UILabel *)label;
@end
