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


- (BOOL)shouldUseBiometrics {

	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

	if([[NSFileManager defaultManager] fileExistsAtPath: kCheckra1n]
		&& ([deviceModel isEqualToString:@"iPhone10,1"]
		|| [deviceModel isEqualToString:@"iPhone10,4"]
		|| [deviceModel isEqualToString:@"iPhone10,2"]
		|| [deviceModel isEqualToString:@"iPhone10,5"]
		|| [deviceModel isEqualToString:@"iPhone10,3"]
		|| [deviceModel isEqualToString:@"iPhone10,6"])) return NO;

	return YES;

}

@end
