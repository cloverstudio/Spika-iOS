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

#import "UIView+Extensions.h"
#import <objc/runtime.h>

static char const * const ObjectTagKey = "ObjectTag";

@implementation UIView (ObjectTag)
@dynamic objectTag;
- (id)objectTag {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setObjectTag:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)viewWithObjectTag:(id)object {
    // Raise an exception if object is nil
    if (object == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Argument to -viewWithObjectTag: must not be nil"];
    }
    
    // Recursively search the view hierarchy for the specified objectTag
    if ([self.objectTag isEqual:object]) {
        return self;
    }
    for (UIView *subview in self.subviews) {
        UIView *resultView = [subview viewWithObjectTag:object];
        if (resultView != nil) {
            return resultView;
        }
    }
    return nil;
}
@end

@implementation UIView (Frame)
@dynamic relativeWidth;
@dynamic relativeHeight;
@dynamic anchorPoint;

- (CGPoint)position {
    return [self frame].origin;
}

- (void)setPosition:(CGPoint)position {
    CGRect rect = [self frame];
    rect.origin = position;
    [self setFrame:rect];
}

- (CGFloat)x {
    return [self frame].origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect rect = [self frame];
    rect.origin.x = x;
    [self setFrame:rect];
}

- (CGFloat)y {
    return [self frame].origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect rect = [self frame];
    rect.origin.y = y;
    [self setFrame:rect];
}

- (CGSize)size {
    return [self frame].size;
}

- (void)setSize:(CGSize)size {
    CGRect rect = [self frame];
    rect.size = size;
    [self setFrame:rect];
}

- (CGFloat)width {
    return [self frame].size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect rect = [self frame];
    rect.size.width = width;
    [self setFrame:rect];
}

- (CGFloat)relativeWidth {
    return self.x + self.width;
}

- (CGFloat)height {
    return [self frame].size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect rect = [self frame];
    rect.size.height = height;
    [self setFrame:rect];
}

- (CGFloat)relativeHeight {
    return self.y + self.height;
}

-(void)setOrigin:(CGPoint)aPoint{
    
    CGRect newFrame = self.frame;
    newFrame.origin = aPoint;
    self.frame = newFrame;
    
}
-(void)setOriginY:(float)value{
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = value;
    self.frame = newFrame;
    
}
-(void)setOriginX:(float)value{
    
    CGRect newFrame = self.frame;
    newFrame.origin.x = value;
    self.frame = newFrame;
    
}

-(void)setSizeWidth:(float)value{
    
    CGRect newFrame = self.frame;
    newFrame.size.width = value;
    self.frame = newFrame;
    
}
-(void)setSizeHeight:(float)value{
    
    CGRect newFrame = self.frame;
    newFrame.size.height = value;
    self.frame = newFrame;
    
}
-(void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}
-(CGPoint) anchorPoint {
    return self.layer.anchorPoint;
}
CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;
    
    return transform;
}
-(void) setScale:(CGSize)scale {
    
    self.transform = makeTransform(scale.width, scale.height, self.rotation, self.translation.x, self.translation.y);
    
}
-(CGSize) scale {
    
    CGAffineTransform t = self.transform;
    
    CGFloat xScale = sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    
    return CGSizeMake(xScale, yScale);
}
-(void) setRotation:(CGFloat)rotation {
    
    self.transform = makeTransform(self.scale.width, self.scale.height, rotation, self.translation.x, self.translation.y);
    
}
-(CGFloat) rotation {
    
    CGAffineTransform t = self.transform;
    
    return atan2f(t.b, t.a);
    
}
-(void) setTranslation:(CGPoint)translation {
    
    self.transform = makeTransform(self.scale.width, self.scale.height, self.rotation, translation.x, translation.y);
    
}
-(CGPoint) translation {
    
    CGAffineTransform t = self.transform;
    
    return CGPointMake(t.tx, t.ty);
    
}

-(CGRect) convertFrameToView:(UIView *)toView {
    return [self convertRect:self.bounds toView:toView];
}
@end

@implementation UIView (Utility)

-(void) addSubviews:(UIView *)view, ... {
    
    va_list args;
    va_start(args, view);
    for (UIView *arg = view; arg != nil; arg = va_arg(args, UIView*))
    {
        [self addSubview:arg];
    }
    va_end(args);
    
}

-(void) removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

-(void) removeAllSubviewsRecursively {
    //possibly performance hungry
    for (UIView *subview in self.subviews) {
        if (subview.subviews.count != 0)
            [subview removeAllSubviewsRecursively];
        [subview removeFromSuperview];
    }
}

-(UIView*) findFirstResponder {
    for (UIView *subview in self.subviews)
        if ([subview isFirstResponder])
            return subview;
    
    return nil;
}

-(UIView*) findFirstResponderRecursively {
    
    UIView *firstResponder = nil;
    
    for (UIView *subview in self.subviews) {
        firstResponder = ([subview isFirstResponder])?subview:[subview findFirstResponderRecursively];
        if (firstResponder != nil) return firstResponder;
    }
    return firstResponder;
}

-(UIView *) topSubview {
    return self.subviews.lastObject;
}

-(void) deselectAllButtons
{
    for(UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton*) subview;
            button.selected = NO;
        }
    }
}

@end

@implementation UIView (GestureRecognizer)

-(void) removeAllGestureRecognizers {
    
    while (self.gestureRecognizers.count != 0) {
        [self removeGestureRecognizer:self.gestureRecognizers[0]];
    }
    
}

-(UITapGestureRecognizer *) addTapGestureRecognizerWithTarget:(id)target selector:(SEL)aSelector {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:aSelector];
    
    [self addGestureRecognizer:tap];
    
    return tap;
}

@end

@implementation UIView (Debug)

@dynamic debugMode, debugColor;

-(void) setDebugColor:(UIColor *)debugColor {
    objc_setAssociatedObject(self, @"DebugColor", debugColor, OBJC_ASSOCIATION_ASSIGN);
}

-(UIColor*) debugColor {
    return objc_getAssociatedObject(self, @"DebugColor");
}

-(void) setDebugMode:(BOOL)debugMode {
    self.layer.borderColor = (debugMode)? (self.debugColor)?self.debugColor.CGColor:[UIColor redColor].CGColor :nil;
    self.layer.borderWidth = (debugMode)?1:0;
    objc_setAssociatedObject(self, @"DebugMode", (debugMode)?@"YES":@"NO", OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL) debugMode {
    return [objc_getAssociatedObject(self, @"DebugMode") isEqualToString:@"YES"];
}

@end

@implementation UIView (Image)
-(UIImage *) imageOfView {
    if(UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(self.frame.size);
    }
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

