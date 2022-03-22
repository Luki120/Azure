#import "AzureFloatingButtonView.h"


@implementation AzureFloatingButtonView {

	UIButton *floatingCreateButton;

}

- (id)init {

	self = [super init];

	if(self) [self setupFloatingButton];

	return self;

}


- (void)setupFloatingButton {

	self.translatesAutoresizingMaskIntoConstraints = NO;

	floatingCreateButton = [UIButton new];
	floatingCreateButton.tintColor = UIColor.labelColor;
	floatingCreateButton.backgroundColor = kAzureMintTintColor;
	floatingCreateButton.layer.shadowColor = UIColor.labelColor.CGColor;
	floatingCreateButton.layer.cornerRadius = 30;
	floatingCreateButton.layer.shadowRadius = 8;
	floatingCreateButton.layer.shadowOffset = CGSizeMake(0, 1);
	floatingCreateButton.layer.shadowOpacity = 0.5;
	floatingCreateButton.translatesAutoresizingMaskIntoConstraints = NO;
	[floatingCreateButton setImage: [UIImage systemImageNamed:@"plus" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:25]] forState: UIControlStateNormal];
	[floatingCreateButton addTarget:self action:@selector(didTapButton) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: floatingCreateButton];

	[floatingCreateButton.topAnchor constraintEqualToAnchor: self.topAnchor].active = YES;
	[floatingCreateButton.bottomAnchor constraintEqualToAnchor: self.bottomAnchor].active = YES;
	[floatingCreateButton.leadingAnchor constraintEqualToAnchor: self.leadingAnchor].active = YES;
	[floatingCreateButton.trailingAnchor constraintEqualToAnchor: self.trailingAnchor].active = YES;

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];
	floatingCreateButton.layer.shadowColor = UIColor.labelColor.CGColor;

}


- (void)didTapButton { [self.delegate azureFloatingButtonViewDidTapFloatingButton]; }


- (void)animateViewWithAlpha:(CGFloat)alpha translateX:(CGFloat)tx translateY:(CGFloat)ty {

	[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		floatingCreateButton.alpha = alpha;
		floatingCreateButton.transform = CGAffineTransformMakeTranslation(tx, ty);

	} completion:nil];

}

@end
