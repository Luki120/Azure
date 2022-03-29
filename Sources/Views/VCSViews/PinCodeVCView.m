#import "PinCodeVCView.h"


@interface PinCodeVCView () <UITextFieldDelegate>
@end


@implementation PinCodeVCView {

	UILabel *issuerLabel;
	UILabel *secretHashLabel;

}

- (id)initWithDataSource:(id<UITableViewDataSource>)dataSource
	tableViewDelegate:(id<UITableViewDelegate>)delegate {

	self = [super init];
	if(!self) return nil;

	[self setupUI];
	pinCodesTableView.dataSource = dataSource;
	pinCodesTableView.delegate = delegate;

	return self;

}


- (void)layoutSubviews {

	[super layoutSubviews];
	[self layoutUI];

}


- (void)setupUI {

	pinCodesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	pinCodesTableView.backgroundColor = UIColor.systemBackgroundColor;
	[self addSubview: pinCodesTableView];

	issuerStackView = [self setupStackView];
	secretHashStackView = [self setupStackView];

	issuerLabel = [self createLabelWithText:@"Issuer:" textColor: UIColor.labelColor];
	secretHashLabel = [self createLabelWithText:@"Secret hash:" textColor: UIColor.labelColor];

	issuerTextField = [self createTextFieldWithPlaceholder:@"For example: GitHub" returnKeyType:UIReturnKeyNext];
	secretTextField = [self createTextFieldWithPlaceholder:@"Enter Secret" returnKeyType:UIReturnKeyDefault];

	[issuerTextField becomeFirstResponder];

	[issuerStackView addArrangedSubview: issuerLabel];
	[issuerStackView addArrangedSubview: issuerTextField];
	[secretHashStackView addArrangedSubview: secretHashLabel];
	[secretHashStackView addArrangedSubview: secretTextField];

	azToastView = [AzureToastView new];
	[self addSubview: azToastView];

	algorithmLabel = [self createLabelWithText:nil textColor: UIColor.placeholderTextColor];
	algorithmLabel.textAlignment = NSTextAlignmentCenter;
	algorithmLabel.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void)layoutUI {

	[self pinViewToAllEdges: pinCodesTableView];
	[self pinAzureToastToTheBottomCenteredOnTheXAxis:azToastView bottomConstant: -5];

}

// ! Reusable funcs

- (UILabel *)createLabelWithText:(NSString *_Nullable)text textColor:(UIColor *)textColor {

	UILabel *label = [UILabel new];
	label.font = [UIFont systemFontOfSize: 14];
	label.text = text;
	label.textColor = textColor;
	return label;

}


- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder
	returnKeyType:(UIReturnKeyType)returnKeyType {

	UITextField *textField = [UITextField new];
	textField.font = [UIFont systemFontOfSize: 14];
	textField.delegate = self;
	textField.placeholder = placeholder;
	textField.returnKeyType = returnKeyType;
	textField.translatesAutoresizingMaskIntoConstraints = NO;
	return textField;

}


- (UIStackView *)setupStackView {

	UIStackView *stackView = [UIStackView new];
	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.spacing = 10;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;	
	return stackView;

}


- (void)configureConstraintsForStackView:(UIStackView *)stackView
	forTextField:(UITextField *)textField
	forCell:(UITableViewCell *)cell {

	[stackView.leadingAnchor constraintEqualToAnchor: cell.contentView.leadingAnchor constant: 15].active = YES;
	[stackView.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
	[textField.widthAnchor constraintEqualToAnchor: cell.contentView.widthAnchor constant: -43].active = YES;
	[textField.heightAnchor constraintEqualToConstant: 44].active = YES;

}

// ! UITextFieldDelegate

 - (BOOL)textFieldShouldReturn:(UITextField *)textField {

	if(textField == issuerTextField) {
		[textField resignFirstResponder];
		[secretTextField becomeFirstResponder];
	}

	else [textField resignFirstResponder];

	return YES;

}

@end
