#import "Sources/Libraries/MF_Base32Additions.h"
#import "Sources/Libraries/TOTPGenerator.h"


@interface TOTPManager : NSObject {

	@public NSInteger selectedRow;
	@public NSMutableArray *entriesArray;
	@public NSDictionary *imagesDict;

}
- (void)feedSelectedRowWithRow:(NSInteger)row;
- (void)feedDictionaryWithObject:(NSString *)obj andObject:(NSString *)object;
- (void)configureEncryptionTypeForDict:(NSMutableDictionary *)dict;
- (void)removeObjectAtIndexPathForRow:(NSUInteger)row;
- (void)removeAllObjectsFromArray;
- (void)saveDefaults;
- (void)makeURLOutOfOtPauthString:(NSString *)string;
+ (TOTPManager *)sharedInstance;
@end
