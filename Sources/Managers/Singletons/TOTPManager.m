#import "TOTPManager.h"


static dispatch_once_t onceToken;

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


- (void)feedSelectedRowWithRow:(NSInteger)row {

	selectedRow = row;
	[defaults setInteger: selectedRow forKey: @"selectedRow"];

}


- (void)feedIssuersArrayWithObject:(NSString *)obj andSecretHashesArray:(NSString *)object {

	[issuersArray addObject: obj];
	[secretHashesArray addObject: object];
	[self configureEncryptionType];

}


- (void)configureEncryptionType {

	switch(selectedRow) {
		case 0: [encryptionTypesArray addObject: kOTPGeneratorSHA1Algorithm]; break;
		case 1: [encryptionTypesArray addObject: kOTPGeneratorSHA256Algorithm]; break;
		case 2: [encryptionTypesArray addObject: kOTPGeneratorSHA512Algorithm]; break;
	}

	[self saveDefaults];

}


- (void)removeObjectAtIndexForArrays:(NSInteger)indexPathForRow {

	[issuersArray removeObjectAtIndex: indexPathForRow];
	[secretHashesArray removeObjectAtIndex: indexPathForRow];
	[encryptionTypesArray removeObjectAtIndex: indexPathForRow];

	[self saveDefaults];

}


- (void)removeAllObjectsFromArrays {

	[issuersArray removeAllObjects];
	[secretHashesArray removeAllObjects];
	[encryptionTypesArray removeAllObjects];

	[self saveDefaults];

}


- (void)saveDefaults {

	[defaults setObject: issuersArray forKey: @"Issuers"];
	[defaults setObject: secretHashesArray forKey: @"Hashes"];
	[defaults setObject: encryptionTypesArray forKey: @"encryptionTypes"];

}


- (void)makeURLOutOfOtPauthString:(NSString *)string {

	NSURL *url = [[NSURL alloc] initWithString: string];
	NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
	NSArray *queryItems = components.queryItems;

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = string;

	for(NSURLQueryItem *queryItem in queryItems) {

		if([queryItem.name isEqualToString: @"issuer"])
			[issuersArray addObject: queryItem.value];

		else if([queryItem.name isEqualToString: @"secret"])
			[secretHashesArray addObject: queryItem.value];

		else if([queryItem.name isEqualToString: @"algorithm"])
			[encryptionTypesArray addObject: queryItem.value];

		if(![queryItem.name isEqualToString: @"algorithm"]) {
			dispatch_once(&onceToken, ^{
				[encryptionTypesArray addObject: kOTPGeneratorSHA1Algorithm];
			});
		}

		[self saveDefaults];

	}

	onceToken = 0;

}

@end
