#import "Sources/Categories/Categories.h"
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
- (void)animateSheetHeight:(CGFloat)height;
- (void)animateDismissWithCompletion:(void(^)(BOOL finished))completion;
- (void)setupModalSheetWithTitle:(NSString *)title
	subtitle:(NSString *)subtitle
	buttonTitle:(NSString *)buttonTitle
	forTarget:(id)target
	forSelector:(SEL)selector
	secondButtonTitle:(NSString *)secondTitle
	forTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	thirdStackView:(BOOL)thirdSV
	thirdButtonTitle:(NSString *)thirdTitle
	forTarget:(id)thirdTarget
	forSelector:(SEL)thirdSelector
	accessoryImage:(UIImage *)accessoryImage
	secondAccessoryImage:(UIImage *)secondAccessoryImg
	thirdAccessoryImage:(UIImage *)thirdAccessoryImg
	prepareForReuse:(BOOL)prepare
	scaleAnimation:(BOOL)scaleAnim;
- (void)shouldCrossDissolveSubviews;
@end


static const CGFloat kDefaultHeight = 300;
static const CGFloat kDismissableHeight = 215;
static CGFloat currentSheetHeight = 300;
