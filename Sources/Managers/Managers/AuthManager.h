@import LocalAuthentication;
#import <sys/utsname.h>
#import "Sources/Constants/Constants.h"


@interface AuthManager : NSObject
- (BOOL)shouldUseBiometrics;
- (void)setupAuthWithReason:(NSString *)reason
	reply:(void(^)(BOOL success, NSError *error))reply;
@end
