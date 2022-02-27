#import "AlgorithmVC.h"


@implementation AlgorithmVC {

	NSInteger selectedRow;

}

- (id)init {

	self = [super initWithStyle: UITableViewStyleGrouped];

	if(!self) return nil;

	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier: @"VanillaCell"];

	return self;

}


- (void)viewDidLoad {

	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = kUserInterfaceStyle ? UIColor.blackColor : UIColor.whiteColor;

}

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 3;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VanillaCell" forIndexPath:indexPath];

	selectedRow = [TOTPManager sharedInstance]->selectedRow;

	cell.accessoryType = selectedRow == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.backgroundColor = UIColor.clearColor;
	cell.textLabel.font = [UIFont systemFontOfSize: 14];

	switch(indexPath.row) {

		case 0: cell.textLabel.text = @"SHA1"; break;
		case 1: cell.textLabel.text = @"SHA256"; break;
		case 2: cell.textLabel.text = @"SHA512"; break;

	}

	return cell;

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[TOTPManager sharedInstance]->selectedRow = indexPath.row;
	[[TOTPManager sharedInstance] saveEncryptionType];
	[tableView reloadData];

}

@end
