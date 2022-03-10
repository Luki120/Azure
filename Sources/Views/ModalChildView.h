#import "Sources/Constants/Constants.h"


@protocol ModalChildViewDelegate <NSObject>

@required

- (void)modalChildViewDidTapScanQRCodeButton;
- (void)modalChildViewDidTapImportQRImageButton;
- (void)modalChildViewDidTapEnterManuallyButton;

@end

@interface ModalChildView : UIView
@property (nonatomic, weak) id <ModalChildViewDelegate> delegate;
- (void)animateSubviews;
@end
