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
