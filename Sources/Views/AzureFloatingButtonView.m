#import "AzureFloatingButtonView.h"


@implementation AzureFloatingButtonView

- (id)init {

	self = [super init];

	if(self) [self setupFloatingButton];

	return self;

}


- (void)setupFloatingButton {

	self.translatesAutoresizingMaskIntoConstraints = NO;

	self.floatingCreateButton = [UIButton new];
	self.floatingCreateButton.tintColor = UIColor.labelColor;
	self.floatingCreateButton.backgroundColor = kAzureMintTintColor;
	self.floatingCreateButton.layer.shadowColor = kUserInterfaceStyle ? UIColor.whiteColor.CGColor : UIColor.blackColor.CGColor;
	self.floatingCreateButton.layer.cornerRadius = 30;
	self.floatingCreateButton.layer.shadowRadius = 8;
	self.floatingCreateButton.layer.shadowOffset = CGSizeMake(0, 1);
	self.floatingCreateButton.layer.shadowOpacity = 0.5;
	self.floatingCreateButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.floatingCreateButton setImage: [UIImage systemImageNamed:@"plus" withConfiguration: [UIImageSymbolConfiguration configurationWithPointSize: 25]] forState: UIControlStateNormal];
	[self.floatingCreateButton addTarget:self action:@selector(didTapButton) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: self.floatingCreateButton];

	[self.floatingCreateButton.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;
	[self.floatingCreateButton.bottomAnchor constraintEqualToAnchor: self.bottomAnchor].active = YES;
	[self.floatingCreateButton.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[self.floatingCreateButton.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];
	self.floatingCreateButton.layer.shadowColor = kUserInterfaceStyle ? UIColor.whiteColor.CGColor : UIColor.blackColor.CGColor;

}

- (void)didTapButton {

	[self.delegate didTapFloatingButton];

}


- (void)animateViewWithAlpha:(CGFloat)alpha translateX:(CGFloat)tx translateY:(CGFloat)ty {

	[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		self.floatingCreateButton.alpha = alpha;
		self.floatingCreateButton.transform = CGAffineTransformMakeTranslation(tx, ty);

	} completion:nil];

}

@end
