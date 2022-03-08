#import "Sources/Categories/UIView+Animations.h"
#import "Sources/Constants/Constants.h"


@interface AzureToastView : UIView
- (void)fadeInOutToastViewWithMessage:(NSString *)message finalDelay:(CGFloat)delay;
@end
