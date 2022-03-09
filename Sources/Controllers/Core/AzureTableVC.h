#import "Azure-Swift.h"
#import "Sources/Categories/UIImage+Resize.h"
#import "Sources/Categories/UIView+Animations.h"
#import "Sources/Cells/AzurePinCodeCell.h"
#import "Sources/Constants/Constants.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Controllers/Misc/ModalSheetVC.h"
#import "Sources/Controllers/Misc/PinCodeVC.h"
#import "Sources/Controllers/Misc/QRCodeVC.h"
#import "Sources/Views/AzureFloatingButtonView.h"
#import "Sources/Views/AzureToastView.h"
#import "Sources/Managers/AuthManager.h"
#import "Sources/Managers/BackupManager.h"


@interface AzureTableVC : UIViewController <AzureFloatingButtonViewDelegate, AzurePinCodeCellDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>
@end
