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

#import "HULoginViewController.h"
#import "HULoginViewController+Style.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "UIView+Apperance.h"
#import "HUDataManager.h"
#import "AlertViewManager.h"
#import "Utils.h"

#import <QuartzCore/QuartzCore.h>

@interface HULoginViewController () {
    
    UIView          *_mainView;
    
    UIView          *_loginContainer;
    
    UITextField     *_emailField;
    UITextField     *_passwordField;
    
    UIButton        *_signInButton;
    UIButton        *_signUpButton;
}

#pragma mark - Animations
- (void) animateKeyboardWillShow:(NSNotification *)aNotification;
- (void) animateKeyboardWillHide:(NSNotification *)aNotification;

@end

@implementation HULoginViewController

#pragma mark - Memory Managemnt


- (void) dealloc {

    CS_RELEASE(_mainView);
    
    CS_RELEASE(_loginContainer);
    CS_RELEASE(_emailField);
    CS_RELEASE(_passwordField);
    CS_RELEASE(_signInButton);
    
    CS_SUPER_DEALLOC;
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(
        0,0,[Utils getDisplayWidth],[Utils getDisplayHeight]
    )];
    
    _mainView.autoresizingMask = self.view.autoresizingMask;
    _mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainView];
        
    _loginContainer = [self loginContainer];
    [_mainView addSubview:_loginContainer];
    
    UIImageView *loginFieldsBackground = [self loginFieldsBackground];
    [_loginContainer addSubview:loginFieldsBackground];
    
    _emailField = CS_RETAIN([self emailField]);
    _emailField.delegate = self;
    _emailField.isAccessibilityElement = YES;
    [loginFieldsBackground addSubview:_emailField];
    
    _passwordField = CS_RETAIN([self passwordField]);
    _passwordField.delegate = self;
    _emailField.isAccessibilityElement = YES;
    [loginFieldsBackground addSubview:_passwordField];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:UserDefaultLastLoginEmail]) {
        _emailField.text = [defaults objectForKey:UserDefaultLastLoginEmail];
        _passwordField.text = [defaults objectForKey:UserDefaultLastLoginPass];
    } else {

    }
    
    UIButton *forgotDetailsButton = [self forgotDetailsButton];
    [forgotDetailsButton addTarget:self
                            action:@selector(onForgotDetails)
                  forControlEvents:UIControlEventTouchUpInside];
    forgotDetailsButton.isAccessibilityElement = YES;
    [_loginContainer addSubview:forgotDetailsButton];

    
    _signInButton = [self signInButton];
    [_signInButton addTarget:self
                      action:@selector(onSignIn)
            forControlEvents:UIControlEventTouchUpInside];
    _signInButton.isAccessibilityElement = YES;
    _signInButton.accessibilityLabel = @"signin";
   [_mainView addSubview:_signInButton];
    
    
    _signUpButton = [self signUpButton];
    [_signUpButton addTarget:self
                  action:@selector(onSignUp)
          forControlEvents:UIControlEventTouchUpInside];
    _signUpButton.isAccessibilityElement = YES;
    [_mainView addSubview:_signUpButton];

    
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
	
    self.navigationItem.leftBarButtonItem = nil;

    __weak HULoginViewController *this = self;
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillShow:note];
    }];
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillHide:note];
    }];
     

}

- (void) viewDidAppear:(BOOL)animated{
	
	[super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *didAlreadySignedIn = [defaults objectForKey:DidAlreadyAutoSignedIn];
    
    if(didAlreadySignedIn == nil && _emailField.text != nil && _emailField.text.length > 0 && _passwordField.text != nil && _passwordField.text.length > 0){
        [self onSignIn];
        
        [defaults setValue:@"true" forKey:DidAlreadyAutoSignedIn];
        [defaults synchronize];

    }
}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    
    [self unsubscribeForKeyboardWillChangeFrameNotification];
    [self unsubscribeForKeyboardWillHideNotification];
    
}

#pragma mark - Animations

- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGSize kbSize = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect scrollContainerFrame = self.view.bounds;
    scrollContainerFrame.size.height -= kbSize.height;
    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^(){
                         
                         _loginContainer.frame = [self frameForLoginContainer:YES];
                         _signInButton.frame = [self frameForSignInButton:YES];
                         _signUpButton.frame = [self frameForSignUpButton:YES];
                     }
                     completion:nil];
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^(){
                         
                         _loginContainer.frame = [self frameForLoginContainer:NO];
                         _signInButton.frame = [self frameForSignInButton:NO];
                         _signUpButton.frame = [self frameForSignUpButton:NO];
                         
                     }
                     completion:nil];
}

#pragma mark - Override

- (NSString *) title {
    return NSLocalizedString(@"Login-Title", @"");
}

#pragma mark - Button Selectors

- (void) onForgotDetails {
    [self.navigationController pushViewController:[CSKit viewControllerFromString:@"HUForgotPasswordViewController"]
                                         animated:YES];
}

- (void) onSignIn {

    [self.view endEditing:YES];
    
    if (!_emailField.text || _emailField.text.length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Email", @"")];

        return;
    }
    
    if (!_passwordField.text || _passwordField.text.length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Password", @"")];
        
        return;
    }
    

    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    NSString *email = _emailField.text;
    NSString *password = _passwordField.text;
    
    __block NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    __block NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    DMFindOneBlock successBlock = ^(ModelUser *user){
        
        if(user){
            
            [userDefault setObject:email forKey:UserDefaultLastLoginEmail];
            [userDefault setObject:password forKey:UserDefaultLastLoginPass];
            [userDefault synchronize];
            
            [notificationCenter postNotificationName:NotificationLoginFinished object:user];
        }
        else{
            
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Incorrect-Login", @"")];
            
        }
        
    };
    
    DMErrorBlock errorBlock = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Incorrect-Login", @"")];
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager] loginUserByEmail:email
                                              password:password
                                               success:successBlock
                                                 error:errorBlock];
}

- (void) onSignUp {

    self.navigationController.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController] pushViewController:[CSKit viewControllerFromString:@"HUSignUpViewController"]
                                           animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {

    if ([textField isEqual:_emailField]) {
        [_passwordField becomeFirstResponder];
    }
    else {
		if ([[HUDataManager defaultManager] isPasswordOkay:_passwordField.text]) {
			[_passwordField resignFirstResponder];
			[self onSignIn];
		} else {
			[CSToast showToast:NSLocalizedString(@"Wrong password message", nil) withDuration:2.0];
		}
    }
    
    return YES;
}

@end
