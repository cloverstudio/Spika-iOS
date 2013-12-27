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

#import "HUSignUpViewController.h"
#import "DatabaseManager.h"
#import "CSGraphics.h"
#import "HUDataManager.h"
#import "AlertViewManager.h"
#import "HUDialog.h"

#define kTagSignUpSucceededAlert    700

@interface HUSignUpViewController () {
}

#pragma mark - Animations
- (void) showLoadingView:(BOOL) show animated:(BOOL) animated;
- (void) animateKeyboardWillShow:(NSNotification *)aNotification;
- (void) animateKeyboardWillHide:(NSNotification *)aNotification;

@end

@implementation HUSignUpViewController

#pragma mark - Memory Managemnt

- (void) dealloc {
    
    CS_RELEASE(_mainView);
    CS_RELEASE(_loginFieldsBackground);
    CS_RELEASE(_usernameField);
    CS_RELEASE(_emailField);
    CS_RELEASE(_passwordField);
    
    CS_SUPER_DEALLOC;
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    
    [_signInButton setTitle:NSLocalizedString(@"Login-Title", @"") forState:UIControlStateNormal];
    [_signUpButton setTitle:NSLocalizedString(@"SignUp-Title", @"") forState:UIControlStateNormal];

    
    /*
    _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainView.autoresizingMask = self.view.autoresizingMask;
    _mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainView];
    
    
    _loginFieldsBackground = CS_RETAIN([self newLoginFieldsBackground]);
    [_mainView addSubview:_loginFieldsBackground];
    
    _usernameField = CS_RETAIN([self newUsernameField]);
    _usernameField.delegate = self;
    [_loginFieldsBackground addSubview:_usernameField];
    
    _emailField = CS_RETAIN([self newEmailField]);
    _emailField.delegate = self;
    [_loginFieldsBackground addSubview:_emailField];
    
    _passwordField = CS_RETAIN([self newPasswordField]);
    _passwordField.delegate = self;
    [_loginFieldsBackground addSubview:_passwordField];
    
    _signInButton = [self newSignInButton];
    [_signInButton addTarget:self
                     action:@selector(onSignIn)
           forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:_signInButton];
    
    _signUpButton = CS_RETAIN([self newSignUpButton]);
    [_signUpButton addTarget:self
                     action:@selector(onSignUp)
           forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:_signUpButton];

    _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    _loadingView.autoresizingMask = self.view.autoresizingMask;
    _loadingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_loadingView];
    
     */
    
	 
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    __weak HUSignUpViewController *this = self;
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillShow:note];
    }];
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillHide:note];
    }];
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
                         
                         _loginFieldsBackground.y -= 10;
                         _signInButton.y -= 50;
                         _signUpButton.y -= 50;
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
                         
                         _loginFieldsBackground.y += 20;
                         _signInButton.y += 100;
                         _signUpButton.y += 100;
                     }
                     completion:nil];
}

#pragma mark - Override

- (NSString *) title {
    
    return NSLocalizedString(@"SignUp-Title", @"");
}

#pragma mark - Button Selectors

- (void) onSignUp {
    
    [self.view endEditing:YES];
    
    NSString *name = _usernameField.text;
    NSString *email = _emailField.text;
    NSString *password = _passwordField.text;
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(![self validationAsync]){
            [[AlertViewManager defaultManager] dismiss];
            return;
        }

        [[DatabaseManager defaultManager] createUserByEmail:email
                                                       name:name
                                                   password:password
                                                    success:^(BOOL isSuccess, NSString *errStr){
                                                        
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(isSuccess == YES){
                        
                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                        [userDefault setObject:email forKey:UserDefaultLastLoginEmail];
                        [userDefault setObject:password forKey:UserDefaultLastLoginPass];
                        [userDefault synchronize];
                        
                        HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"SignUp-Succeeded", @"") delegate:self cancelTitle:@"Ok" otherTitle:nil];
                        
                        [dialog show];
                        
                        dialog.tag = kTagSignUpSucceededAlert;
                        
                    }
                    else {
                        
                        [[AlertViewManager defaultManager] dismiss];
                        
                        [CSKit alertViewShowWithTitle:CS_APPLICATION_NAME
                                              message:errStr
                                             delegate:nil
                                         cancelButton:NSLocalizedString(@"OK", @"")
                                          otherButton:nil];
                    }
                });
            }
              error:^(NSString *errStr){
                 [[AlertViewManager defaultManager] dismiss];
        }];
        
    });
    

}

- (BOOL) validationAsync{
    
    if (!_usernameField.text || _usernameField.text.length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Username", @"")];

        return NO;
    }
    
    if (!_emailField.text || _emailField.text.length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Email", @"")];
       
        return NO;
    }
    
    if (!_passwordField.text || _passwordField.text.length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Password", @"")];

        return NO;
    }

    
    if(![[HUDataManager defaultManager] isNameOkay:_usernameField.text]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Name", @"")];
        
        return NO;
        
    }
    
    if(![[HUDataManager defaultManager] isPasswordOkay:_passwordField.text]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password message", @"")];
        
        return NO;
        
    }
    
    
    if(![[HUDataManager defaultManager] isEmailOkay:_emailField.text]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong email message", @"")];
        
        return NO;
        
    }
    
    /*
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"email" value:_emailField.text];
    
    if(result != nil){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate email", @"")];
        
        return NO;
        
    }
    
    result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"username" value:_usernameField.text];
    
    if(result != nil){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate username", @"")];
        
        return NO;
        
    }
    */
    
    return YES;
}

- (void) onSignIn {

    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - HUDialogDelegate

-(void) dialogDidPressCancel:(HUDialog *)dialog{
    
    if (dialog.tag == kTagSignUpSucceededAlert) {
        
        DMFindOneBlock successBlock = ^(ModelUser *user) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoginFinished
                                                                object:user];
        };
        
        DMErrorBlock errorBlock = ^(NSString *errorString) {
            [[AlertViewManager defaultManager] dismiss];
        };
        
        [[DatabaseManager defaultManager] loginUserByEmail:_emailField.text
                                                  password:_passwordField.text
                                                   success:successBlock
                                                     error:errorBlock];
        
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:_usernameField]) {
        [_emailField becomeFirstResponder];
    }
    else if ([textField isEqual:_emailField]) {
        [_passwordField becomeFirstResponder];
    }
    else {
        [_passwordField resignFirstResponder];
        [self onSignUp];
    }

    return YES;
}


@end
