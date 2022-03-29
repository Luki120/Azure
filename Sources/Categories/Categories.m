//
//  Categories.m
//  Azure
//
//  Created by Luki120 on 3/8/2022.
//  Copyright © 2022 Luki120. All rights reserved.
//

#import "Categories.h"


@implementation UIBarButtonItem (Reusable)

+ (UIBarButtonItem *)getBarButtonItemWithImage:(UIImage *)image
	forTarget:(id)target
	forSelector:(SEL)selector {

	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
		initWithImage:image
		style:UIBarButtonItemStyleDone
		target:target
		action:selector
	];

	return barButtonItem;

}

@end


@implementation UIImage (Resize)

+ (UIImage *)resizeImageFromImage:(UIImage *)image withSize:(CGSize)size {

	CGSize newSize = size;

	CGFloat scale = MAX(newSize.width/image.size.width, newSize.height/image.size.height);
	CGFloat width = image.size.width * scale;
	CGFloat height = image.size.height * scale;
	CGRect imageRect = CGRectMake(
		(newSize.width - width)/2.0,
		(newSize.height - height)/2.0,
		width,
		height
	);

	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
	[image drawInRect: imageRect];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;

}

@end


@implementation UIView (Tools)

+ (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion {

	[UIView animateWithDuration:0.5 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:animations completion:completion];

}


+ (void)makeRotationTransformForView:(UIView *)view andLabel:(UILabel *)label {

	CATransform3D rotation = CATransform3DIdentity;
	rotation.m34 = 1.0 / -500; // idfk what this does but ok :lul:
	rotation = CATransform3DRotate(rotation, 180.0 * M_PI / 180, 0, 1, 0);
	view.layer.transform = rotation;
	label.layer.transform = rotation;

}


- (void)pinViewToAllEdges:(UIView *)view {

	view.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[view.topAnchor constraintEqualToAnchor: self.topAnchor],
		[view.bottomAnchor constraintEqualToAnchor: self.bottomAnchor],
		[view.leadingAnchor constraintEqualToAnchor: self.leadingAnchor],
		[view.trailingAnchor constraintEqualToAnchor: self.trailingAnchor]
	]];

}


- (void)pinViewToAllEdgesIncludingSafeAreas:(UIView *)view bottomConstant:(CGFloat)bottomConstant {

	view.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[view.topAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.topAnchor],
		[view.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant: bottomConstant],
		[view.leadingAnchor constraintEqualToAnchor: self.leadingAnchor],
		[view.trailingAnchor constraintEqualToAnchor: self.trailingAnchor]
	]];

}


- (void)pinAzureToastToTheBottomCenteredOnTheXAxis:(UIView *)azureToastView
	bottomConstant:(CGFloat)bottomConstant {

	azureToastView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[azureToastView.bottomAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.bottomAnchor constant: bottomConstant],
		[azureToastView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor]
	]];

}

@end
