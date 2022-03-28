#import "PinCodeVC.h"


@implementation PinCodeVC {

	AlgorithmVC *algorithmVC;
	PinCodeVCView *pinCodeVCView;

}

// ! Lifecycle

- (id)init {

	self = [super init];
	if(!self) return nil;

	algorithmVC = [AlgorithmVC new];
	algorithmVC.delegate = self;
	[self setupMainView];
	[pinCodeVCView->pinCodesTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(shouldSaveData) name:@"checkIfDataShouldBeSaved" object:nil];

	return self;

}


- (void)setupMainView {

	pinCodeVCView = [[PinCodeVCView alloc] initWithDataSource:self tableViewDelegate:self];

}


- (void)loadView { self.view = pinCodeVCView; }


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	[self configureAlgorithmLabelWithSelectedRow:[TOTPManager sharedInstance]->selectedRow];

}


- (void)configureAlgorithmLabelWithSelectedRow:(NSInteger)selectedRow {

	switch(selectedRow) {
		case 0: pinCodeVCView->algorithmLabel.text = @"SHA1"; break;
		case 1: pinCodeVCView->algorithmLabel.text = @"SHA256"; break;
		case 2: pinCodeVCView->algorithmLabel.text = @"SHA512"; break;
	}

}

// ! AlgorithmVCDelegate

- (void)algorithmVCDidUpdateAlgorithmLabelWithSelectedRow:(NSInteger)selectedRow {

	[self configureAlgorithmLabelWithSelectedRow: selectedRow];

}

// ! NSNotificationCenter

- (void)shouldSaveData {

	if(pinCodeVCView->issuerTextField.text.length <= 0 || pinCodeVCView->secretTextField.text.length <= 0) {
		[pinCodeVCView->azToastView fadeInOutToastViewWithMessage:@"Fill out both forms." finalDelay: 1.5];
		[pinCodeVCView->secretTextField resignFirstResponder];
		return;
	}

	[[TOTPManager sharedInstance] feedDictionaryWithObject:pinCodeVCView->issuerTextField.text
		andObject:pinCodeVCView->secretTextField.text
	];

	[self.delegate pinCodeVCShouldDismissVC];

	pinCodeVCView->issuerTextField.text = @"";
	pinCodeVCView->secretTextField.text = @"";

}

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 3;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [pinCodeVCView->pinCodesTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.backgroundColor = UIColor.clearColor;

	switch(indexPath.row) {

		case 0:

			[cell.contentView addSubview: pinCodeVCView->issuerStackView];
			[pinCodeVCView configureConstraintsForStackView:pinCodeVCView->issuerStackView forTextField:pinCodeVCView->issuerTextField forCell:cell];
			break;

		case 1:

			[cell.contentView addSubview: pinCodeVCView->secretHashStackView];
			[pinCodeVCView configureConstraintsForStackView:pinCodeVCView->secretHashStackView forTextField:pinCodeVCView->secretTextField forCell:cell];
			break;

		case 2:

			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.font = [UIFont systemFontOfSize: 14];
			cell.textLabel.text = @"Algorithm";

			[cell.contentView addSubview: pinCodeVCView->algorithmLabel];
			[pinCodeVCView->algorithmLabel.trailingAnchor constraintEqualToAnchor: cell.contentView.trailingAnchor constant: -20].active = YES;
			[pinCodeVCView->algorithmLabel.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
			break;

	}

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(indexPath.row != 2) return;

	[self.delegate pinCodeVCShouldPushAlgorithmVC];

}

@end
