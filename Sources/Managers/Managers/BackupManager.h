#import "Azure-Swift.h"
#import "Sources/Constants/Constants.h"
@import UniformTypeIdentifiers;


@interface BackupManager : NSObject
- (BOOL)isJailbroken;
- (void)makeDataOutOfJSON;
- (void)makeJSONOutOfData;
@end
