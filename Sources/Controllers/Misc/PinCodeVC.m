#import "PinCodeVC.h"


@implementation PinCodeVC {

	UIStackView *issuerStackView;
	UIStackView *secretHashStackView;
	UILabel *issuerLabel;
	UILabel *secretHashLabel;
	UITextField *issuerTextField;
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
	[self createStackViewWithStackView: issuerStackView];

	issuerLabel = [UILabel new];
	[self createLabelWithLabel:issuerLabel withText: @"Issuer:"];
	[issuerStackView addArrangedSubview: issuerLabel];

	issuerTextField = [UITextField new];
	[self createTextFieldWithTextField:issuerTextField
		withPlaceholder:@"For example: GitHub"
		returnKeyType:UIReturnKeyNext
	];
	[issuerStackView addArrangedSubview: issuerTextField];

	secretHashStackView = [UIStackView new];
	[self createStackViewWithStackView: secretHashStackView];

	secretHashLabel = [UILabel new];
	[self createLabelWithLabel:secretHashLabel withText: @"Secret hash:"];
	[secretHashStackView addArrangedSubview: secretHashLabel];

	secretTextField = [UITextField new];
	[self createTextFieldWithTextField:secretTextField
		withPlaceholder:@"Enter Secret"
		returnKeyType:UIReturnKeyDefault
	];
	[secretHashStackView addArrangedSubview: secretTextField];

	azToastView = [AzureToastView new];
	[self.view addSubview: azToastView];

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

	if(issuerTextField.text.length > 0 && secretTextField.text.length > 0) {

		[[TOTPManager sharedInstance]->issuersArray addObject: issuerTextField.text];
		[[TOTPManager sharedInstance]->secretHashesArray addObject: secretTextField.text];
		[[TOTPManager sharedInstance] saveDefaults];

		[self.delegate shouldDismissVC];

		issuerTextField.text = @"";
		secretTextField.text = @"";

	}

	else {

		azToastView->toastViewLabel.text = @"Fill out both forms!";
		[azToastView fadeInOutToastViewWithFinalDelay: 1.5];

	}

}

// ! Reusable funcs

- (void)createStackViewWithStackView:(UIStackView *)stackView {

	stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.spacing = 10;
	stackView.distribution = UIStackViewDistributionFill;
	stackView.translatesAutoresizingMaskIntoConstraints = NO;	

}


- (void)createLabelWithLabel:(UILabel *)label withText:(NSString *)text {

	label.font = [UIFont systemFontOfSize: 14];
	label.text = text;
	label.textColor = UIColor.labelColor;

}


- (void)createTextFieldWithTextField:(UITextField *)textField
	withPlaceholder:(NSString *)placeholder
	returnKeyType:(UIReturnKeyType)returnKeyType {

	textField.font = [UIFont systemFontOfSize: 14];
	textField.delegate = self;
	textField.placeholder = placeholder;
	textField.returnKeyType = returnKeyType;

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
			[issuerStackView.leadingAnchor constraintEqualToAnchor: cell.contentView.leadingAnchor constant: 15].active = YES;
			[issuerStackView.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
			break;

		case 1:

			[cell.contentView addSubview: secretHashStackView];
			[secretHashStackView.leadingAnchor constraintEqualToAnchor: cell.contentView.leadingAnchor constant: 15].active = YES;
			[secretHashStackView.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
			break;

		case 2:

			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.font = [UIFont systemFontOfSize: 14];
			cell.textLabel.text = @"Algorithm";
			break;

	}

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	if(indexPath.row != 2) return;

	[NSNotificationCenter.defaultCenter postNotificationName:@"pushAlgorithmVC" object:nil];

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
