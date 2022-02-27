#import "Azure-Swift.h"
#import "Sources/Categories/UIImage+Resize.h"
#import "Sources/Categories/UIView+Animations.h"
#import "Sources/Cells/AzurePinCodeCell.h"
#import "Sources/Constants/Constants.h"
#import "Sources/Controllers/Core/PinCodeVC.h"
#import "Sources/Controllers/Core/QRCodeVC.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Views/AzureFloatingButtonView.h"
#import "Sources/Views/AzureToastView.h"


@interface AzureTableVC : UIViewController <AzureFloatingButtonViewDelegate, AzurePinCodeCellDelegate, PinCodeVCDelegate, UITableViewDataSource, UITableViewDelegate>
@end
