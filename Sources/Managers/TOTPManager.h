#import "Sources/Libraries/MF_Base32Additions.h"
#import "Sources/Libraries/TOTPGenerator.h"


@interface TOTPManager : NSObject {

	@public NSInteger selectedRow;
	@public NSMutableArray *issuersArray;
	@public NSMutableArray *secretHashesArray;
	@public NSMutableArray *encryptionTypesArray;

}
- (void)feedSelectedRowWithRow:(NSInteger)row;
- (void)makeURLOutOfOtPauthString:(NSString *)string;
- (void)feedIssuersArrayWithObject:(NSString *)obj andSecretHashesArray:(NSString *)object;
- (void)removeAllObjectsFromArrays;
- (void)removeObjectAtIndexForArrays:(NSInteger)indexPath;
- (void)configureEncryptionType;
+ (TOTPManager *)sharedInstance;
@end
