#import "Sources/Categories/Categories.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Controllers/Misc/PinCodeVC.h"
#import "Sources/Controllers/Misc/QRCodeVC.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/ModalChildView.h"


@interface ModalSheetVC : UIViewController <ModalChildViewDelegate, PinCodeVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end
