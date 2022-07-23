#import "AzureTableVC.h"


@interface AzureTableVC () <AzureFloatingButtonViewDelegate, AzurePinCodeCellDelegate, ModalSheetVCDelegate, UIPopoverPresentationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>
@end


@implementation AzureTableVC {

	BOOL isFiltered;
	NSMutableArray *filteredArray;
	AzureTableVCView *azureTableVCView;
	AuthManager *authManager;
	BackupManager *backupManager;
	ModalSheetVC *modalSheetVC;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	// Custom initialization
	[self setupMainView];
	[self setupObservers];
	[self setupSearchController];

	authManager = [AuthManager new];
	backupManager = [BackupManager new];
	[azureTableVCView->azureTableView registerClass:AzurePinCodeCell.class forCellReuseIdentifier:kIdentifier];

	return self;

}


- (void)setupMainView {

	azureTableVCView = [[AzureTableVCView alloc] initWithDataSource:self
		tableViewDelegate:self
		floatingButtonViewDelegate:self
	];

}


- (void)setupObservers {

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(purgeData) name:@"purgeDataDone" object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(shouldMakeBackup) name:@"makeBackup" object:nil];

}


- (void)setupSearchController {

	UISearchController *searchC = [[UISearchController alloc] initWithSearchResultsController: nil];
	searchC.searchResultsUpdater = self;
	searchC.obscuresBackgroundDuringPresentation = NO;

	self.definesPresentationContext = YES;
	self.navigationItem.searchController = searchC;
	self.extendedLayoutIncludesOpaqueBars = YES;

}


- (void)loadView { self.view = azureTableVCView; }


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if(scrollView.contentOffset.y >= self.view.safeAreaInsets.bottom + 60)

		[azureTableVCView->azureFloatingButtonView animateViewWithAlpha:0 translateX:1 translateY:100];

	else [azureTableVCView->azureFloatingButtonView animateViewWithAlpha:1 translateX:1 translateY:1];

}

// ! NSNotificationCenter

- (void)purgeData {

	[[TOTPManager sharedInstance] removeAllObjectsFromArray];
	[azureTableVCView->azureTableView reloadData];

}


- (void)shouldMakeBackup {

	if(![authManager shouldUseBiometrics]) return [self makeBackup];
	[authManager setupAuthWithReason:kAzureReasonSensitiveOperation reply:^(BOOL success, NSError *error) {

		dispatch_async(dispatch_get_main_queue(), ^{

			if(!success) return;
			[self makeBackup];

		});

	}];

}


- (void)makeBackup {

	modalSheetVC = [ModalSheetVC new];
	[modalSheetVC setupChildWithTitle:@"Backup options"
		subtitle:@"Choose between loading a backup from file or making a new one."
		buttonTitle:@"Load Backup"
		forTarget:self
		forSelector:@selector(didTapLoadBackupButton)
		secondButtonTitle:@"Make Backup"
		forTarget:self
		forSelector:@selector(didTapMakeBackupButton)
		accessoryImage:[UIImage systemImageNamed:@"square.and.arrow.down"]
		secondAccessoryImage:[UIImage systemImageNamed:@"square.and.arrow.up"]
		prepareForReuse:NO
		scaleAnimation:YES
	];
	modalSheetVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:modalSheetVC animated:NO completion:nil];

}

// ! UITableViewDataSource

- (void)setupDataSourceForArray:(NSMutableArray *)array
	atIndexPath:(NSIndexPath *)indexPath
	forCell:(AzurePinCodeCell *)cell {

	cell->issuer = [array[indexPath.row] objectForKey: @"Issuer"];
	cell->hash = [array[indexPath.row] objectForKey: @"Secret"];
	[cell setSecret:[array[indexPath.row] objectForKey: @"Secret"]
		withAlgorithm:[array[indexPath.row] objectForKey: @"encryptionType"]
		allowingForTransition:NO
	];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	[azureTableVCView animateViewsWhenNecessary];
	return isFiltered ? filteredArray.count : [TOTPManager sharedInstance]->entriesArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	AzurePinCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
	cell.delegate = self;
	cell.backgroundColor = UIColor.clearColor;

	if(isFiltered) [self setupDataSourceForArray:filteredArray atIndexPath:indexPath forCell:cell];

	else
		[self setupDataSourceForArray:[TOTPManager sharedInstance]->entriesArray
			atIndexPath:indexPath
			forCell:cell
		];

	UIImage *image = [TOTPManager sharedInstance]->imagesDict[cell->issuer.lowercaseString];
	UIImage *resizedImage = [UIImage resizeImageFromImage:image withSize:CGSizeMake(30, 30)];
	UIImage *placeholderImage = [[UIImage imageWithContentsOfFile:kImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	cell->issuerImageView.image = image ? resizedImage : placeholderImage;
	cell->issuerImageView.tintColor = image ? nil : kAzureMintTintColor;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults boolForKey:@"copySecretPopoverView"]) return cell;

	[self initPopoverVCWithSourceView: cell];
	[defaults setBool:YES forKey: @"copySecretPopoverView"];

//	[[TOTPManager sharedInstance]->issuersArray sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
		title:@"Delete"
		handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {

		NSString *message = [NSString stringWithFormat: @"You're about to delete the code for the issuer named %@ ❗❗. Are you sure you want to proceed? You'll have to set the code again if you wished to.", [[TOTPManager sharedInstance]->entriesArray[indexPath.row] objectForKey:@"Issuer"]];

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Azure" message:message preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

			[[TOTPManager sharedInstance] removeObjectAtIndexPathForRow: indexPath.row];
			[azureTableVCView->azureTableView reloadData];

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

- (void)azureFloatingButtonViewDidTapFloatingButton {

	modalSheetVC = [ModalSheetVC new];
	modalSheetVC.delegate = self;
	[modalSheetVC setupChildWithTitle:@"Add issuer"
		subtitle:@"Add an issuer by scanning a QR code, importing a QR image or entering the secret manually."
		buttonTitle:@"Scan QR Code"
		forTarget:modalSheetVC
		forSelector:@selector(modalChildViewDidTapScanQRCodeButton)
		secondButtonTitle:@"Import QR Image"
		forTarget:modalSheetVC
		forSelector:@selector(modalChildViewDidTapImportQRImageButton)
		thirdStackView:YES
		thirdButtonTitle:@"Enter Manually"
		forTarget:modalSheetVC
		forSelector:@selector(modalChildViewDidTapEnterManuallyButton)
		accessoryImage:[UIImage systemImageNamed:@"qrcode"]
		secondAccessoryImage:[UIImage systemImageNamed:@"square.and.arrow.up"]
		thirdAccessoryImage:[UIImage systemImageNamed:@"square.and.pencil"]
		prepareForReuse:NO
		scaleAnimation:YES
	];
	modalSheetVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:modalSheetVC animated:NO completion:nil];

}

// ! AzurePinCodeCellDelegate

- (void)fadeInOutToastForCell:(AzurePinCodeCell *)cell {

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = cell->hash;

	[azureTableVCView->azureToastView fadeInOutToastViewWithMessage:@"Copied secret!" finalDelay:0.2];

}


- (void)azurePinCodeCellDidTapCell:(AzurePinCodeCell *)cell {

	if(![authManager shouldUseBiometrics]) return [self fadeInOutToastForCell: cell];
	[authManager setupAuthWithReason:kAzureReasonSensitiveOperation reply:^(BOOL success, NSError *error) {

		dispatch_async(dispatch_get_main_queue(), ^{

			if(!success) return;
			[self fadeInOutToastForCell: cell];

		});

	}];

}


- (void)azurePinCodeCellDidTapInfoButton:(AzurePinCodeCell *)cell {

	NSString *message = [NSString stringWithFormat:@"Issuer: %@", cell->issuer];
	[azureTableVCView->azureToastView fadeInOutToastViewWithMessage:message finalDelay:0.2];

}


- (void)azurePinCodeCellShouldFadeInOutToastView {

	[azureTableVCView->azureToastView fadeInOutToastViewWithMessage:@"Copied!" finalDelay:0.2];

}

// ! ModalSheetVCDelegate

- (void)modalSheetVCShouldReloadData { [azureTableVCView->azureTableView reloadData]; }

// ! ModalSheetVC

- (void)didTapLoadBackupButton {

	[backupManager makeDataOutOfJSON];

	[UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		[azureTableVCView->azureTableView reloadData];

	} completion:^(BOOL finished) { [modalSheetVC vcNeedsDismissal]; }];

}


- (void)didTapMakeBackupButton {

	[backupManager makeJSONOutOfData];
	[modalSheetVC shouldCrossDissolveChildSubviews];
	[modalSheetVC setupChildWithTitle:@"Make backup actions"
		subtitle:@"Do you want to view your backup in Filza now?"
		buttonTitle:@"Yes"
		forTarget:self
		forSelector:@selector(didTapViewInFilzaButton)
		secondButtonTitle:@"Later"
		forTarget:self
		forSelector:@selector(didTapDismissButton)
		accessoryImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]
		secondAccessoryImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
		prepareForReuse:YES
		scaleAnimation:NO
	];

}


- (void)didTapViewInFilzaButton {

	NSString *pathToFilza = [@"filza://view" stringByAppendingString: kAzurePath];
	NSURL *backupURLPath = [NSURL URLWithString: pathToFilza];
	[UIApplication.sharedApplication openURL:backupURLPath options:@{} completionHandler:nil];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[modalSheetVC vcNeedsDismissal];

	});

}


- (void)didTapDismissButton { [modalSheetVC vcNeedsDismissal]; }

// ! PopoverVC

- (void)initPopoverVCWithSourceView:(UIView *)sourceView {

	PopoverVC *popoverVC = [PopoverVC new];
	popoverVC.preferredContentSize = CGSizeMake(200, 40);
	popoverVC.modalPresentationStyle = UIModalPresentationPopover;
	popoverVC.view.layer.cornerCurve = kCACornerCurveContinuous;

	UIPopoverPresentationController *popover = popoverVC.popoverPresentationController;
	popover.delegate = self;
	popover.sourceView = sourceView;
	popover.permittedArrowDirections = UIPopoverArrowDirectionUp;

	[popoverVC fadeInPopoverWithMessage: @"Press the cell to save the current secret."];

	[self presentViewController:popoverVC animated:YES completion:nil];

}

// ! UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {

	return UIModalPresentationNone;

}

// ! UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

	NSString *searchedString = searchController.searchBar.text;
	[self updateWithFilteredContent: searchedString];
	[azureTableVCView->azureTableView reloadData];

}


- (void)updateWithFilteredContent:(NSString *)searchString {

	NSString *textToSearch = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	isFiltered = textToSearch.length ? YES : NO;

	filteredArray = [NSMutableArray new];
	NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"Issuer CONTAINS[cd] %@", textToSearch];
	[filteredArray removeAllObjects];
	filteredArray = [[TOTPManager sharedInstance]->entriesArray filteredArrayUsingPredicate:thePredicate].mutableCopy;

}

@end
