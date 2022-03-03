@import UIKit;
#import "Sources/Constants/Constants.h"
#import "Sources/Managers/TOTPManager.h"
#import "Sources/Views/AzureToastView.h"


@protocol PinCodeVCDelegate <NSObject>

@required - (void)shouldDismissVC;

@end


@interface PinCodeVC : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {

	@public UITextField *secretTextField;

}
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
