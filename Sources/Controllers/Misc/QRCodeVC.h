@import AVFoundation;
#import "Sources/Managers/Animators/PopAnimator.h"
#import "Sources/Managers/Animators/PushAnimator.h"
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/UI/AzureToastView.h"


@protocol QRCodeVCDelegate

@required

- (void)qrCodeVCDidCreateIssuerOutOfQRCode;

@end


@interface QRCodeVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) id <QRCodeVCDelegate> delegate;
@end
