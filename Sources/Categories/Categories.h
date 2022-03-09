@import UIKit;


@interface UIBarButtonItem (Reusable)
+ (UIBarButtonItem *)getBarButtonItemWithImage:(UIImage *)image
	forTarget:(id)target
	forSelector:(SEL)selector;
@end


@interface UIImage (Resize)
+ (UIImage *)resizeImageFromImage:(UIImage *)image withSize:(CGSize)size;
@end


@interface UIView (Animations)
+ (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion;
+ (void)makeRotationTransformForView:(UIView *)view andLabel:(UILabel *)label;
@end
