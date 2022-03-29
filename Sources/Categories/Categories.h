//
//  Categories.h
//  Azure
//
//  Created by Luki120 on 3/8/2022.
//  Copyright © 2022 Luki120. All rights reserved.
//

@import UIKit;


@interface UIBarButtonItem (Reusable)
+ (UIBarButtonItem *)getBarButtonItemWithImage:(UIImage *)image
	forTarget:(id)target
	forSelector:(SEL)selector;
@end


@interface UIImage (Resize)
+ (UIImage *)resizeImageFromImage:(UIImage *)image withSize:(CGSize)size;
@end


@interface UIView (Tools)
+ (void)animateViewWithDelay:(CGFloat)delay
	withAnimations:(void (^)(void))animations
	withCompletion:(void(^)(BOOL finished))completion;
+ (void)makeRotationTransformForView:(UIView *)view andLabel:(UILabel *)label;
- (void)pinViewToAllEdges:(UIView *)view;
- (void)pinViewToAllEdgesIncludingSafeAreas:(UIView *)view bottomConstant:(CGFloat)bottomConstant;
- (void)pinAzureToastToTheBottomCenteredOnTheXAxis:(UIView *)azureToastView
	bottomConstant:(CGFloat)bottomConstant;
@end
