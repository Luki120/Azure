@import Foundation;
#import "Sources/Controllers/Core/PinCodeVC.h"
#import "Sources/Libraries/TOTPGenerator.h"
#import "Sources/Libraries/MF_Base32Additions.h"


@interface TOTPManager : NSObject {

	@public NSMutableArray *issuersArray;
	@public NSMutableArray *secretHashesArray;

}
- (void)saveDefaults;
+ (TOTPManager *)sharedInstance;
@end
