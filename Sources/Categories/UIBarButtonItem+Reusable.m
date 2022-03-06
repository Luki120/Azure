#import "Sources/Categories/UIBarButtonItem+Reusable.h"


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
