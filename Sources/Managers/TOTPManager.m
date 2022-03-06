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
	encryptionTypesArray = [defaults arrayForKey: @"encryptionTypes"].mutableCopy ?: [NSMutableArray new];
	selectedRow = [defaults integerForKey: @"selectedRow"];

	return self;

}


- (void)saveDefaults {

	[defaults setObject: issuersArray forKey: @"Issuers"];
	[defaults setObject: secretHashesArray forKey: @"Hashes"];
	[defaults setObject: encryptionTypesArray forKey: @"encryptionTypes"];

}


- (void)saveSelectedRow {

	[defaults setInteger: selectedRow forKey: @"selectedRow"];

}


- (void)makeURLOutOfOtPauthString:(NSString *)string {

	NSURL *url = [[NSURL alloc] initWithString: string];
	NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
	NSArray *queryItems = components.queryItems;

	for(NSURLQueryItem *queryItem in queryItems) {

		if([queryItem.name isEqualToString: @"issuer"])
			[[TOTPManager sharedInstance]->issuersArray addObject: queryItem.value];

		else if([queryItem.name isEqualToString: @"secret"])
			[[TOTPManager sharedInstance]->secretHashesArray addObject: queryItem.value];

		else if([queryItem.name isEqualToString: @"algorithm"])
			[[TOTPManager sharedInstance]->encryptionTypesArray addObject: queryItem.value];

		[[TOTPManager sharedInstance] saveDefaults];

	}

}

@end
