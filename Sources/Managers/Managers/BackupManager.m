#import "BackupManager.h"


@implementation BackupManager {

	NSFileManager *fileM;
	NSString *documentsPath;
	NSString *kAzureJailedPath;

}

- (id)init {

	self = [super init];
	if(!self) return nil;

	fileM = [NSFileManager defaultManager];
	documentsPath = [[fileM URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path;
	kAzureJailedPath = [documentsPath stringByAppendingPathComponent: @"AzureBackup.json"];

	return self;

}


- (BOOL)isJailbroken {

	if([fileM fileExistsAtPath: kCheckra1n]
		|| [fileM fileExistsAtPath: kUnc0ver]
		|| [fileM fileExistsAtPath: kTaurine]) return YES;

	return NO;

}


- (void)makeDataOutOfJSON {

	NSData *jsonData = [[NSData alloc] initWithContentsOfFile: [self isJailbroken] ? kAzurePath : kAzureJailedPath];
	NSMutableArray *jsonArray = [NSMutableArray new];
	jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	[TOTPManager sharedInstance].entriesArray = jsonArray;
	[[TOTPManager sharedInstance] saveDefaults];

}


- (void)makeJSONOutOfData {

	if([self isJailbroken]) {

		BOOL isDir;

		if(![fileM fileExistsAtPath:kAzureDir isDirectory:&isDir])
			[fileM createDirectoryAtPath:kAzureDir withIntermediateDirectories:NO attributes:nil error:nil];

		[self createFileAtPath: kAzurePath];

	}

	else [self createFileAtPath: kAzureJailedPath];

	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: [self isJailbroken] ? kAzurePath : kAzureJailedPath];
	[fileHandle seekToEndOfFile];

	NSData *serializedData = [NSJSONSerialization dataWithJSONObject:[TOTPManager sharedInstance].entriesArray
		options:0
		error:nil
	];
	[fileHandle writeData: serializedData];
	[fileHandle closeFile];

}


- (void)createFileAtPath:(NSString *)path {

	if(![fileM fileExistsAtPath: path])
		[fileM createFileAtPath:path contents:nil attributes:nil];

	else if([fileM fileExistsAtPath: path]) {
		[fileM removeItemAtPath:path error:nil];
		[fileM createFileAtPath:path contents:nil attributes:nil];
	}

}

@end
