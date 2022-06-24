#import "Sources/Categories/Categories.h"
#import "Sources/Controllers/Misc/2FA/AlgorithmVC.h"
#import "Sources/Controllers/Misc/2FA/PinCodeVC.h"
#import "Sources/Controllers/Misc/2FA/QRCodeVC.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/UI/ModalChildView.h"


@protocol ModalSheetVCDelegate <NSObject>

@required
- (void)modalSheetVCShouldReloadData;

@end


@interface ModalSheetVC : UIViewController <ModalChildViewDelegate, PinCodeVCDelegate, QRCodeVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) id <ModalSheetVCDelegate> delegate;
- (void)setupChildWithTitle:(NSString *)title
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
- (void)setupChildWithTitle:(NSString *)title
	subtitle:(NSString *)subtitle
	buttonTitle:(NSString *)buttonTitle
	forTarget:(id)target
	forSelector:(SEL)selector
	secondButtonTitle:(NSString *)secondTitle
	forTarget:(id)secondTarget
	forSelector:(SEL)secondSelector
	accessoryImage:(UIImage *)accessoryImage
	secondAccessoryImage:(UIImage *)secondAccessoryImg
	prepareForReuse:(BOOL)prepare
	scaleAnimation:(BOOL)scaleAnim;
- (void)vcNeedsDismissal;
- (void)shouldCrossDissolveChildSubviews;
@end
