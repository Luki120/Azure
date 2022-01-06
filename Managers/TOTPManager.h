@import Foundation;
#import "Controllers/PinCodeVC.h"
#import "TOTPGenerator/TOTPGenerator.h"
#import "TOTPGenerator/MF_Base32Additions.h"


@interface TOTPManager : NSObject {

	@public NSMutableArray *issuersArray;
	@public NSMutableArray *secretHashesArray;

}
+ (TOTPManager *)sharedInstance;
@end
