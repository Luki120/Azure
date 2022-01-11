#import "Azure-Swift.h"
#import "Categories/UIImage+Resize.h"
#import "Cells/AzurePinCodeCell.h"
#import "Constants/Constants.h"
#import "Controllers/Core/PinCodeVC.h"
#import "Controllers/Core/QRCodeVC.h"


@interface AzureTableVC : UITableViewController <AzurePinCodeCellDelegate, PinCodeVCDelegate>
@end
