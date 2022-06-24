#import "Sources/Constants/Constants.h"
#import "Sources/Managers/Singletons/TOTPManager.h"


@protocol AlgorithmVCDelegate

@required
- (void)algorithmVCDidUpdateAlgorithmLabelWithSelectedRow:(NSInteger)selectedRow;

@end


@interface AlgorithmVC : UITableViewController
@property (nonatomic, weak) id <AlgorithmVCDelegate> delegate;
@end
