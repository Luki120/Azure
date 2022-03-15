#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/AzureFloatingButtonView.h"
#import "Sources/Views/AzureToastView.h"


@interface AzureTableVCView : UIView {

	@public AzureFloatingButtonView *azureFloatingButtonView;
	@public AzureToastView *azureToastView;
	@public UITableView *azureTableView;

}
- (void)animateViewsWhenNecessary;
@end
