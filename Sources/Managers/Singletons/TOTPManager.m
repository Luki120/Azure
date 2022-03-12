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

	selectedRow = [defaults integerForKey: @"selectedRow"];
	entriesArray = [defaults arrayForKey: @"entriesArray"].mutableCopy ?: [NSMutableArray new];

	return self;

}


- (void)feedSelectedRowWithRow:(NSInteger)row {

	selectedRow = row;
	[defaults setInteger:selectedRow forKey:@"selectedRow"];

}


- (void)feedDictionaryWithObject:(NSString *)obj andObject:(NSString *)object {

	NSMutableDictionary *issuersDict = [NSMutableDictionary new];

	[issuersDict setObject:obj forKey:@"Issuer"];
	[issuersDict setObject:object forKey:@"Secret"];
	[self configureEncryptionTypeForDict: issuersDict];

	[entriesArray addObject: issuersDict];
	[self saveDefaults];

}


- (void)configureEncryptionTypeForDict:(NSMutableDictionary *)dict {

	switch(selectedRow) {
		case 0: [dict setObject:kOTPGeneratorSHA1Algorithm forKey:@"encryptionType"]; break;
		case 1: [dict setObject:kOTPGeneratorSHA256Algorithm forKey:@"encryptionType"]; break;
		case 2: [dict setObject:kOTPGeneratorSHA512Algorithm forKey:@"encryptionType"]; break;
	}

}


- (void)removeObjectAtIndexPathForRow:(NSUInteger)row {

	[entriesArray removeObjectAtIndex: row];
	[self saveDefaults];

}


- (void)removeAllObjectsFromArray {

	[entriesArray removeAllObjects];
	[self saveDefaults];

}


- (void)saveDefaults {

	[defaults setObject:entriesArray forKey:@"entriesArray"];

}


- (void)makeURLOutOfOtPauthString:(NSString *)string {

	NSURL *url = [[NSURL alloc] initWithString: string];
	NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
	NSArray *queryItems = components.queryItems;

	NSMutableDictionary *issuerDict = [NSMutableDictionary new];

	for(NSURLQueryItem *queryItem in queryItems) {

		if([queryItem.name isEqualToString: @"issuer"])
			[issuerDict setObject:queryItem.value forKey:@"Issuer"];

		else if([queryItem.name isEqualToString: @"secret"])
			[issuerDict setObject:queryItem.value forKey:@"Secret"];

		else if([queryItem.name isEqualToString: @"algorithm"])
			[issuerDict setObject:queryItem.value forKey:@"encryptionType"];

		if([queryItem.name rangeOfString: @"algorithm"].location != NSNotFound
			&& [queryItem.name rangeOfString: @"issuer"].location != NSNotFound)
				goto finished;

		else {

			if([queryItem.name rangeOfString: @"algorithm"].location == NSNotFound)
				[issuerDict setObject:kOTPGeneratorSHA1Algorithm forKey:@"encryptionType"];

			if([queryItem.name rangeOfString: @"issuer"].location == NSNotFound) {

				NSScanner *scanner = [NSScanner scannerWithString: string];
				[scanner setCharactersToBeSkipped:nil];
				[scanner scanUpToString:@"/totp/" intoString:nil];
				if([scanner scanString:@"/totp/" intoString:nil]) {
					NSString *result = nil;
					if([scanner scanUpToString:@"?" intoString:&result])
						[issuerDict setObject:result forKey:@"Issuer"];
				}

			}

		}

	}

	finished:

	[entriesArray addObject: issuerDict];
	[self saveDefaults];

}

@end
