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

#import "HUSignUpViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import <QuartzCore/QuartzCore.h>

@implementation HUSignUpViewController (Style)

#pragma mark - UIImageViews

- (UIImageView *) newLoginFieldsBackground {
    
    UIImage *loginImage = [UIImage imageWithBundleImage:@"hp_signup_fields_background"];
    
    UIImageView *loginFieldsBackground = [CSKit imageViewWithImage:loginImage
                                                  highlightedImage:nil];
    loginFieldsBackground.userInteractionEnabled = YES;
    loginFieldsBackground.frame = [self frameForLoginFieldsBackground:NO];
    
    return loginFieldsBackground;
}

#pragma mark - UITextFields

- (UITextField *) newUsernameField {

    UITextField *usernameField = CS_RETAIN([CSKit textFieldWithFrame:CGRectMake(44, 15, 220, 30)
                                                                font:[self fontForTextField]
                                                                text:nil
                                                         placeholder:NSLocalizedString(@"Username", @"")]);
    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    usernameField.textColor = [self colorForTextField];
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.enablesReturnKeyAutomatically = YES;
    usernameField.returnKeyType = UIReturnKeyNext;
    usernameField.backgroundColor = [UIColor clearColor];
    
    [usernameField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    return usernameField;
}

- (UITextField *) newEmailField {

    UITextField *emailField = CS_RETAIN([CSKit textFieldWithFrame:CGRectMake(44, 65, 220, 30)
                                                 font:[self fontForTextField]
                                                 text:nil
                                          placeholder:NSLocalizedString(@"Email", @"")]);
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.textColor = [self colorForTextField];
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.enablesReturnKeyAutomatically = YES;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.backgroundColor = [UIColor clearColor];
    
    [emailField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    return emailField;
}
- (UITextField *) newPasswordField {

    UITextField *passwordField = CS_RETAIN([CSKit textFieldWithFrame:CGRectMake(44, 114, 220, 30)
                                                    font:kFontArialMTOfSize(kFontSizeMiddium)
                                                    text:nil
                                             placeholder:NSLocalizedString(@"Password", @"")]);
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.textColor = [self colorForTextField];
    passwordField.secureTextEntry = YES;
    passwordField.enablesReturnKeyAutomatically = YES;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.backgroundColor = [UIColor clearColor];
    
    [passwordField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    return passwordField;
}

#pragma mark - UIButtons

- (UIButton *) newSignInButton {
    
    CGRect buttonFrame = [self frameForSignInButton:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark] andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];;
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForSignInUpButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"Login-Title", @"") forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *) newSignUpButton {
    
    CGRect buttonFrame = [self frameForSignUpButton:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame]; 
    [button setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen] andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];;
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForSignInUpButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"SignUp-Title", @"") forState:UIControlStateNormal];
    
    return button;
}

#pragma mark - UIActivityIndicatorView

- (UIActivityIndicatorView *) newLoadingIndicatorView {
    
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

#pragma mark - Fonts

- (UIFont *) fontForTextField {
    
    return kFontArialMTOfSize(kFontSizeMiddium);
}

- (UIFont *) fontForSignInUpButtons {
    
    return kFontArialMTBoldOfSize(kFontSizeMiddium);
}

- (UIFont *) fontForLoadingLabel {

    return kFontArialMTBoldOfSize(kFontSizeBig);
}

#pragma mark - Colors

- (UIColor *) colorForTextField {
    
    return [UIColor colorWithRed:125/255. green:125/255. blue:125/255. alpha:1.0];
}

#pragma mark - Frames

- (CGRect) frameForLoginFieldsBackground:(BOOL)isUp {
    
    CGFloat originYAdd = ((CS_WINSIZE.height + [UIApplication sharedApplication].statusBarFrame.size.height) > 480 ? 15 : 0);
    
    UIImage *loginImage = [UIImage imageWithBundleImage:@"hp_signup_fields_background"];
    
    return CGRectMake(22, (isUp ? (originYAdd) : 30), loginImage.size.width, loginImage.size.height);
}

- (CGRect) frameForSignUpButton:(BOOL)isUp {
    
    CGSize signUpTitleSize = [NSLocalizedString(@"SignUp-Title", @"") sizeWithFont:[self fontForSignInUpButtons]
                                                                 constrainedToSize:CGSizeMake(200, 20)];
    
    signUpTitleSize = CGSizeMake(signUpTitleSize.width < 176 ?
                                 176 : signUpTitleSize.width + 10,
                                 36);
    
    int maring = 40;
    if(isUp)
        maring = 20;
    
    return CGRectMake(CGRectGetMidX(self.view.frame) - signUpTitleSize.width / 2,
                      CGRectGetMaxY([self frameForLoginFieldsBackground:isUp]) + maring,
                      signUpTitleSize.width,
                      signUpTitleSize.height);
}

- (CGRect) frameForSignInButton:(BOOL)isUp {
    
    CGSize signInTitleSize = [NSLocalizedString(@"Login-Title", @"") sizeWithFont:[self fontForSignInUpButtons]
                                                                constrainedToSize:CGSizeMake(300, 20)];
    
    signInTitleSize = CGSizeMake(signInTitleSize.width < 176 ?
                                 176 : signInTitleSize.width + 10,
                                 36);

    
    return CGRectMake(CGRectGetMidX(self.view.frame) - signInTitleSize.width / 2,
                      CGRectGetMaxY([self frameForSignUpButton:isUp]) + 14,
                      signInTitleSize.width,
                      signInTitleSize.height);
}



@end
