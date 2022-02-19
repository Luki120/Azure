#import "AzureToastView.h"


@implementation AzureToastView {

	UIView *copyPinToastView;
	UILabel *copiedPinLabel;
	NSLayoutConstraint *bottomAnchorConstraint;

}

- (id)init {

	self = [super init];

	if(!self) return nil;

	[self setupToastView];

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fadeToast) name:@"fadeInOutToast" object:nil];

	return self;

}


- (void)setupToastView {

	self.translatesAutoresizingMaskIntoConstraints = NO;

	copyPinToastView = [UIView new];
	copyPinToastView.alpha = 0;
	copyPinToastView.backgroundColor = kAzureTintColor;
	copyPinToastView.layer.cornerCurve = kCACornerCurveContinuous;
	copyPinToastView.layer.cornerRadius = 20;
	copyPinToastView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: copyPinToastView];

	copiedPinLabel = [UILabel new];
	copiedPinLabel.font = [UIFont systemFontOfSize: 14];
	copiedPinLabel.text = @"Copied!";
	copiedPinLabel.textColor = UIColor.labelColor;
	copiedPinLabel.textAlignment = NSTextAlignmentCenter;
	copiedPinLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[copyPinToastView addSubview: copiedPinLabel];

	[copyPinToastView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor].active = YES;
	bottomAnchorConstraint = [copyPinToastView.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant : 50];
	bottomAnchorConstraint.active = YES;
	[copyPinToastView.widthAnchor constraintEqualToConstant: 120].active = YES;
	[copyPinToastView.heightAnchor constraintEqualToConstant: 40].active = YES;

	[copiedPinLabel.centerXAnchor constraintEqualToAnchor: copyPinToastView.centerXAnchor].active = YES;
	[copiedPinLabel.centerYAnchor constraintEqualToAnchor: copyPinToastView.centerYAnchor].active = YES;

}


- (void)fadeToast {

	[self animateViewWithDelay:0 withAnimations:^ {

		[self animateToastViewWithConstraintConstant: -20 andAlpha: 1];

	} withCompletion:^(BOOL finished) {

		[self animateViewWithDelay:0.2 withAnimations:^ {

			CATransform3D rotation = CATransform3DIdentity;
			rotation.m34 = 1.0 / - 500; // idfk what this does but ok :lul:
			rotation = CATransform3DRotate(rotation, 180.0 * M_PI / 180, 0, 1, 0);
			copyPinToastView.layer.transform = rotation;
			copiedPinLabel.layer.transform = rotation;
			[self layoutIfNeeded];

		} withCompletion:^(BOOL finished) {

			[self animateViewWithDelay:0.5 withAnimations:^ {

				[self animateToastViewWithConstraintConstant: 50 andAlpha: 0];

			} withCompletion:^(BOOL finished) {

				copyPinToastView.layer.transform = CATransform3DIdentity;
				copiedPinLabel.layer.transform = CATransform3DIdentity;

			}];

		}];

	}];

}


- (void)animateToastViewWithConstraintConstant:(CGFloat)constant andAlpha:(CGFloat)alpha {

	bottomAnchorConstraint.constant = constant;
	copyPinToastView.alpha = alpha;
	[self layoutIfNeeded];

}


- (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion {

	[UIView animateWithDuration:0.5 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animations completion:completion];

}

@end
