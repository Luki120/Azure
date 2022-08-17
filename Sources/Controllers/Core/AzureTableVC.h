#import "Azure-Swift.h"
#import "Sources/Cells/AzurePinCodeCell.h"
#import "Sources/Controllers/Misc/Views/ModalSheetVC.h"
#import "Sources/Controllers/Misc/Views/PopoverVC.h"
#import "Sources/Managers/Managers/AuthManager.h"
#import "Sources/Managers/Managers/BackupManager.h"
#import "Sources/Views/VCSViews/AzureTableVCView.h"


@interface AzureTableVC : UIViewController
@end


@interface UIApplication (Azure)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end
