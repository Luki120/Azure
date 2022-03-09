#import <objc/runtime.h>
#import "Sources/Constants/Constants.h"
#import "Sources/Controllers/Core/AzureRootVC.h"
#import "Sources/Managers/Managers/AuthManager.h"


@interface AZAppDelegate : UIResponder <UIApplicationDelegate>
@end

Class strongClass;
UIButton *quitButton;
UILabel *addressLabel;
UIWindow *strongWindow;
