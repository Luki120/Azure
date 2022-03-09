#import "Sources/Constants/Constants.h"
#import "Sources/Managers/TOTPManager.h"


@interface BackupManager : NSObject
- (void)constructJSONDictOutOfCurrentTableView:(UITableView *)tableView
	withNumberOfRowsInSection:(NSInteger)section;
@end
