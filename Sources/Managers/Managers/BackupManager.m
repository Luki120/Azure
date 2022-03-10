#import "BackupManager.h"


@implementation BackupManager

- (id)init {

	self = [super init];
	if(!self) return nil;

	return self;

}


- (void)makeDataOutOfJSON {

	NSData *jsonData = [[NSData alloc] initWithContentsOfFile: kAzurePath];
	NSMutableArray *jsonArray = [NSMutableArray new];
	jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	[TOTPManager sharedInstance]->entriesArray = jsonArray;
	[[TOTPManager sharedInstance] saveDefaults];

}


- (void)makeJSONOutOfData {

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

	NSData *serializedData = [NSJSONSerialization dataWithJSONObject:[TOTPManager sharedInstance]->entriesArray
		options:0
		error:nil
	];
	[fileHandle writeData: serializedData];
	[fileHandle closeFile];

}

@end
