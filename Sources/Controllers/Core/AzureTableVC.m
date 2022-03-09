#import "AzureTableVC.h"


@implementation AzureTableVC {

	AzureFloatingButtonView *azureFloatingButtonView;	
	AzureToastView *azureToastView;
	NSDictionary *imagesDict;
	UITableView *azureTableView;
	UILabel *placeholderLabel;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	// Custom initialization
	[self setupViews];
	[self setupObservers];
	[self setupImagesDict];

/*	[NSUserDefaults.standardUserDefaults removeObjectForKey: @"Issuers"];
	[NSUserDefaults.standardUserDefaults removeObjectForKey: @"Hashes"];
	[NSUserDefaults.standardUserDefaults removeObjectForKey: @"encryptionTypes"];*/

	[azureTableView registerClass: AzurePinCodeCell.class forCellReuseIdentifier: kIdentifier];

	return self;

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
		@"twitter": [UIImage imageNamed: @"Twitter"],
		@"zoho": [UIImage imageNamed: @"ZohoMail"]

	};

}


- (void)setupObservers {

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(purgeData) name:@"purgeDataDone" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(shouldMakeBackup) name:@"makeBackup" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(shouldReloadTableViewData) name:@"reloadData" object:nil];

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];

	/*--- Disabling the scrolling in the SwiftUI Form also
	likes to disable the scrolling in all the objC table views :KanyeWTF:
	so we gotta do a little forcing to reenable it :nfr: ---*/
	azureTableView.scrollEnabled = YES;

}


- (void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

	[azureTableView.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor].active = YES;
	[azureTableView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
	[azureTableView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor].active = YES;
	[azureTableView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor].active = YES;	

	[azureFloatingButtonView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -15].active = YES;
	[azureFloatingButtonView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor constant: -25].active = YES;
	[azureFloatingButtonView.widthAnchor constraintEqualToConstant: 60].active = YES;
	[azureFloatingButtonView.heightAnchor constraintEqualToConstant: 60].active = YES;

	[azureToastView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor constant: -5].active = YES;
	[azureToastView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;

	[placeholderLabel.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor].active = YES;
	[placeholderLabel.centerYAnchor constraintEqualToAnchor: self.view.centerYAnchor].active = YES;
	[placeholderLabel.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor constant: 10].active = YES;
	[placeholderLabel.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor constant: -10].active = YES;

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];
	azureTableView.backgroundColor = kUserInterfaceStyle ? UIColor.systemBackgroundColor : UIColor.secondarySystemBackgroundColor;

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if(scrollView.contentOffset.y >= self.view.safeAreaInsets.bottom + 60 
		|| scrollView.contentOffset.y <= self.view.safeAreaInsets.bottom - 22)

		[azureFloatingButtonView animateViewWithAlpha:0 translateX:1 translateY:100];

	else [azureFloatingButtonView animateViewWithAlpha:1 translateX:1 translateY:1];

}

// ! NSNotificationCenter

- (void)purgeData {

	[[TOTPManager sharedInstance] removeAllObjectsFromArrays];
	[azureTableView reloadData];

}


- (void)shouldMakeBackup {

	[UIView transitionWithView:self.tabBarController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{

		[self.tabBarController setSelectedIndex: 0];

	} completion:nil];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		if([TOTPManager sharedInstance]->secretHashesArray.count == 0) {
			[azureToastView fadeInOutToastViewWithMessage:@"Nothing to backup." finalDelay:0.5];
			return;
		}

		AuthManager *authManager = [AuthManager new];
		[authManager setupAuthWithReason:@"Azure needs you to authenticate in order to verify your identity for a sensitive operation."
			reply:^(BOOL success, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{ if(success) [self makeBackup]; });
			}

		];

	});

}


- (void)shouldReloadTableViewData { [azureTableView reloadData]; }

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	[self animateViewsWhenNecessary];
	return [TOTPManager sharedInstance]->secretHashesArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	AzurePinCodeCell *cell = [tableView dequeueReusableCellWithIdentifier: kIdentifier forIndexPath: indexPath];

	cell.delegate = self;
	cell.backgroundColor = UIColor.clearColor;

	cell->issuer = [TOTPManager sharedInstance]->issuersArray[indexPath.row];
	cell->hash = [TOTPManager sharedInstance]->secretHashesArray[indexPath.row];
	[cell setSecret: [TOTPManager sharedInstance]->secretHashesArray[indexPath.row]
		withAlgorithm: [[TOTPManager sharedInstance]->encryptionTypesArray count] == 0
		? kOTPGeneratorSHA1Algorithm 
		: [TOTPManager sharedInstance]->encryptionTypesArray[indexPath.row]
	];

	UIImage *image = imagesDict[cell->issuer.lowercaseString];
	UIImage *resizedImage = [UIImage resizeImageFromImage:image withSize: CGSizeMake(30, 30)];
	UIImage *placeholderImage = [UIImage systemImageNamed: @"photo"];

	cell->issuerImageView.image = image ? resizedImage : placeholderImage;
	cell->issuerImageView.tintColor = image ? nil : UIColor.labelColor;

//	[[TOTPManager sharedInstance]->issuersArray sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: YES];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
		title:@"Delete"
		handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

		NSString *message = [NSString stringWithFormat: @"You're about to delete the code for the issuer named %@ ❗❗. Are you sure you want to proceed? You'll have to set the code again if you wished to.", [TOTPManager sharedInstance]->issuersArray[indexPath.row]];

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:message preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

			[[TOTPManager sharedInstance] removeObjectAtIndexForArrays: indexPath.row];
			[azureTableView reloadData];

			completionHandler(YES);

		}];
		UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Oops" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

			completionHandler(YES);

		}];
		[alertController addAction: confirmAction];
		[alertController addAction: dismissAction];
		[self presentViewController:alertController animated:YES completion: nil];

	}];

	action.backgroundColor = kAzureMintTintColor;

	UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions: @[action]];
	return actions;

}

// ! AzureFloatingButtonViewDelegate

- (void)didTapFloatingButton {

	ModalSheetVC *modalSheetVC = [ModalSheetVC new];
	modalSheetVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:modalSheetVC animated:NO completion: nil];

}

// ! AzurePinCodeCellDelegate

- (void)didTapCell:(AzurePinCodeCell *)cell {

	[azureToastView fadeInOutToastViewWithMessage:@"Copied hash!" finalDelay:0.2];

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = cell->hash;

}


- (void)didTapInfoButton:(AzurePinCodeCell *)cell {

	NSString *message = [NSString stringWithFormat:@"Issuer: %@", cell->issuer];
	[azureToastView fadeInOutToastViewWithMessage:message finalDelay:0.2];

}

// ! Views

- (void)setupViews {

	azureTableView = [UITableView new];
	azureTableView.dataSource = self;
	azureTableView.delegate = self;
	azureTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	azureTableView.backgroundColor = kUserInterfaceStyle ? UIColor.systemBackgroundColor : UIColor.secondarySystemBackgroundColor;
	azureTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: azureTableView];

	azureFloatingButtonView = [AzureFloatingButtonView new];
	azureFloatingButtonView.delegate = self;
	[self.view addSubview: azureFloatingButtonView];

	azureToastView = [AzureToastView new];
	[self.view addSubview: azureToastView];

	placeholderLabel = [UILabel new];
	placeholderLabel.font = [UIFont systemFontOfSize: 16];
	placeholderLabel.text = @"No issuers were added yet. Tap the + button in order to add one.";
	placeholderLabel.textColor = UIColor.placeholderTextColor;
	placeholderLabel.numberOfLines = 0;
	placeholderLabel.textAlignment = NSTextAlignmentCenter;
	placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview: placeholderLabel];

//	[self setupSearchController];

}


- (void)setupSearchController {

	UISearchController *searchC = [[UISearchController alloc] initWithSearchResultsController: nil];
	searchC.searchBar.delegate = self;
	searchC.searchResultsUpdater = self;
	searchC.obscuresBackgroundDuringPresentation = NO;

	self.definesPresentationContext = YES;
	self.navigationItem.searchController = searchC;
	self.extendedLayoutIncludesOpaqueBars = YES;

}


- (void)animateViewsWhenNecessary {

	[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{

		if([TOTPManager sharedInstance]->secretHashesArray.count == 0) {
			azureTableView.alpha = 0;
			placeholderLabel.alpha = 1;
			placeholderLabel.transform = CGAffineTransformMakeScale(1, 1);
		}
		else {
			azureTableView.alpha = 1;
			placeholderLabel.alpha = 0;
			placeholderLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
		}

	} completion: nil];

}


- (void)makeBackup {

	BackupManager *backupManager = [BackupManager new];
	[backupManager constructJSONDictOutOfCurrentTableView:azureTableView
		withNumberOfRowsInSection:0
	];

	UIAlertController *successController = [UIAlertController alertControllerWithTitle:@"Azure" message:@"Do you want to view your backup in Filza now?" preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {	

		NSString *pathToFilza = [@"filza://view" stringByAppendingString: kAzurePath];
		NSURL *backupURLPath = [NSURL URLWithString: pathToFilza];
		[UIApplication.sharedApplication openURL:backupURLPath options:@{} completionHandler:nil];

	}];

	UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:nil];
	[successController addAction: confirmAction];
	[successController addAction: dismissAction];
	[self presentViewController:successController animated:YES completion:nil];

}

// ! UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

/*	NSString *searchedString = searchController.searchBar.text;
	[self updateWithFilteredContent: searchedString];
	[azureTableView reloadData];*/

}


- (void)updateWithFilteredContent:(NSString *)searchString {

/*	NSString *textToSearch = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", textToSearch];
	[[TOTPManager sharedInstance]->issuersArray filteredArrayUsingPredicate:thePredicate];*/

}

@end
