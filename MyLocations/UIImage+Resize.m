//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by  Jierism on 16/8/16.
//  Copyright © 2016年  Jierism. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

// 设置图片缩略图，并修改其大小，减少内存的占用
- (UIImage *)resizedImageWithBounds:(CGSize)bounds
{
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
