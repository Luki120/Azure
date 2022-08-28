#import "Sources/Constants/Constants.h"
#import "Sources/Libraries/MF_Base32Additions.h"
#import "Sources/Libraries/TOTPGenerator.h"


@class AzurePinCodeCell;

@protocol AzurePinCodeCellDelegate <NSObject>

@required
- (void)azurePinCodeCellDidTapCell:(AzurePinCodeCell *)cell;
- (void)azurePinCodeCellDidTapInfoButton:(AzurePinCodeCell *)cell;
- (void)azurePinCodeCellShouldFadeInOutToastView;

@end


@interface AzurePinCodeCell : UITableViewCell {

	@public NSString *issuer;
	@public NSString *hash;
	@public UIImageView *issuerImageView;

}
@property (nonatomic, weak) id <AzurePinCodeCellDelegate> delegate;
- (void)setSecret:(NSString *)secret withAlgorithm:(NSString *)algorithm allowingForTransition:(BOOL)allowed;
@end
