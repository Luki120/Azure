#import "AzureTableVC.h"


@implementation AzureTableVC {

	AzureFloatingButtonView *azureFloatingButtonView;	
	AzureToastView *azureToastView;
	NSLayoutConstraint *bottomAnchorConstraint;
	NSDictionary *imagesDict;
	PinCodeVC *pinCodeVC;
	QRCodeVC *qrCodeVC;
	UINavigationController *navVC;
	UITableView *azureTableView;

}

// ! Lifecycle

- (id)init {

	self = [super init];

	if(!self) return nil;

	// Custom initialization
	[self setupViews];
	[self setupObservers];
	[self setupImagesDict];

	qrCodeVC = [QRCodeVC new];
	pinCodeVC = [PinCodeVC new];
	pinCodeVC.delegate = self;

	[azureTableView registerClass: AzurePinCodeCell.class forCellReuseIdentifier: kIdentifier];

	return self;

}


- (void)setupViews {

	azureTableView = [UITableView new];
	azureTableView.dataSource = self;
	azureTableView.delegate = self;
	azureTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	azureTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: azureTableView];

	azureFloatingButtonView = [AzureFloatingButtonView new];
	azureFloatingButtonView.delegate = self;
	[self.view addSubview: azureFloatingButtonView];

	azureToastView = [AzureToastView new];
	[self.view addSubview: azureToastView];

}


- (void)setupObservers {

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(purgeData) name:@"purgeDataDone" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fillOutHash) name:@"qrCodeScanDone" object:nil];

}


- (void)setupImagesDict {

	imagesDict = @{

		@"dashlane": [UIImage imageNamed: @"Dashlane"],
		@"discord": [UIImage imageNamed: @"Discord"],
		@"facebook": [UIImage imageNamed: @"Facebook"],
		@"github": [UIImage imageNamed: @"GitHub"],
		@"instagram": [UIImage imageNamed: @"Instagram"],
		@"kraken": [UIImage imageNamed: @"Kraken"],
		@"snapchat": [UIImage imageNamed: @"Snapchat"],
		@"paypal": [UIImage imageNamed: @"PayPal"],
		@"twitter": [UIImage imageNamed: @"Twitter"]

	};

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

	[azureTableView.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor].active = YES;
	[azureTableView.bottomAnchor constraintEqualToAnchor: azureFloatingButtonView.topAnchor constant: -15].active = YES;
	[azureTableView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[azureTableView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;	

	[azureFloatingButtonView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -15].active = YES;
	[azureFloatingButtonView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor constant: -25].active = YES;
	[azureFloatingButtonView.widthAnchor constraintEqualToConstant: 60].active = YES;
	[azureFloatingButtonView.heightAnchor constraintEqualToConstant: 60].active = YES;

	[azureToastView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -5].active = YES;
	[azureToastView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];

	/*--- Disabling the scrolling in the SwiftUI Form also
	likes to disable the scrolling in all the objC table views :KanyeWTF:
	so we gotta do a little forcing to reenable it :nfr: ---*/

	azureTableView.scrollEnabled = YES;

}


// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [TOTPManager sharedInstance]->secretHashesArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	AzurePinCodeCell *cell = [tableView dequeueReusableCellWithIdentifier: kIdentifier forIndexPath: indexPath];

	cell.delegate = self;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = UIColor.clearColor;

	cell->issuer = [TOTPManager sharedInstance]->issuersArray[indexPath.row];
	cell->hash = [TOTPManager sharedInstance]->secretHashesArray[indexPath.row];
	[cell setSecret: [TOTPManager sharedInstance]->secretHashesArray[indexPath.row]];

	UIImage *image = imagesDict[cell->issuer.lowercaseString];
	UIImage *resizedImage = [UIImage resizeImageFromImage:image withSize: CGSizeMake(30, 30)];
	UIImage *placeholderImage = [UIImage systemImageNamed: @"photo"];

	cell->issuerImageView.image = image ? resizedImage : placeholderImage;
	cell->issuerImageView.tintColor = image ? nil : UIColor.labelColor;

	return cell;

}


// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

		NSString *message = [NSString stringWithFormat: @"You're about to delete the code for the issuer named %@ ❗❗. Are you sure you want to proceed? You'll have to set the code again if you wished to.", [TOTPManager sharedInstance]->issuersArray[indexPath.row]];

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:message preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

			[[TOTPManager sharedInstance]->issuersArray removeObjectAtIndex: indexPath.row];
			[[TOTPManager sharedInstance]->secretHashesArray removeObjectAtIndex: indexPath.row];
			[azureTableView reloadData];

			[[TOTPManager sharedInstance] saveDefaults];

			completionHandler(YES);

		}];
		UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Oops" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

			completionHandler(NO);

		}];
		[alertController addAction: confirmAction];
		[alertController addAction: dismissAction];
		[self presentViewController:alertController animated:YES completion: nil];

	}];

	action.backgroundColor = kAzureTintColor;

	UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions: @[action]];

	return actions;

}


// ! NSNotificationCenter

- (void)purgeData {

	[[TOTPManager sharedInstance]->issuersArray removeAllObjects];
	[[TOTPManager sharedInstance]->secretHashesArray removeAllObjects];
	[azureTableView reloadData];

	[[TOTPManager sharedInstance] saveDefaults];

}


- (void)fillOutHash {

	pinCodeVC->secretTextField.text = [UIPasteboard generalPasteboard].string;
	pinCodeVC->secretTextField.secureTextEntry = YES;

	pinCodeVC.title = @"Add Pin Code";
	pinCodeVC.navigationItem.rightBarButtonItem = [self getCreateButtonItem];
	[navVC pushViewController: pinCodeVC animated: YES];

}


// ! Buttons

- (UIBarButtonItem *)getCreateButtonItem {

	UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc]
		initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]
		style:UIBarButtonItemStyleDone
		target:self
		action:@selector(didTapCreateButton)
	];

	return createButtonItem;

}


- (void)didTapComposeButton {

	pinCodeVC.title = @"Add Pin Code";
	pinCodeVC.navigationItem.rightBarButtonItem = [self getCreateButtonItem];
	[navVC pushViewController: pinCodeVC animated: YES];

}


- (void)didTapCreateButton {

	[NSNotificationCenter.defaultCenter postNotificationName: @"checkIfDataShouldBeSaved" object: nil];

}


- (void)didTapDismissButton {

	[self dismissViewControllerAnimated:YES completion:nil];

}


// ! AzureFloatingButtonViewDelegate

- (void)didTapFloatingButton {

	navVC = [[UINavigationController alloc] initWithRootViewController: qrCodeVC];

	qrCodeVC.title = @"Scan QR Code";
	qrCodeVC.navigationController.navigationBar.translucent = NO;
	qrCodeVC.navigationController.navigationBar.barTintColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;

	UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]
		initWithImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
		style:UIBarButtonItemStyleDone
		target:self
		action:@selector(didTapDismissButton)
	];

	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] 
		initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
		target:self
		action:@selector(didTapComposeButton)
	];

	qrCodeVC.navigationItem.leftBarButtonItem = leftButtonItem;
	qrCodeVC.navigationItem.rightBarButtonItem = rightButtonItem;
	navVC.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:navVC animated:YES completion:nil];

}


// ! AzurePinCodeCellDelegate

- (void)didTapInfoButton:(AzurePinCodeCell *)cell {

	NSString *message = [NSString stringWithFormat: @"Issuer: %@ \nSecret hash: %@", cell->issuer, cell->hash];

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil];
	[alertController addAction: dismissAction];
	[self presentViewController:alertController animated:YES completion: nil];

}


// ! PinCodeVCDelegate

- (void)shouldDismissVC {

	[azureTableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if(scrollView.contentOffset.y >= self.view.safeAreaInsets.bottom + 60)

		[azureFloatingButtonView animateViewWithAlpha:0 translateX:100 translateY:0];

	else [azureFloatingButtonView animateViewWithAlpha:1 translateX:1 translateY:1];

}

@end
