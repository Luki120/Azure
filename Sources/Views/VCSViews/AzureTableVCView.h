#import "Azure-Swift.h"
#import "Sources/Managers/Singletons/TOTPManager.h"


@interface AzureTableVCView : UIView {

	@public AzureFloatingButtonView *azureFloatingButtonView;
	@public AzureToastView *azureToastView;
	@public UITableView *azureTableView;

}
- (id)initWithDataSource:(id<UITableViewDataSource>)dataSource
	tableViewDelegate:(id<UITableViewDelegate>)delegate
	floatingButtonViewDelegate:(id<AzureFloatingButtonViewDelegate>)buttonDelegate;
- (void)animateViewsWhenNecessary;
@end
