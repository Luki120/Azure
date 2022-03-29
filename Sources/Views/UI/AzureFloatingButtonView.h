#import "Sources/Categories/Categories.h"
#import "Sources/Constants/Constants.h"


@protocol AzureFloatingButtonViewDelegate <NSObject>

@required
- (void)azureFloatingButtonViewDidTapFloatingButton;

@end


@interface AzureFloatingButtonView : UIView
@property (nonatomic, weak) id <AzureFloatingButtonViewDelegate> delegate;
- (void)animateViewWithAlpha:(CGFloat)alpha translateX:(CGFloat)tx translateY:(CGFloat)ty;
@end
