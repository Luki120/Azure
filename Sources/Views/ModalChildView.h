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
- (void)setupModalSheetWithTitle:(NSString *)title
	withSubtitle:(NSString *)subtitle
	withButtonTitle:(NSString *)firstTitle
	withTarget:(id)firstTarget
	forSelector:(SEL)firstSelector
	secondButtonTitle:(NSString *)secondTitle
	withTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	thirdButtonTitle:(NSString *)thirdTitle
	withTarget:(id)thirdTarget
	forSelector:(SEL)thirdSelector
	withFirstImage:(UIImage *)firstImage
	withSecondImage:(UIImage *)secondImage
	withThirdImage:(UIImage *)thirdImage
	allowingForSecondStackView:(BOOL)allowsSecondSV
	allowingForThirdStackView:(BOOL)allowsThirdSV
	prepareForReuse:(BOOL)prepare;
- (void)shouldCrossDissolveSubviews;
@end


// Constants
static const CGFloat kDefaultHeight = 300;
static const CGFloat kDismissableHeight = 200;
