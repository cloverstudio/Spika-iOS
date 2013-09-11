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

#import "HULoginViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import <QuartzCore/QuartzCore.h>

@implementation HULoginViewController (Style)

#pragma mark - UIViews

- (UIView *) loginContainer {
    
    UIView *loginContainer = CS_AUTORELEASE([[UIView alloc] initWithFrame:[self frameForLoginContainer:NO]]);
    loginContainer.backgroundColor = [UIColor clearColor];
    return loginContainer;
}

#pragma mark - UIImageViews

- (UIImageView *) loginFieldsBackground {

    UIImage *loginImage = [UIImage imageWithBundleImage:@"hp_login_fields_background"];
    
    UIImageView *loginFieldsBackground = [CSKit imageViewWithImage:loginImage
                                                  highlightedImage:nil];
    loginFieldsBackground.userInteractionEnabled = YES;
    loginFieldsBackground.frame = [self frameForLoginBackground];

    return loginFieldsBackground;
}

#pragma mark - UITextFields

- (UITextField *) emailField {

    UITextField *emailField = [CSKit textFieldWithFrame:CGRectMake(44, 19, 220, 30)
                                                   font:[self fontForTextField]
                                                   text:nil
                                            placeholder:NSLocalizedString(@"Email", @"")];
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.textColor = [self colorForTextField];
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.enablesReturnKeyAutomatically = YES;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.backgroundColor = [UIColor clearColor];
    emailField.keyboardType = UIKeyboardTypeEmailAddress;

    
    return emailField;
}

- (UITextField *) passwordField {

    UITextField *passwordField = [CSKit textFieldWithFrame:CGRectMake(44, 65, 220, 30)
                                                      font:[self fontForTextField]
                                                      text:nil
                                               placeholder:NSLocalizedString(@"Password", @"")];
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.textColor = [self colorForTextField];
    passwordField.secureTextEntry = YES;
    passwordField.enablesReturnKeyAutomatically = YES;
    passwordField.returnKeyType = UIReturnKeyDone;
    
    return passwordField;
}

#pragma mark - UIButtons

- (UIButton *) forgotDetailsButton {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:[self frameForForgotDetailsButton]];
    [[button titleLabel] setFont:[self fontForForgotDetailsButton]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[self colorForTextField] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Forgot-Details", @"") forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *) signInButton {

    CGRect buttonFrame = [self frameForSignInButton:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen] andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForSignInUpButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"Login-Title", @"") forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *) signUpButton {

    CGRect buttonFrame = [self frameForSignUpButton:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark] andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForSignInUpButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"SignUp-Title", @"") forState:UIControlStateNormal];
    
    return button;
}

#pragma mark - UIActivityIndicatorView

- (UIActivityIndicatorView *) loadingIndicatorView {

    UIActivityIndicatorView *indicatorView = CS_AUTORELEASE([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]);
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    indicatorView.hidesWhenStopped = YES;
    [indicatorView startAnimating];
    
    return indicatorView;
}

#pragma mark - Labels

- (UILabel *) loadingLabel:(CGRect)loadingIndicatorFrame {
    
    UILabel *loadingLabel = [CSKit labelWithFrame:CGRectMake(0,
                                                             CGRectGetMaxY(loadingIndicatorFrame) + 20,
                                                             CGRectGetWidth(self.view.frame),
                                                             22)
                                             font:[self fontForLoadingLabel]
                                        textColor:[UIColor whiteColor]
                                    textAlignment:UITextAlignmentCenter
                                             text:NSLocalizedString(@"Loading", @"")];
    
    return loadingLabel;
}

#pragma mark - Colors

- (UIColor *) colorForTextField {

    return [UIColor colorWithRed:125/255. green:125/255. blue:125/255. alpha:1.0];
}

#pragma mark - Fonts

- (UIFont *) fontForTextField {

    return kFontArialMTOfSize(kFontSizeMiddium);
}

- (UIFont *) fontForForgotDetailsButton {

    return kFontArialMTOfSize(kFontSizeSmall);
}

- (UIFont *) fontForSignInUpButtons {

    return kFontArialMTBoldOfSize(kFontSizeMiddium);
}

- (UIFont *) fontForLoadingLabel {
    
    return kFontArialMTBoldOfSize(kFontSizeBig);
}

#pragma mark - Frames

- (CGRect) frameForLoginContainer:(BOOL)isUp {
    
    CGFloat originYAdd = ((CS_WINSIZE.height + [UIApplication sharedApplication].statusBarFrame.size.height) > 480 ? 15 : 0);
    
    UIImage *loginImage = [UIImage imageWithBundleImage:@"hp_login_fields_background"];
    
    return CGRectMake(22, (isUp ? (originYAdd) : 30), loginImage.size.width, 135);
}

- (CGRect) frameForLoginBackground {

    UIImage *loginImage = [UIImage imageWithBundleImage:@"hp_login_fields_background"];
    
    return CGRectMake(0, 0, loginImage.size.width, loginImage.size.height);
}

- (CGRect) frameForForgotDetailsButton {
    
    CGSize forgotDetailsSize = [NSLocalizedString(@"Forgot-Details", @"") sizeWithFont:[self fontForForgotDetailsButton]
                                                                     constrainedToSize:CGSizeMake(300, 16)];
    
    CGRect loginBacgkroundFrame = [self frameForLoginBackground];
    
    return CGRectMake(CGRectGetMaxX(loginBacgkroundFrame) - forgotDetailsSize.width - 5,
                      CGRectGetMaxY(loginBacgkroundFrame) + 10,
                      forgotDetailsSize.width,
                      forgotDetailsSize.height);
}

- (CGRect) frameForSignInButton:(BOOL)isUp {
    
    CGFloat originYAdd = ((CS_WINSIZE.height + [UIApplication sharedApplication].statusBarFrame.size.height) > 480 ? 15 : 0);
        
    CGSize signInTitleSize = [NSLocalizedString(@"Login-Title", @"") sizeWithFont:[self fontForSignInUpButtons]
                                                                constrainedToSize:CGSizeMake(300, 20)];
    
    signInTitleSize = CGSizeMake(signInTitleSize.width < 176 ?
                                 176 : signInTitleSize.width + 10,
                                 36);
    
    return CGRectMake(CGRectGetMidX(self.view.frame) - signInTitleSize.width / 2,
                      CGRectGetMaxY([self frameForLoginContainer:isUp]) + (isUp ? (10 + originYAdd) : 55),
                      signInTitleSize.width,
                      signInTitleSize.height);
}


- (CGRect) frameForSignUpButton:(BOOL)isUp {
    
    CGSize signUpTitleSize = [NSLocalizedString(@"SignUp-Title", @"") sizeWithFont:[self fontForSignInUpButtons]
                                                                 constrainedToSize:CGSizeMake(200, 20)];
    
    signUpTitleSize = CGSizeMake(signUpTitleSize.width < 176 ?
                                 176 : signUpTitleSize.width + 10,
                                 36);
    
    return CGRectMake(CGRectGetMidX(self.view.frame) - signUpTitleSize.width / 2,
                      CGRectGetMaxY([self frameForSignInButton:isUp]) + 14,
                      signUpTitleSize.width,
                      signUpTitleSize.height);
}

@end
