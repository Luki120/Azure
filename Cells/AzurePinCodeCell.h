@import UIKit;
#import "Azure-Swift.h"
#import "Constants/Constants.h"
#import "Managers/TOTPManager.h"


@class AzurePinCodeCell;


@protocol AzurePinCodeCellDelegate <NSObject>
@required - (void)didTapInfoButton:(AzurePinCodeCell *)cell;
@end


@interface AzurePinCodeCell : UITableViewCell {

	@public NSString *issuer;
	@public NSString *hash;

}
@property (nonatomic, weak) id <AzurePinCodeCellDelegate> delegate;
- (void)setSecret:(NSString *)secret;
@end
