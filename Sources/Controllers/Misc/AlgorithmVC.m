#import "AlgorithmVC.h"


@implementation AlgorithmVC {

	NSInteger selectedRow;
	NSMutableArray *algorithmTableArray;

}

- (id)init {

	self = [super initWithStyle: UITableViewStyleGrouped];

	if(!self) return nil;

	algorithmTableArray = [NSMutableArray new];
	[algorithmTableArray addObject: @"SHA1"];
	[algorithmTableArray addObject: @"SHA256"];
	[algorithmTableArray addObject: @"SHA512"];

	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier: @"VanillaCell"];

	return self;

}


- (void)viewDidLoad {

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
