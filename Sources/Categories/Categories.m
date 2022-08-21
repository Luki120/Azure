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

	CGFloat scale = MAX(newSize.width / image.size.width, newSize.height / image.size.height);
	CGFloat width = image.size.width * scale;
	CGFloat height = image.size.height * scale;
	CGRect imageRect = CGRectMake(
		(newSize.width - width) / 2.0,
		(newSize.height - height) / 2.0,
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
