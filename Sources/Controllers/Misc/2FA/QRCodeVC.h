@import AVFoundation;
#import "Azure-Swift.h"
#import "Sources/Managers/Singletons/TOTPManager.h"


@protocol QRCodeVCDelegate

@required

- (void)qrCodeVCDidCreateIssuerOutOfQRCode;

@end


@interface QRCodeVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, weak) id <QRCodeVCDelegate> delegate;
@end
