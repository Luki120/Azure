#import "AlgorithmVC.h"
#import "Azure-Swift.h"


@protocol PinCodeVCDelegate <NSObject>

@optional
- (void)pinCodeVCShouldDismissVC;

@required
- (void)pinCodeVCShouldPushAlgorithmVC;

@end


@interface PinCodeVC : UIViewController <AlgorithmVCDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
