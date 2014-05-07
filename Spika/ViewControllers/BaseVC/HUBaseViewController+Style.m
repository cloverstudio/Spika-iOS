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

#import "HUBaseViewController+Style.h"
#import "NSNotification+Extensions.h"
#import "HUBaseViewController+Style.h"
#import "HUButton.h"

@implementation HUBaseViewController (Style)

#pragma mark - UIButton Factory

+(HUButton *) buttonWithTitle:(NSString *)title
                        frame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                       target:(id)target
                     selector:(SEL)selector {
    
    HUButton *button = [HUButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundColor:backgroundColor];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:[HUBaseViewController fontForBarButtonItems]];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [button titleLabel].numberOfLines = 0;
    [button titleLabel].lineBreakMode = NSLineBreakByWordWrapping;
    
    return button;
}

#pragma mark - UIBarButtonItems NSArray

+ (NSArray *) barButtonItemWithTitle:(NSString *)title
                               frame:(CGRect)frame
                     backgroundColor:(UIColor *)backgroundColor
                              target:(id)target
                            selector:(SEL)selector {

    HUButton *button = [HUBaseViewController
                        buttonWithTitle:title
                        frame:frame
                        backgroundColor:backgroundColor
                        target:target
                        selector:selector];
    
    [button alignmentRectInsets];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    negativeSpacer.width = -5;
    // Note: We use 5 above b/c that's how many pixels of padding iOS seems to add
    // Add the two buttons together on the left:
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:button];

    return  [NSArray arrayWithObjects:
             btn,
             nil];
    
}

- (NSArray *) backBarButtonItemsWithSelector:(SEL)aSelector {

    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Back", nil)
                                                  frame:[self frameForBackButton]
                                        backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                 target:self
                                               selector:aSelector];
}

+ (NSArray *) dummyBarButtonItem{
    
    UIButton *dummyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    
    dummyButton.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    negativeSpacer.width = -5;

    return  [NSArray arrayWithObjects:
             negativeSpacer,
             [[UIBarButtonItem alloc] initWithCustomView:dummyButton],
             nil];

    
}

#pragma mark - Frames

+ (CGRect) frameForBarButtonWithTitle:(NSString *)title
                                 font:(UIFont *)font {

    
    //CGSize titleSize = [title sizeWithFont:[HUBaseViewController fontForBarButtonItems]
    //                     constrainedToSize:CGSizeMake(200, 20)];
    
    return CGRectMake(0, 0, BarButtonWidth, 44);
}

- (CGRect) frameForBackButton {
    
    CGRect frame = [HUBaseViewController frameForBarButtonWithTitle:NSLocalizedString(@"Back", @"")
                                                               font:[HUBaseViewController fontForBarButtonItems]];

    return frame;
}

#pragma mark - Colors

+ (UIColor *) sharedViewBackgroundColor {

    return [UIColor colorWithPatternImage:[UIImage imageWithBundleImage:@"hp_wall_background_pattern"]];
}

+ (UIColor *) sharedBarButtonItemColor {

    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
}

+ (UIColor *) sharedLabelDefaultColor {

    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark];
}

+ (UIColor *) sharedLabelDominantColor {

    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
}

+ (UIColor *) titleColorForButtonState:(UIControlState)state {

    return (state == UIControlStateNormal ? [UIColor whiteColor] : [UIColor grayColor]);
}

+ (UIColor *) colorWithSharedColorType:(HUSharedColorType)sharedColorType {

    if (sharedColorType == HUSharedColorTypeGreen) {
        return [UIColor colorWithIntegralRed:0 green:204 blue:123];
    }
    else if (sharedColorType == HUSharedColorTypeDark) {
        return [UIColor blackColor];
    }
    else if (sharedColorType == HUSharedColorTypeGray) {
        return [UIColor grayColor];
    }
    else if (sharedColorType == HUSharedColorTypeRed) {
        return [UIColor colorWithIntegralRed:235 green:0 blue:86];
    }
    else if (sharedColorType == HUSharedColorTypeDarkGreen) {
        return [UIColor colorWithIntegralRed:0 green:174 blue:93];
    }
    
    return nil;
}

- (UIColor *) colorForViewStateLabels {

    return [UIColor blackColor];
}

#pragma mark - Fonts

+ (UIFont *) fontForBarButtonItems {
    
    return kFontArialMTBoldOfSize(kFontSizeSmall);
}

#pragma mark - KeyboardEvent

-(void) autoresizeScrollView:(UIScrollView *)scrollView maximumScrollViewHeight:(CGFloat)height {
    
    [self autoresizeScrollView:scrollView maximumScrollViewHeight:height resizeHandler:nil];
    
}

-(void) autoresizeScrollView:(UIScrollView *)scrollView maximumScrollViewHeight:(CGFloat)height resizeHandler:(void (^)(NSNotification *))block {
    
    if (block == nil) {
        block = ^(NSNotification *note) {
            [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + scrollView.height) animated:YES];
        };
    }
    
    [self subscribeForKeyboardWillShowNotificationUsingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:[note keyboardAnimationDuration]
                         animations:^{
                             scrollView.height = height - [note keyboardFrameEnd].size.height - self.navigationController.navigationBar.height;
                         } completion:^(BOOL finished) {
                             block(note);
                         }];
    }];
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:[note keyboardAnimationDuration]
                         animations:^{
                             scrollView.height = height - self.navigationController.navigationBar.height;
                         }];
    }];
    
}

@end
