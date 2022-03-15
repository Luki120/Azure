#import "Sources/Views/VCSViews/PinCodeVCView.h"


@implementation PinCodeVCView {

	UILabel *issuerLabel;
	UILabel *secretHashLabel;

}

- (id)init {

	self = [super init];
	if(!self) return nil;

	[self setupUI];

	return self;

}


- (void)setupUI {

	pinCodesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	pinCodesTableView.backgroundColor = UIColor.systemBackgroundColor;
	pinCodesTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: pinCodesTableView];

	issuerStackView = [UIStackView new];
	secretHashStackView = [UIStackView new];
	[self createStackViewWithStackView: issuerStackView];
	[self createStackViewWithStackView: secretHashStackView];

	issuerLabel = [UILabel new];
	secretHashLabel = [UILabel new];
	[self createLabelWithLabel:issuerLabel withText: @"Issuer:" andTextColor: UIColor.labelColor];
	[self createLabelWithLabel:secretHashLabel withText: @"Secret hash:" andTextColor: UIColor.labelColor];

	issuerTextField = [UITextField new];
	secretTextField = [UITextField new];
	[self createTextFieldWithTextField:issuerTextField
		withPlaceholder:@"For example: GitHub"
		returnKeyType:UIReturnKeyNext
	];
	[self createTextFieldWithTextField:secretTextField
		withPlaceholder:@"Enter Secret"
		returnKeyType:UIReturnKeyDefault
	];

	[issuerTextField becomeFirstResponder];

	[issuerStackView addArrangedSubview: issuerLabel];
	[issuerStackView addArrangedSubview: issuerTextField];
	[secretHashStackView addArrangedSubview: secretHashLabel];
	[secretHashStackView addArrangedSubview: secretTextField];

	azToastView = [AzureToastView new];
	[self addSubview: azToastView];

	algorithmLabel = [UILabel new];
	[self createLabelWithLabel:algorithmLabel withText:nil andTextColor: UIColor.placeholderTextColor];
	algorithmLabel.textAlignment = NSTextAlignmentCenter;
	algorithmLabel.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void)layoutSubviews { [self layoutUI]; }


- (void)layoutUI {

	[pinCodesTableView.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;
	[pinCodesTableView.bottomAnchor constraintEqualToAnchor: self.bottomAnchor].active = YES;
	[pinCodesTableView.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[pinCodesTableView.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

	[azToastView.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant: -5].active = YES;
	[azToastView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor].active = YES;

}

// ! Reusable funcs

- (void)createStackViewWithStackView:(UIStackView *)stackView {

	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.spacing = 10;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;	

}


- (void)createLabelWithLabel:(UILabel *)label
	withText:(NSString *_Nullable)text
	andTextColor:(UIColor *)textColor {

	label.font = [UIFont systemFontOfSize: 14];
	label.text = text;
	label.textColor = textColor;

}


- (void)createTextFieldWithTextField:(UITextField *)textField
	withPlaceholder:(NSString *)placeholder
	returnKeyType:(UIReturnKeyType)returnKeyType {

	textField.font = [UIFont systemFontOfSize: 14];
	textField.placeholder = placeholder;
	textField.returnKeyType = returnKeyType;
	textField.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void)configureConstraintsForStackView:(UIStackView *)stackView
	andTextField:(UITextField *)textField
	forCell:(UITableViewCell *)cell {

	[stackView.leadingAnchor constraintEqualToAnchor: cell.contentView.leadingAnchor constant: 15].active = YES;
	[stackView.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
	[textField.widthAnchor constraintEqualToAnchor: cell.contentView.widthAnchor constant: -43].active = YES;
	[textField.heightAnchor constraintEqualToConstant: 44].active = YES;

}

@end
