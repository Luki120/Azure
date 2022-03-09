#import "PinCodeVC.h"


@implementation PinCodeVC {

	UIStackView *issuerStackView;
	UIStackView *secretHashStackView;
	UILabel *issuerLabel;
	UILabel *secretHashLabel;
	UILabel *algorithmLabel;
	UITextField *issuerTextField;
	UITextField *secretTextField;
	UITableView *pinCodesTableView;
	AzureToastView *azToastView;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	[self setupUI];
	[pinCodesTableView registerClass: UITableViewCell.class forCellReuseIdentifier: @"Cell"];

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(shouldSaveData) name:@"checkIfDataShouldBeSaved" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateAlgorithmLabel:) name:@"updateAlgorithmLabel" object:nil];

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];
	[self layoutUI];

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];
	pinCodesTableView.scrollEnabled = YES;

}


- (void)setupUI {

	pinCodesTableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
	pinCodesTableView.dataSource = self;
	pinCodesTableView.delegate = self;
	pinCodesTableView.backgroundColor = UIColor.systemBackgroundColor;
	pinCodesTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: pinCodesTableView];

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

	[issuerStackView addArrangedSubview: issuerLabel];
	[issuerStackView addArrangedSubview: issuerTextField];
	[secretHashStackView addArrangedSubview: secretHashLabel];
	[secretHashStackView addArrangedSubview: secretTextField];

	azToastView = [AzureToastView new];
	[self.view addSubview: azToastView];

	algorithmLabel = [UILabel new];
	[self createLabelWithLabel:algorithmLabel withText:nil andTextColor: UIColor.placeholderTextColor];
	algorithmLabel.textAlignment = NSTextAlignmentCenter;
	algorithmLabel.translatesAutoresizingMaskIntoConstraints = NO;

	[self configureAlgorithmLabelWithSelectedRow: [TOTPManager sharedInstance]->selectedRow];

	[issuerTextField becomeFirstResponder];

}


- (void)configureAlgorithmLabelWithSelectedRow:(NSInteger)selectedRow {

	switch(selectedRow) {
		case 0: algorithmLabel.text = @"SHA1"; break;
		case 1: algorithmLabel.text = @"SHA256"; break;
		case 2: algorithmLabel.text = @"SHA512"; break;
	}

}


- (void)updateAlgorithmLabel:(NSNotification *)notification {

	NSDictionary *userInfoDict = notification.userInfo;
	NSInteger selectedRow = [[userInfoDict objectForKey: @"selectedRow"] integerValue];
	[self configureAlgorithmLabelWithSelectedRow: selectedRow];

}


- (void)layoutUI {

	[pinCodesTableView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
	[pinCodesTableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
	[pinCodesTableView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[pinCodesTableView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;

	[azToastView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -5].active = YES;
	[azToastView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;

}

// ! NSNotificationCenter

- (void)shouldSaveData {

	if(issuerTextField.text.length <= 0 || secretTextField.text.length <= 0) {
		[azToastView fadeInOutToastViewWithMessage:@"Fill out both forms." finalDelay: 1.5];
		return;
	}

	[[TOTPManager sharedInstance] feedIssuersArrayWithObject:issuerTextField.text
		andSecretHashesArray:secretTextField.text
	];

	[self.delegate shouldDismissVC];

	issuerTextField.text = @"";
	secretTextField.text = @"";

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
	textField.delegate = self;
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

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 3;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [pinCodesTableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
	cell.backgroundColor = UIColor.clearColor;

	switch(indexPath.row) {

		case 0:

			[cell.contentView addSubview: issuerStackView];
			[self configureConstraintsForStackView:issuerStackView andTextField:issuerTextField forCell:cell];
			break;

		case 1:

			[cell.contentView addSubview: secretHashStackView];
			[self configureConstraintsForStackView:secretHashStackView andTextField:secretTextField forCell:cell];
			break;

		case 2:

			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.font = [UIFont systemFontOfSize: 14];
			cell.textLabel.text = @"Algorithm";

			[cell.contentView addSubview: algorithmLabel];
			[algorithmLabel.trailingAnchor constraintEqualToAnchor: cell.contentView.trailingAnchor constant: -20].active = YES;
			[algorithmLabel.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
			break;

	}

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	if(indexPath.row != 2) return;

	[self.delegate pushAlgorithmVC];

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
