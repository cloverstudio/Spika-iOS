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

#import "UIView+CoreGraphics.h"
#import <QuartzCore/QuartzCore.h>

extern void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
extern void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
extern void drawBorderInFrame(CGContextRef context, CGRect frame, CGFloat radius, CGFloat borderWidth, CGColorRef color);
extern void drawRectWithBottomCornerRadius(CGContextRef context, CGRect frame, CGFloat radius, CGColorRef color);
extern void addRoundedCornersToRect(CGContextRef context, CGRect frame, CGFloat radius, CGColorRef color);

extern CGRect rectFor1PxStroke(CGRect rect);

@implementation UIView (CoreGraphics)

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor) {
    
    NSArray *colors = nil;
    
#if !__has_feature(objc_arc)
    colors = [NSArray arrayWithObjects: (id)startColor, (id)endColor, nil];
#else
    colors = [NSArray arrayWithObjects: (__bridge id)startColor, (__bridge id)endColor, nil];
#endif
    
	CGFloat locations[] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    CGGradientRef gradient = NULL;
    
#if !__has_feature(objc_arc)
    gradient =  CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
#else
    gradient =  CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
#endif
    
	CGPoint top = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
	CGPoint bottom = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	CGContextDrawLinearGradient(context, gradient, top, bottom, 0);
	CGGradientRelease(gradient);
}


void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color) {
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);        
}

void drawBorderInFrame(CGContextRef context, CGRect frame, CGFloat radius, CGFloat borderWidth, CGColorRef color) {

    /*
     //if you want to fill rect add this
    CGContextSetRGBFillColor(context, 0,0,0,0.75);
    CGContextFillPath(context);
     */
        
    CGContextSetStrokeColorWithColor(context, color);
    
    CGContextSetLineWidth(context, borderWidth);
    
    CGContextMoveToPoint(context, 0.0, 0.0);	
    CGContextAddLineToPoint(context, frame.origin.x, frame.origin.y + frame.size.height - radius);
    CGContextAddArc(context, frame.origin.x + radius, frame.origin.y + frame.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height);
    CGContextAddArc(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + radius);
    CGContextAddArc(context, frame.origin.x + frame.size.width - radius, frame.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, frame.origin.x + radius, frame.origin.y);
    CGContextAddArc(context, frame.origin.x + radius, frame.origin.y + radius, radius, -M_PI / 2, M_PI, 1);

    CGContextStrokePath(context);
}

void drawRectWithBottomCornerRadius(CGContextRef context, CGRect frame, CGFloat radius, CGColorRef color) {

    CGContextSetFillColorWithColor(context, color);
 
    CGFloat aRadius = 0.0;
    
    CGContextMoveToPoint(context, 0.0, 0.0);	
    
    CGContextAddLineToPoint(context, frame.origin.x, frame.origin.y + frame.size.height - radius);
    CGContextAddArc(context, frame.origin.x + radius, frame.origin.y + frame.size.height - radius, radius, M_PI, M_PI / 2, 1);
    
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height);
    CGContextAddArc(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height - radius, radius, M_PI / 2, 0.0f, 1);
   
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + aRadius);
    CGContextAddArc(context, frame.origin.x + frame.size.width - aRadius, frame.origin.y + aRadius, aRadius, 0.0f, -M_PI / 2, 1);
    
    CGContextAddLineToPoint(context, frame.origin.x + aRadius, frame.origin.y);
    CGContextAddArc(context, frame.origin.x + aRadius, frame.origin.y + aRadius, aRadius, -M_PI / 2, M_PI, 1);
    
    CGContextClosePath(context); 
    CGContextDrawPath(context, kCGPathFill); 
}

void addRoundedCornersToRect(CGContextRef context, CGRect frame, CGFloat radius, CGColorRef color) {

    CGContextSetFillColorWithColor(context, color);
        
    CGContextMoveToPoint(context, 0.0, 0.0);	
    
    CGContextAddLineToPoint(context, frame.origin.x, frame.origin.y + frame.size.height - radius);
    CGContextAddArc(context, frame.origin.x + radius, frame.origin.y + frame.size.height - radius, radius, M_PI, M_PI / 2, 1);
    
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height);
    CGContextAddArc(context, frame.origin.x + frame.size.width - radius, frame.origin.y + frame.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    
    CGContextAddLineToPoint(context, frame.origin.x + frame.size.width, frame.origin.y + radius);
    CGContextAddArc(context, frame.origin.x + frame.size.width - radius, frame.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    
    CGContextAddLineToPoint(context, frame.origin.x + radius, frame.origin.y);
    CGContextAddArc(context, frame.origin.x + radius, frame.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    
    CGContextClosePath(context); 
    CGContextDrawPath(context, kCGPathFill); 
}

@end
