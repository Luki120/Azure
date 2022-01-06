#import "TOTPManager.h"


@implementation TOTPManager


+ (TOTPManager *)sharedInstance {

	static TOTPManager *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });

	return sharedInstance;

}


- (id)init {

	self = [super init];

	if(self) {

		issuersArray = [NSUserDefaults.standardUserDefaults arrayForKey: @"Issuers"].mutableCopy ?: [NSMutableArray new];
		secretHashesArray = [NSUserDefaults.standardUserDefaults arrayForKey: @"Hashes"].mutableCopy ?: [NSMutableArray new];

	}

	return self;

}


@end
