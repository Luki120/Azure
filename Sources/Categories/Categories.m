#import "Sources/Categories/Categories.h"


@implementation UIBarButtonItem (Reusable)

+ (UIBarButtonItem *)getBarButtonItemWithImage:(UIImage *)image
	forTarget:(id)target
	forSelector:(SEL)selector {

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
		initWithImage:image
		style:UIBarButtonItemStyleDone
		target:target
		action:selector
	];

	return barButtonItem;

}

@end


@implementation UIImage (Resize)

+ (UIImage *)resizeImageFromImage:(UIImage *)image withSize:(CGSize)size {

	CGSize newSize = size;

	CGFloat scale = MAX(newSize.width/image.size.width, newSize.height/image.size.height);
	CGFloat width = image.size.width * scale;
	CGFloat height = image.size.height * scale;
	CGRect imageRect = CGRectMake(
		(newSize.width - width)/2.0,
		(newSize.height - height)/2.0,
		width,
		height
	);

	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
	[image drawInRect: imageRect];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;

}

@end


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
