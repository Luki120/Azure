@import Foundation;
@import LocalAuthentication;


@interface AuthManager : NSObject
- (void)setupAuthWithReason:(NSString *)reason
	reply:(void(^)(BOOL success, NSError *error))reply;
@end
