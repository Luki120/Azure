#import "Sources/Constants/Constants.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
@import UniformTypeIdentifiers;


@interface BackupManager : NSObject
- (BOOL)isJailbroken;
- (void)makeDataOutOfJSON;
- (void)makeJSONOutOfData;
@end
