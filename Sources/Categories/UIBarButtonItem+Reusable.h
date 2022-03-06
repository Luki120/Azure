@import UIKit;


@interface UIBarButtonItem (Reusable)
+ (UIBarButtonItem *)getBarButtonItemWithImage:(UIImage *)image
	forTarget:(id)target
	forSelector:(SEL)selector;
@end
