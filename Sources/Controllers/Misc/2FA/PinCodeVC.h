#import "AlgorithmVC.h"
#import "Sources/Views/VCSViews/PinCodeVCView.h"


@protocol PinCodeVCDelegate <NSObject>

@optional
- (void)pinCodeVCShouldDismissVC;

@required
- (void)pinCodeVCShouldPushAlgorithmVC;

@end


@interface PinCodeVC : UIViewController <AlgorithmVCDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
