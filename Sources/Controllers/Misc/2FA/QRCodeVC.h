@import AVFoundation;
#import "Sources/Managers/Singletons/TOTPManager.h"
#import "Sources/Views/UI/AzureToastView.h"


@protocol QRCodeVCDelegate

@required

- (void)qrCodeVCDidCreateIssuerOutOfQRCode;

@end


@interface QRCodeVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, weak) id <QRCodeVCDelegate> delegate;
@end
