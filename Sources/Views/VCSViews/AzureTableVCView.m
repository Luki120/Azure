#import "AzureTableVCView.h"


@implementation AzureTableVCView {

	UILabel *placeholderLabel;

}

- (id)initWithDataSource:(id<UITableViewDataSource>)dataSource
	tableViewDelegate:(id<UITableViewDelegate>)delegate
	floatingButtonViewDelegate:(id<AzureFloatingButtonViewDelegate>)buttonDelegate {

	self = [super init];
	if(!self) return nil;

	[self setupViews];
	azureTableView.dataSource = dataSource;
	azureTableView.delegate = delegate;
	azureFloatingButtonView.delegate = buttonDelegate;

	return self;

}


- (void)setupViews {

	azureTableView = [UITableView new];
	azureTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	azureTableView.backgroundColor = kUserInterfaceStyle ? UIColor.systemBackgroundColor : UIColor.secondarySystemBackgroundColor;
	[self addSubview: azureTableView];

	azureFloatingButtonView = [AzureFloatingButtonView new];
	[self addSubview: azureFloatingButtonView];

	azureToastView = [AzureToastView new];
	[self addSubview: azureToastView];

	placeholderLabel = [UILabel new];
	placeholderLabel.font = [UIFont systemFontOfSize: 16];
	placeholderLabel.text = @"No issuers were added yet. Tap the + button in order to add one.";
	placeholderLabel.textColor = UIColor.placeholderTextColor;
	placeholderLabel.numberOfLines = 0;
	placeholderLabel.textAlignment = NSTextAlignmentCenter;
	placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview: placeholderLabel];

}

- (void)layoutSubviews {

	[super layoutSubviews];
	[self pinViewToAllEdgesIncludingSafeAreas:azureTableView bottomConstant: -50];

	[azureFloatingButtonView.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant: -74].active = YES;
	[azureFloatingButtonView.trailingAnchor constraintEqualToAnchor: self.trailingAnchor constant: -25].active = YES;
	[azureFloatingButtonView.widthAnchor constraintEqualToConstant: 60].active = YES;
	[azureFloatingButtonView.heightAnchor constraintEqualToConstant: 60].active = YES;

	[self pinAzureToastToTheBottomCenteredOnTheXAxis:azureToastView bottomConstant: -55];

	[placeholderLabel.centerXAnchor constraintEqualToAnchor: self.centerXAnchor].active = YES;
	[placeholderLabel.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
	[placeholderLabel.leadingAnchor constraintEqualToAnchor: self.leadingAnchor constant: 10].active = YES;
	[placeholderLabel.trailingAnchor constraintEqualToAnchor: self.trailingAnchor constant: -10].active = YES;

}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	[super traitCollectionDidChange: previousTraitCollection];

	// I want a clean light grayish in light mode, but pure black in dark mode, so :bThisIsHowItIs:
	azureTableView.backgroundColor = kUserInterfaceStyle
		? UIColor.systemBackgroundColor
		: UIColor.secondarySystemBackgroundColor;

}


- (void)animateViewsWhenNecessary {

	[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{

		if([TOTPManager sharedInstance]->entriesArray.count == 0) {
			azureTableView.alpha = 0;
			placeholderLabel.alpha = 1;
			placeholderLabel.transform = CGAffineTransformMakeScale(1, 1);
		}
		else {
			azureTableView.alpha = 1;
			placeholderLabel.alpha = 0;
			placeholderLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
		}

	} completion: nil];

}

@end
