#import "AlgorithmVC.h"


@implementation AlgorithmVC {

	NSInteger selectedRow;
	NSArray *algorithmTableArray;

}

- (id)init {

	self = [super initWithStyle: UITableViewStyleGrouped];
	if(!self) return nil;

	algorithmTableArray = [NSArray arrayWithObjects: @"SHA1", @"SHA256", @"SHA512", nil];
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier: @"VanillaCell"];

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = UIColor.systemBackgroundColor;

}

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return algorithmTableArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VanillaCell" forIndexPath:indexPath];

	selectedRow = [TOTPManager sharedInstance]->selectedRow;
	NSDictionary *userInfoDict = @{ @"selectedRow": [NSNumber numberWithInteger: selectedRow] };
	[NSNotificationCenter.defaultCenter postNotificationName:@"updateAlgorithmLabel" object:nil userInfo: userInfoDict];

	cell.accessoryType = selectedRow == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.backgroundColor = UIColor.clearColor;
	cell.textLabel.font = [UIFont systemFontOfSize: 14];
	cell.textLabel.text = algorithmTableArray[indexPath.row];

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[TOTPManager sharedInstance]->selectedRow = indexPath.row;
	[[TOTPManager sharedInstance] saveSelectedRow];
	[tableView reloadData];

}

@end
