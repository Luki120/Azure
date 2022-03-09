#import "Sources/Categories/Categories.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Controllers/Misc/PinCodeVC.h"
#import "Sources/Controllers/Misc/QRCodeVC.h"
#import "Sources/Managers/TOTPManager.h"


@interface ModalSheetVC : UIViewController <PinCodeVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end


// Constants
static const CGFloat kDefaultHeight = 300;
static const CGFloat kDismissableHeight = 200;
