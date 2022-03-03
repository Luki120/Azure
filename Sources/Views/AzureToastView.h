#import "Sources/Categories/UIView+Animations.h"
#import "Sources/Constants/Constants.h"


@interface AzureToastView : UIView {

	@public UILabel *toastViewLabel;

}
- (void)fadeInOutToastViewWithFinalDelay:(CGFloat)delay;
- (void)animateToastViewWithConstraintConstant:(CGFloat)constant andAlpha:(CGFloat)alpha;
@end
