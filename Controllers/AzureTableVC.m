#import "AzureTableVC.h"


@implementation AzureTableVC {

	PinCodeVC *pinCodeVC;
	SettingsVC *settingsVC;
	UIButton *floatingCreateButton;
	UIView *copyPinToastView;
	UILabel *copiedPinLabel;
	NSLayoutConstraint *bottomAnchorConstraint;

}

- (id)init {

	self = [super init];

	if(self) {

		// Custom initialization

		[self setupViews];
		[self setupNavBarButton];

		pinCodeVC = [PinCodeVC new];
		pinCodeVC.delegate = self;

		[NSNotificationCenter.defaultCenter removeObserver:self];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fadeToast) name:@"fadeInOutToastDone" object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(purgeData) name:@"purgeDataDone" object:nil];

		[self.tableView registerClass: AzurePinCodeCell.class forCellReuseIdentifier: kIdentifier];

	}

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

 	[floatingCreateButton.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: - 20].active = YES;
	[floatingCreateButton.trailingAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.trailingAnchor constant: - 15].active = YES;
	[floatingCreateButton.widthAnchor constraintEqualToConstant: 60].active = YES;
	[floatingCreateButton.heightAnchor constraintEqualToConstant: 60].active = YES;

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];

	/*--- Disabling the scrolling in the SwiftUI Form also
	likes to disable the scrolling in all the objC table views :KayneWtf:
	so we gotta do a little forcing to reenable it :nfr: ---*/

	self.tableView.scrollEnabled = YES;

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];

	floatingCreateButton.layer.shadowColor = kUserInterfaceStyle ? UIColor.whiteColor.CGColor : UIColor.blackColor.CGColor;
	settingsVC.navigationController.navigationBar.barTintColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;

}


- (void)setupNavBarButton {

	UIImageSymbolConfiguration *settingsConfig = [UIImageSymbolConfiguration configurationWithPointSize: 15];
	UIImage *settingsImage = [UIImage systemImageNamed: @"gear" withConfiguration: settingsConfig];

	UIBarButtonItem *settingsButtonItem = [[UIBarButtonItem alloc] 
		initWithImage:settingsImage
		style:UIBarButtonItemStylePlain
		target:self
		action:@selector(didTapSettingsButton)
	];

	self.navigationItem.rightBarButtonItem = settingsButtonItem;

}


- (void)didTapSettingsButton {

	settingsVC = [SettingsVC new];
	UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController: settingsVC];

	settingsVC.title = @"Settings";
	settingsVC.navigationController.navigationBar.translucent = NO;
	settingsVC.navigationController.navigationBar.barTintColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;

	[self presentViewController:navVC animated:YES completion:nil];

}


- (void)setupViews {

	floatingCreateButton = [UIButton new];
	floatingCreateButton.tintColor = UIColor.labelColor;
	floatingCreateButton.backgroundColor = kAzureTintColor;
	floatingCreateButton.layer.shadowColor = kUserInterfaceStyle ? UIColor.whiteColor.CGColor : UIColor.blackColor.CGColor;
	floatingCreateButton.layer.cornerRadius = 30;
	floatingCreateButton.layer.shadowRadius = 8;
	floatingCreateButton.layer.shadowOffset = CGSizeMake(0, 1);
	floatingCreateButton.layer.shadowOpacity = 0.5;
	floatingCreateButton.translatesAutoresizingMaskIntoConstraints = NO;
	[floatingCreateButton setImage: [UIImage systemImageNamed:@"plus" withConfiguration: [UIImageSymbolConfiguration configurationWithPointSize: 25]] forState: UIControlStateNormal];
	[floatingCreateButton addTarget:self action:@selector(didTapFloatingButton) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: floatingCreateButton];

	copyPinToastView = [UIView new];
	copyPinToastView.alpha = 0;
	copyPinToastView.backgroundColor = kAzureTintColor;
	copyPinToastView.layer.cornerCurve = kCACornerCurveContinuous;
	copyPinToastView.layer.cornerRadius = 20;
	copyPinToastView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: copyPinToastView];

	copiedPinLabel = [UILabel new];
	copiedPinLabel.font = [UIFont systemFontOfSize: 14];
	copiedPinLabel.text = @"Copied!";
	copiedPinLabel.textColor = UIColor.labelColor;
	copiedPinLabel.textAlignment = NSTextAlignmentCenter;
	copiedPinLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[copyPinToastView addSubview: copiedPinLabel];

	[copyPinToastView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;
	bottomAnchorConstraint = [copyPinToastView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant : 50];
	bottomAnchorConstraint.active = YES;
	[copyPinToastView.widthAnchor constraintEqualToConstant: 120].active = YES;
	[copyPinToastView.heightAnchor constraintEqualToConstant: 40].active = YES;

	[copiedPinLabel.centerXAnchor constraintEqualToAnchor: copyPinToastView.centerXAnchor].active = YES;
	[copiedPinLabel.centerYAnchor constraintEqualToAnchor: copyPinToastView.centerYAnchor].active = YES;

}


- (void)didTapFloatingButton {


	UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController: pinCodeVC];

	pinCodeVC.title = @"Add Pin Code";
	pinCodeVC.navigationController.navigationBar.translucent = NO;
	pinCodeVC.navigationController.navigationBar.barTintColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;

	UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] 
		initWithTitle:@"Create"
		style:UIBarButtonItemStylePlain
		target:self
		action:@selector(didTapCreateButton)
	];

	pinCodeVC.navigationItem.rightBarButtonItem = createButtonItem;

	[self presentViewController:navVC animated:YES completion:nil];

}


- (void)didTapCreateButton {

	[NSNotificationCenter.defaultCenter postNotificationName: @"checkIfDataShouldBeSaved" object: nil];

}


- (void)fadeToast {

	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

		bottomAnchorConstraint.constant = -20;
		copyPinToastView.alpha = 1;

		[self.view layoutIfNeeded];

	} completion:^(BOOL finished) {

		[UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseIn animations:^{

			CATransform3D rotation = CATransform3DIdentity;
 			rotation.m34 = 1.0 / - 500; // idfk what this does but ok :lul:
			rotation = CATransform3DRotate(rotation, 360.0 * M_PI / 360, 0, 1, 0);
			copyPinToastView.layer.transform = rotation;
			copiedPinLabel.layer.transform = rotation;

			[self.view layoutIfNeeded];

		} completion:^(BOOL finished) {

			[UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{

				bottomAnchorConstraint.constant = 50;
				copyPinToastView.alpha = 0;

				[self.view layoutIfNeeded];

			} completion:^(BOOL finished) {

				copyPinToastView.layer.transform = CATransform3DIdentity;
				copiedPinLabel.layer.transform = CATransform3DIdentity;

			}];

		}];

	}];

}


// MARK: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [TOTPManager sharedInstance]->secretHashesArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	AzurePinCodeCell *cell = [tableView dequeueReusableCellWithIdentifier: kIdentifier forIndexPath: indexPath];

	cell.delegate = self;
	cell.backgroundColor = UIColor.clearColor;

 	cell->issuer = [TOTPManager sharedInstance]->issuersArray[indexPath.row];
	cell->hash = [TOTPManager sharedInstance]->secretHashesArray[indexPath.row];

	[cell setSecret: [TOTPManager sharedInstance]->secretHashesArray[indexPath.row]];

	return cell;

}


// MARK: UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

		[[TOTPManager sharedInstance]->issuersArray removeObjectAtIndex: indexPath.row];
		[[TOTPManager sharedInstance]->secretHashesArray removeObjectAtIndex: indexPath.row];
		[self.tableView reloadData];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject: [TOTPManager sharedInstance]->issuersArray forKey: @"Issuers"];
		[defaults setObject: [TOTPManager sharedInstance]->secretHashesArray forKey: @"Hashes"];

		completionHandler(YES);

	}];

	action.backgroundColor = kAzureTintColor;

	UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions: @[action]];

	return actions;

}


// MARK: AzurePinCodeCellDelegate

- (void)didTapInfoButton:(AzurePinCodeCell *)cell {

	NSString *message = [NSString stringWithFormat: @"Issuer: %@ \nSecret hash: %@", cell->issuer, cell->hash];

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:message preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil];

	[alertController addAction: dismissAction];

	[self presentViewController:alertController animated:YES completion: nil];

}


// MARK: PinCodeVCDelegate

- (void)shouldDismissVC {

	[self.tableView reloadData];

	[self dismissViewControllerAnimated:YES completion:nil];

}


- (void)purgeData {

	[[TOTPManager sharedInstance]->issuersArray removeAllObjects];
	[[TOTPManager sharedInstance]->secretHashesArray removeAllObjects];
	[self.tableView reloadData];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [TOTPManager sharedInstance]->issuersArray forKey: @"Issuers"];
	[defaults setObject: [TOTPManager sharedInstance]->secretHashesArray forKey: @"Hashes"];

}


@end
