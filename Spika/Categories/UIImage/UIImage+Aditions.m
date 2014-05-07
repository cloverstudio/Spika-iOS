/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "UIImage+Aditions.h"
#import "UIColor+Aditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Aditions)

+ (UIImage *) imageWithColor:(UIColor *)color andSize:(CGSize)size {

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *) circleImageWithColor:(UIColor *)color andSize:(CGSize)size {
    
    UIImage *image = [UIImage imageWithColor:color andSize:size];
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, size.width, size.height);
    imageLayer.contents = (id) image.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = size.width / 2;
    
    UIGraphicsBeginImageContext(size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

+ (UIImage *) circleImageWithColor:(UIColor *)color
                              size:(CGSize)size
                    borderDarkness:(float)darnkess {
    
    UIImage *image = [UIImage imageWithColor:color andSize:size];
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, size.width, size.height);
    imageLayer.contents = (id) image.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = size.width / 2;
    
    imageLayer.shadowOffset = CGSizeMake(0, 1);
    imageLayer.shadowRadius = 1.0;
    imageLayer.shadowColor = [UIColor darkerColorForColor:color inPercent:darnkess].CGColor;
    imageLayer.shadowOpacity = 1.0;
    
    
//    imageLayer.borderWidth = 1.0;
//    imageLayer.borderColor = [UIColor darkerColorForColor:color inPercent:darnkess].CGColor;
    
    UIGraphicsBeginImageContext(size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

@end
