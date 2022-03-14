#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Views/AzureToastView.h"


@protocol PinCodeVCDelegate <NSObject>

@optional
- (void)pinCodeVCShouldDismissVC;

@required
- (void)pinCodeVCShouldPushAlgorithmVC;

@end


@interface PinCodeVC : UIViewController <AlgorithmVCDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <PinCodeVCDelegate> delegate;
@end
