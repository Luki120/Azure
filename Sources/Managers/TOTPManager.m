#import "TOTPManager.h"


@implementation TOTPManager {

	NSUserDefaults *defaults;

}


+ (TOTPManager *)sharedInstance {

	static TOTPManager *sharedInstance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{ sharedInstance = [self new]; });

	return sharedInstance;

}


- (id)init {

	self = [super init];

	if(!self) return nil;

	defaults = [NSUserDefaults standardUserDefaults];

	issuersArray = [defaults arrayForKey: @"Issuers"].mutableCopy ?: [NSMutableArray new];
	secretHashesArray = [defaults arrayForKey: @"Hashes"].mutableCopy ?: [NSMutableArray new];
	selectedRow = [defaults integerForKey: @"selectedRow"];

	return self;

}


- (void)saveDefaults {

	[defaults setObject: issuersArray forKey: @"Issuers"];
	[defaults setObject: secretHashesArray forKey: @"Hashes"];

}


- (void)saveSelectedRow {

	[defaults setInteger: selectedRow forKey: @"selectedRow"];

}

@end
