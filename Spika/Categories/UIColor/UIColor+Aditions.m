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

#import "UIColor+Aditions.h"

@implementation UIColor (Aditions)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    
    if (!hexString)
        return nil;

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)darkerColorForColor:(UIColor *)color {
    
    float r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColorForColor:(UIColor *)color
                       inPercent:(float)percent {
    
    percent = (percent > 1.0 ? 1.0 : percent);
    percent = (percent < 0.0 ? 0.0 : percent);
    
    float r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        
        return [UIColor colorWithRed:MAX(r - percent, 0.0)
                               green:MAX(g - percent, 0.0)
                                blue:MAX(b - percent, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)colorWithIntegralRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    CGFloat r = red / 255.0f, g = green / 255.0f, b = blue / 255.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
