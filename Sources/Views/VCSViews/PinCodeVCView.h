#import "Sources/Views/UI/AzureToastView.h"


@interface PinCodeVCView : UIView {

	@public UIStackView *issuerStackView;
	@public UIStackView *secretHashStackView;
	@public UILabel *algorithmLabel;
	@public UITextField *issuerTextField;
	@public UITextField *secretTextField;
	@public UITableView *pinCodesTableView;
	@public AzureToastView *azToastView;

}
- (id)initWithDataSource:(id<UITableViewDataSource>)dataSource
	tableViewDelegate:(id<UITableViewDelegate>)delegate
	textFieldsDelegate:(id<UITextFieldDelegate>)textFieldsDelegate;
- (void)configureConstraintsForStackView:(UIStackView *)stackView
	andTextField:(UITextField *)textField
	forCell:(UITableViewCell *)cell;
@end
