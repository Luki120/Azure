#import "Sources/Categories/Categories.h"
#import "Sources/Controllers/Misc/AlgorithmVC.h"
#import "Sources/Controllers/Misc/PinCodeVC.h"
#import "Sources/Controllers/Misc/QRCodeVC.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/UI/ModalChildView.h"


@protocol ModalSheetVCDelegate <NSObject>

@required
- (void)modalSheetVCShouldReloadData;

@end


@interface ModalSheetVC : UIViewController <ModalChildViewDelegate, PinCodeVCDelegate, QRCodeVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) id <ModalSheetVCDelegate> delegate;
- (void)setupChildWithTitle:(NSString *)title
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
	prepareForReuse:(BOOL)prepare
	allowingInitialScaleAnimation:(BOOL)allowsScaleAnim;
- (void)vcNeedsDismissal;
- (void)shouldCrossDissolveChildSubviews;
@end
