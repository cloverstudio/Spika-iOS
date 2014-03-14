//
//  CSGraphics.h
//  ProjectOO
//
//  Created by Luka Fajl on 28.2.2013..
//  Copyright (c) 2013. Fajlworks. All rights reserved.
//

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

CG_INLINE CGRect CGRectWithRectAndEdgeInset(CGRect rect, UIEdgeInsets insets) {
    return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top, rect.size.width - insets.left - insets.right, rect.size.height - insets.top - insets.bottom);
}


#endif
