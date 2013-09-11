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

#ifndef ProjectOO_CSGraphics_h
#define ProjectOO_CSGraphics_h

#import <CoreGraphics/CGBase.h>
#import <Foundation/Foundation.h>

CG_INLINE CGPoint CGPointShiftRight(CGPoint point, CGFloat number) {
    return CGPointMake(point.x + number, point.y);
}

CG_INLINE CGPoint CGPointShiftLeft(CGPoint point, CGFloat number) {
    return CGPointShiftRight(point, -number);
}

CG_INLINE CGPoint CGPointShiftDown(CGPoint point, CGFloat number) {
    return CGPointMake(point.x, point.y + number);
}

CG_INLINE CGPoint CGPointShiftUp(CGPoint point, CGFloat number) {
    return CGPointShiftDown(point, -number);
}

CG_INLINE CGRect CGRectWithPointAndSize(CGPoint point, CGSize size) {
    return CGRectMake(point.x, point.y, size.width, size.height);
};

CG_INLINE CGRect CGRectMakeWithPoint(CGPoint point, CGFloat width, CGFloat height) {
    return CGRectMake(point.x, point.y, width, height);
}

CG_INLINE CGRect CGRectMakeWithSize(CGFloat x, CGFloat y, CGSize size) {
    return CGRectMake(x, y, size.width, size.height);
}

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectSetCenter(CGRect rect, CGPoint point) {
    return CGRectMakeWithSize(point.x - rect.size.width * 0.5f, point.y - rect.size.height * 0.5f, rect.size);
}

CG_INLINE CGRect CGRectExpand(CGRect rect, CGFloat number) {
    return CGRectMake(rect.origin.x - number, rect.origin.y - number, rect.size.width + number * 2, rect.size.height + number * 2);
}

CG_INLINE CGRect CGRectContract(CGRect rect, CGFloat number) {
    return CGRectExpand(rect, -number);
}

CG_INLINE CGRect CGRectMakeBounds(CGFloat width, CGFloat height) {
    return CGRectMakeWithPoint(CGPointZero, width, height);
}

CG_INLINE CGRect CGRectMakeBoundsWithSize(CGSize size) {
    return CGRectWithPointAndSize(CGPointZero, size);
}

CG_INLINE CGRect CGRectShiftRight(CGRect rect, CGFloat number) {
    return CGRectWithPointAndSize(CGPointShiftRight(rect.origin, number), rect.size);
}

CG_INLINE CGRect CGRectShiftLeft(CGRect rect, CGFloat number) {
    return CGRectShiftRight(rect, -number);
}

CG_INLINE CGRect CGRectShiftDown(CGRect rect, CGFloat number) {
    return CGRectWithPointAndSize(CGPointShiftDown(rect.origin, number), rect.size);
}

CG_INLINE CGRect CGRectShiftUp(CGRect rect, CGFloat number) {
    return CGRectShiftDown(rect, -number);
}

#pragma mark - CoreGraphics

CG_INLINE CGPathRef CSTriangleCreate(CGPoint pt1, CGPoint pt2, CGPoint pt3) {
    CGAffineTransform t = CGAffineTransformIdentity;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &t, pt1.x, pt1.y);
    CGPathAddLineToPoint(path, &t, pt2.x, pt2.y);
    CGPathAddLineToPoint(path, &t, pt3.x, pt3.y);
    return path;
}

CG_INLINE void CSDrawTriangleFill(CGContextRef ctx, CGPoint pt1, CGPoint pt2, CGPoint pt3, UIColor *color) {
    CGContextSaveGState(ctx);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGPathRef path = CSTriangleCreate(pt1, pt2, pt3);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}

CG_INLINE void CSDrawRectangleFill(CGContextRef ctx, CGRect rect, UIColor *color) {
    CGContextSaveGState(ctx);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, rect);
    CGContextRestoreGState(ctx);
}


#endif
