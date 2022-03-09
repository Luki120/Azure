#import "Sources/Constants/Constants.h"
#import "Sources/Managers/Singletons/TOTPManager.h"


@interface BackupManager : NSObject
- (void)constructJSONDictOutOfCurrentTableView:(UITableView *)tableView
	withNumberOfRowsInSection:(NSInteger)section;
@end
