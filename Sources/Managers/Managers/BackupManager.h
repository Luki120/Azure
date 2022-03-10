#import "Sources/Constants/Constants.h"
#import "Sources/Managers/Singletons/TOTPManager.h"


@interface BackupManager : NSObject
- (void)makeDataOutOfJSON;
- (void)makeJSONOutOfData;
@end
