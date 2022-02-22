#import "Azure-Swift.h"
#import "Categories/UIImage+Resize.h"
#import "Cells/AzurePinCodeCell.h"
#import "Constants/Constants.h"
#import "Controllers/Core/PinCodeVC.h"
#import "Controllers/Core/QRCodeVC.h"
#import "Views/AzureFloatingButtonView.h"
#import "Views/AzureToastView.h"


@interface AzureTableVC : UIViewController <AzureFloatingButtonViewDelegate, AzurePinCodeCellDelegate, PinCodeVCDelegate, UITableViewDataSource, UITableViewDelegate>
@end
