#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/UI/AzureFloatingButtonView.h"
#import "Sources/Views/UI/AzureToastView.h"


@interface AzureTableVCView : UIView {

	@public AzureFloatingButtonView *azureFloatingButtonView;
	@public AzureToastView *azureToastView;
	@public UITableView *azureTableView;

}
- (void)animateViewsWhenNecessary;
@end
