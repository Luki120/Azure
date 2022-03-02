@import UIKit;
#import "Azure-Swift.h"
#import "Sources/Constants/Constants.h"
#import "Sources/Managers/TOTPManager.h"


@class AzurePinCodeCell;


@protocol AzurePinCodeCellDelegate <NSObject>

@required - (void)didTapCell:(AzurePinCodeCell *)cell;
@required - (void)didTapInfoButton:(AzurePinCodeCell *)cell;

@end


@interface AzurePinCodeCell : UITableViewCell {

	@public NSString *issuer;
	@public NSString *hash;
	@public UIImageView *issuerImageView;

}
@property (nonatomic, weak) id <AzurePinCodeCellDelegate> delegate;
- (void)setSecret:(NSString *)secret withAlgorithm:(NSString *)algorithm;
@end
