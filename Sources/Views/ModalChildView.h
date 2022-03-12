#import "Sources/Constants/Constants.h"


@protocol ModalChildViewDelegate <NSObject>

@required

- (void)modalChildViewDidTapScanQRCodeButton;
- (void)modalChildViewDidTapImportQRImageButton;
- (void)modalChildViewDidTapEnterManuallyButton;
- (void)modalChildViewDidTapDimmedView;
- (void)modalChildViewDidPanWithGesture:(UIPanGestureRecognizer *)panRecognizer
	modifyingConstraintForView:(NSLayoutConstraint *)constraint;

@end


@interface ModalChildView : UIView
@property (nonatomic, weak) id <ModalChildViewDelegate> delegate;
- (void)animateViews;
- (void)animateDismissWithCompletion:(void(^)(BOOL finished))completion;
@end


// Constants
static const CGFloat kDefaultHeight = 300;
static const CGFloat kDismissableHeight = 200;
