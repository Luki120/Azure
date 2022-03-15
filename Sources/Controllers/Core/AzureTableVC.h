#import "Azure-Swift.h"
#import "Sources/Cells/AzurePinCodeCell.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Controllers/Misc/ModalSheetVC.h"
#import "Sources/Controllers/Misc/PinCodeVC.h"
#import "Sources/Controllers/Misc/QRCodeVC.h"
#import "Sources/Managers/Managers/AuthManager.h"
#import "Sources/Managers/Managers/BackupManager.h"
#import "Sources/Views/VCSViews/AzureTableVCView.h"


@interface AzureTableVC : UIViewController <AzureFloatingButtonViewDelegate, AzurePinCodeCellDelegate, ModalSheetVCDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>
@end
