#import "PinCodeVC.h"


@implementation PinCodeVC {

	UIStackView *issuerStackView;
	UIStackView *secretHashStackView;
	UILabel *issuerLabel;
	UILabel *secretHashLabel;
	UITextField *issuerTextField;
	UITextField *secretTextField;
	UITableView *pinCodesTableView;

}

- (id)init {

	self = [super init];

	if(self) {

		[self setupUI];

		[pinCodesTableView registerClass: UITableViewCell.class forCellReuseIdentifier: @"Cell"];

		[NSNotificationCenter.defaultCenter removeObserver: self];
		[NSNotificationCenter.defaultCenter addObserver: self selector: @selector(shouldSaveData) name: @"checkIfDataShouldBeSaved" object: nil];

	}

	return self;

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

	[self layoutUI];

}


- (void)setupUI {

	pinCodesTableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
	pinCodesTableView.dataSource = self;
	pinCodesTableView.delegate = self;
	pinCodesTableView.scrollEnabled = YES;
	pinCodesTableView.backgroundColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;
	pinCodesTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: pinCodesTableView];

	issuerStackView = [UIStackView new];
	issuerStackView.axis = UILayoutConstraintAxisHorizontal;
	issuerStackView.spacing = 10;
	issuerStackView.distribution = UIStackViewDistributionFill;
	issuerStackView.translatesAutoresizingMaskIntoConstraints = NO;

	issuerLabel = [UILabel new];
	issuerLabel.font = [UIFont systemFontOfSize: 14];
	issuerLabel.text = @"Issuer:";
	issuerLabel.textColor = UIColor.labelColor;
	[issuerStackView addArrangedSubview: issuerLabel];

	issuerTextField = [UITextField new];
	issuerTextField.font = [UIFont systemFontOfSize: 14];
	issuerTextField.delegate = self;
	issuerTextField.textColor = UIColor.labelColor;
	issuerTextField.placeholder = @"For example: GitHub";
	issuerTextField.returnKeyType = UIReturnKeyNext;
	[issuerStackView addArrangedSubview: issuerTextField];

	secretHashStackView = [UIStackView new];
	secretHashStackView.axis = UILayoutConstraintAxisHorizontal;
	secretHashStackView.spacing = 10;
	secretHashStackView.distribution = UIStackViewDistributionFill;
	secretHashStackView.translatesAutoresizingMaskIntoConstraints = NO;

	secretHashLabel = [UILabel new];
	secretHashLabel.font = [UIFont systemFontOfSize: 14];
	secretHashLabel.text = @"Secret hash:";
	secretHashLabel.textColor = UIColor.labelColor;
	[secretHashStackView addArrangedSubview: secretHashLabel];

	secretTextField = [UITextField new];
	secretTextField.font = [UIFont systemFontOfSize: 14];
	secretTextField.delegate = self;
	secretTextField.placeholder = @"Enter Secret";
	[secretHashStackView addArrangedSubview: secretTextField];

}


- (void)layoutUI {

	[pinCodesTableView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
	[pinCodesTableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
	[pinCodesTableView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[pinCodesTableView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;

}


// MARK: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 2;

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

	}

	return cell;

}


// MARK: UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];

}


// MARK: UITextFieldDelegate

 - (BOOL)textFieldShouldReturn:(UITextField *)textField {

	if(textField == issuerTextField) {

		[textField resignFirstResponder];
		[secretTextField becomeFirstResponder];

	}

	else [textField resignFirstResponder];

	return YES;

}


// MARK: NSNotificationCenter

- (void)shouldSaveData {

	if(issuerTextField.text.length > 0 && secretTextField.text.length > 0) {

		[[TOTPManager sharedInstance]->issuersArray addObject: issuerTextField.text];
		[[TOTPManager sharedInstance]->secretHashesArray addObject: secretTextField.text];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject: [TOTPManager sharedInstance]->issuersArray forKey: @"Issuers"];
		[defaults setObject: [TOTPManager sharedInstance]->secretHashesArray forKey: @"Hashes"];

		[self.delegate shouldDismissVC];

		issuerTextField.text = @"";
		secretTextField.text = @"";

	}

	else {

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message: @"Please fill out both forms." preferredStyle: UIAlertControllerStyleAlert];

		UIAlertAction *dismissAction = [UIAlertAction actionWithTitle: @"Got it" style: UIAlertActionStyleDefault handler: nil];

		[alertController addAction: dismissAction];

		[self presentViewController: alertController animated: YES completion: nil];

	}

}


@end
