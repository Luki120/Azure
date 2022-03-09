#import "Sources/Constants/Constants.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/AzureToastView.h"


@protocol PinCodeVCDelegate <NSObject>

@required - (void)pushAlgorithmVC;
@optional - (void)shouldDismissVC;

@end


@interface PinCodeVC : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
