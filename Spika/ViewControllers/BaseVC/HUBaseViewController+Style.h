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

#import "HUBaseViewController.h"
#import "UIColor+Aditions.h"
#import "UIImage+Aditions.h"
#import "HUButton.h"

@interface HUBaseViewController (Style)

#pragma mark - UIButton Factory

+(HUButton *) buttonWithTitle:(NSString *)title
                        frame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                       target:(id)target
                     selector:(SEL)selector;

#pragma mark - UIBarButtonItems NSArray
+ (NSArray *) barButtonItemWithTitle:(NSString *)title
                               frame:(CGRect)frame
                     backgroundColor:(UIColor *)backgroundColor
                              target:(id)target
                            selector:(SEL)selector;


+ (NSArray *) dummyBarButtonItem;

- (NSArray *) backBarButtonItemsWithSelector:(SEL)aSelector;




#pragma mark - Frames
+ (CGRect) frameForBarButtonWithTitle:(NSString *)title
                                 font:(UIFont *)font;
- (CGRect) frameForBackButton;

#pragma mark - Colors
+ (UIColor *) sharedViewBackgroundColor;
+ (UIColor *) sharedBarButtonItemColor;
+ (UIColor *) sharedLabelDefaultColor;
+ (UIColor *) sharedLabelDominantColor;
+ (UIColor *) titleColorForButtonState:(UIControlState)state;
+ (UIColor *) colorWithSharedColorType:(HUSharedColorType)color;

#pragma mark - Fonts
+ (UIFont *) fontForBarButtonItems;

#pragma mark - KeyboardEvent
-(void) autoresizeScrollView:(UIScrollView *)scrollView maximumScrollViewHeight:(CGFloat)height;
-(void) autoresizeScrollView:(UIScrollView *)scrollView maximumScrollViewHeight:(CGFloat)height resizeHandler:(void(^)(NSNotification *note))block;
@end
