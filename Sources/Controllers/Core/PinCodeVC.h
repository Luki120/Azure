@import UIKit;
#import "Constants/Constants.h"
#import "Managers/TOTPManager.h"


@protocol PinCodeVCDelegate <NSObject>

@required - (void)shouldDismissVC;

@end


@interface PinCodeVC : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {

	@public UITextField *secretTextField;

}
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
