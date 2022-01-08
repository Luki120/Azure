@import Foundation;
#import "Controllers/Core/PinCodeVC.h"
#import "Libraries/TOTPGenerator.h"
#import "Libraries/MF_Base32Additions.h"


@interface TOTPManager : NSObject {

	@public NSMutableArray *issuersArray;
	@public NSMutableArray *secretHashesArray;

}
+ (TOTPManager *)sharedInstance;
@end
