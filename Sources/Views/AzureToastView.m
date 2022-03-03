#import "AzureToastView.h"


@implementation AzureToastView {

	UIView *toastView;
	NSLayoutConstraint *bottomAnchorConstraint;

}

- (id)init {

	self = [super init];

	if(!self) return nil;

	[self setupToastView];

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fadeInOutCopyPinToastView) name:@"fadeInOutToast" object:nil];

	return self;

}


- (void)setupToastView {

	self.translatesAutoresizingMaskIntoConstraints = NO;

	toastView = [UIView new];
	toastView.alpha = 0;
	toastView.backgroundColor = kAzureMintTintColor;
	toastView.layer.cornerCurve = kCACornerCurveContinuous;
	toastView.layer.cornerRadius = 20;
	toastView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: toastView];

	toastViewLabel = [UILabel new];
	toastViewLabel.font = [UIFont systemFontOfSize: 14];
	toastViewLabel.textColor = UIColor.labelColor;
	toastViewLabel.numberOfLines = 0;
	toastViewLabel.textAlignment = NSTextAlignmentCenter;
	toastViewLabel.adjustsFontSizeToFitWidth = YES;
	toastViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[toastView addSubview: toastViewLabel];

	[toastView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor].active = YES;
	bottomAnchorConstraint = [toastView.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant : 50];
	bottomAnchorConstraint.active = YES;
	[toastView.widthAnchor constraintEqualToConstant: 120].active = YES;
	[toastView.heightAnchor constraintEqualToConstant: 40].active = YES;

	[toastViewLabel.centerXAnchor constraintEqualToAnchor: toastView.centerXAnchor].active = YES;
	[toastViewLabel.centerYAnchor constraintEqualToAnchor: toastView.centerYAnchor].active = YES;
	[toastViewLabel.leadingAnchor constraintEqualToAnchor: toastView.leadingAnchor constant: 10].active = YES;
	[toastViewLabel.trailingAnchor constraintEqualToAnchor: toastView.trailingAnchor constant: -10].active = YES;

}


- (void)fadeInOutCopyPinToastView {

	toastViewLabel.text = @"Copied!";
	[self fadeInOutToastViewWithFinalDelay: 0.2];

}


- (void)fadeInOutToastViewWithFinalDelay:(CGFloat)delay {

	[UIView animateViewWithDelay:0 withAnimations:^ {

		[self animateToastViewWithConstraintConstant: -20 andAlpha: 1];

	} withCompletion:^(BOOL finished) {

		[UIView animateViewWithDelay:0.2 withAnimations:^ {

			[UIView makeRotationTransformForView:toastView andLabel:toastViewLabel];
			[self layoutIfNeeded];

		} withCompletion:^(BOOL finished) {

			[UIView animateViewWithDelay:delay withAnimations:^ {

				[self animateToastViewWithConstraintConstant: 50 andAlpha: 0];

			} withCompletion:^(BOOL finished) {

				toastView.layer.transform = CATransform3DIdentity;
				toastViewLabel.layer.transform = CATransform3DIdentity;

			}];

		}];

	}];

}


- (void)animateToastViewWithConstraintConstant:(CGFloat)constant andAlpha:(CGFloat)alpha {

	bottomAnchorConstraint.constant = constant;
	toastView.alpha = alpha;
	[self layoutIfNeeded];

}

@end
