@import Foundation;
#import "Sources/Libraries/MF_Base32Additions.h"
#import "Sources/Libraries/TOTPGenerator.h"


@interface TOTPManager : NSObject {

	@public NSInteger selectedRow;
	@public NSMutableArray *issuersArray;
	@public NSMutableArray *secretHashesArray;
	@public NSMutableArray *encryptionTypesArray;

}
- (void)saveDefaults;
- (void)saveSelectedRow;
+ (TOTPManager *)sharedInstance;
@end
