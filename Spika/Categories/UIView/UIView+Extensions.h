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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (ObjectTag)
@property (nonatomic, strong) id objectTag;
-(UIView*)viewWithObjectTag:(id)object;
@end

@interface UIView (Frame)
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGSize size;
@property CGFloat width;
@property CGFloat height;
@property (readonly) CGFloat relativeWidth;
@property (readonly) CGFloat relativeHeight;
@property CGPoint anchorPoint;
@property CGSize scale;
@property CGFloat rotation;
@property CGPoint translation;
-(void)setOrigin:(CGPoint)aPoint;
-(void)setOriginY:(float)value;
-(void)setOriginX:(float)value;
-(void)setSize:(CGSize)aSize;
-(void)setSizeWidth:(float)value;
-(void)setSizeHeight:(float)value;
-(void)setScale:(CGSize)scale;
-(void)setRotation:(CGFloat)rotation;
-(CGRect) convertFrameToView:(UIView *)toView;
@end

@interface UIView (Utility)
-(void) addSubviews:(UIView*)view, ... NS_REQUIRES_NIL_TERMINATION;
-(void)removeAllSubviews;
-(void)removeAllSubviewsRecursively;
-(UIView*)findFirstResponder;
-(UIView*)findFirstResponderRecursively;
-(UIView*)topSubview;
-(void) deselectAllButtons;
@end

@interface UIView (GestureRecognizer)
-(void) removeAllGestureRecognizers;
-(UITapGestureRecognizer *) addTapGestureRecognizerWithTarget:(id)target selector:(SEL)aSelector;
@end

@interface UIView (Debug)
@property BOOL debugMode;
@property (nonatomic, strong) UIColor *debugColor;
@end

@interface UIView (Image)
-(UIImage *) imageOfView;
@end