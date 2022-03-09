#import "Sources/Managers/BackupManager.h"
#include "Sources/Views/AzureToastView.h"


@implementation BackupManager {

	NSMutableArray *entriesArray;

}


- (id)init {

	self = [super init];
	if(!self) return nil;

	return self;

}


- (void)constructJSONDictOutOfCurrentTableView:(UITableView *)tableView
	withNumberOfRowsInSection:(NSInteger)section {

	entriesArray = [NSMutableArray new];
	for(NSInteger i = 0; i < [tableView numberOfRowsInSection:section]; i++) {
		NSMutableDictionary *jsonDict = [NSMutableDictionary new];
		[jsonDict setObject:[TOTPManager sharedInstance]->issuersArray[i] forKey:@"Issuer"];
		[jsonDict setObject:[TOTPManager sharedInstance]->secretHashesArray[i] forKey:@"Secret"];
		[jsonDict setObject:[TOTPManager sharedInstance]->encryptionTypesArray[i] forKey:@"Encryption type"];

		[entriesArray addObject: jsonDict];
	}

	NSFileManager *fileM = [NSFileManager defaultManager];

	BOOL isDir;

	if(![fileM fileExistsAtPath:kAzureDir isDirectory:&isDir])
		[fileM createDirectoryAtPath:kAzureDir withIntermediateDirectories:NO attributes:nil error:nil];

	if(![fileM fileExistsAtPath: kAzurePath])
		[fileM createFileAtPath:kAzurePath contents:nil attributes:nil];

	else if([fileM fileExistsAtPath: kAzurePath]) {
		[fileM removeItemAtPath:kAzurePath error:nil];
		[fileM createFileAtPath:kAzurePath contents:nil attributes:nil];
	}

	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: kAzurePath];
	[fileHandle seekToEndOfFile];

	NSData *serializedData = [NSJSONSerialization dataWithJSONObject:entriesArray options:0 error:nil];
	[fileHandle writeData: serializedData];
	[fileHandle closeFile];

}

@end
