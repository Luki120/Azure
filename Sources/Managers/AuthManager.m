#import "AuthManager.h"


@implementation AuthManager

- (id)init {

	self = [super init];
	if(!self) return nil;

	return self;

}


- (void)setupAuthWithReason:(NSString *)reason
	reply:(void(^)(BOOL success, NSError *error))reply {

	[[LAContext new] evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:reply];

}

@end
