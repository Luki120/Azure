#import "Constants/Constants.h"


@protocol AzureFloatingButtonViewDelegate <NSObject>

@required - (void)didTapFloatingButton;

@end


@interface AzureFloatingButtonView : UIView
@property (nonatomic, strong) UIButton *floatingCreateButton;
@property (nonatomic, weak) id <AzureFloatingButtonViewDelegate> delegate;
@end
