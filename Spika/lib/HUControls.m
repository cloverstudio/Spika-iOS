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

#import "HUControls.h"
#import "UIImage+Aditions.h"

#define kHUButtonSizeDefault CGSizeMake(176, 36)
#define kHUButtonFontSize 16
#define kHUButtonTextPadding 10

#define kHUTextFieldFontSize 18

@implementation HUControls

+(UIButton *) buttonWithCenter:(CGPoint) center
                localizedTitle:(NSString*) localizedTitle
               backgroundColor:(UIColor*) backgroundColor
                    titleColor:(UIColor*) titleColor
                        target:(id) target
                      selector:(SEL) selector
{
    NSString *text = NSLocalizedString(localizedTitle, @"");
    UIFont *font = kFontArialMTBoldOfSize(kHUButtonFontSize);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:[self buttonFrameForText:text font:font]];
    [button setCenter:center];
    [button setBackgroundImage:[UIImage imageWithColor:backgroundColor
                                               andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:font];
    [[button layer] setCornerRadius:button.height / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+(UITextField*) emailFieldWithFrame:(CGRect) frame {
    UITextField *emailField = [CSKit textFieldWithFrame:frame
                                                   font:kFontArialMTOfSize(kFontSizeMiddium)
                                                   text:nil
                                            placeholder:NSLocalizedString(@"Email", @"")];
    
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.textColor = kHUColorLightGray;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.enablesReturnKeyAutomatically = YES;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.backgroundColor = [UIColor clearColor];
    emailField.clearsOnBeginEditing = YES;
    
    [emailField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    return emailField;
}

+(UILabel*) labelWithFrame:(CGRect) frame
                      text:(NSString*) text
                  fontSize:(CGFloat) fontSize {
    UILabel *label = [CSKit labelWithFrame:frame
                                      font:kFontArialMTOfSize(fontSize)
                                 textColor:kHUColorDarkDarkGray
                             textAlignment:NSTextAlignmentLeft
                                      text:text];
    return label;
}

+(CGRect) buttonFrameForText:(NSString*) text font:(UIFont*) font {
    CGSize size = [text sizeForBoundingSize:kHUButtonSizeDefault
                                       font:font];
    
    CGFloat paddedWidth = size.width + kHUButtonTextPadding;
    size.width = paddedWidth > kHUButtonSizeDefault.width ? paddedWidth : kHUButtonSizeDefault.width;
    size.height = kHUButtonSizeDefault.height;
    return CGRectMake(0, 0, size.width, size.height);
}

@end
