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
#import "DatabaseManager.h"
#import "CSToast.h"
#import "UIView+Apperance.h"
#import "HUDataManager.h"
#import "AlertViewManager.h"
#import "Utils.h"
#import "HUSignUpViewController.h"
#import "HUForgotPasswordViewController.h"
#import "HUServerListViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface HULoginViewController () {
    

}

#pragma mark - Animations
- (void) animateKeyboardWillShow:(NSNotification *)aNotification;
- (void) animateKeyboardWillHide:(NSNotification *)aNotification;

@end

@implementation HULoginViewController

#pragma mark - View Lifecycle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
    }
    return self;
}


- (void) viewDidLoad{
    [super viewDidLoad];
    
}

- (void) loadView {

    [super loadView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:UserDefaultLastLoginEmail]) {
        _emailField.text = [defaults objectForKey:UserDefaultLastLoginEmail];
        _passwordField.text = [defaults objectForKey:UserDefaultLastLoginPass];
    } else {
        
    }
    
    [_forgotDetailsButton setTitle:NSLocalizedString(@"Forgot-Details", @"") forState:UIControlStateNormal];
    [_signInButton setTitle:NSLocalizedString(@"Login-Title", @"") forState:UIControlStateNormal];
    [_signUpButton setTitle:NSLocalizedString(@"SignUp-Title", @"") forState:UIControlStateNormal];

    UIColor *color = [UIColor grayColor];
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_emailField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_passwordField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    
    __weak HULoginViewController *this = self;
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillShow:note];
    }];
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillHide:note];
    }];
}


- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
	
    self.navigationItem.leftBarButtonItem = nil;
    
    // update server label with correct server name or url
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:serverBaseNamePrefered];
    if ([name length] > 0) {
        [_serverURLLabel setText:name];
    }
    else {
        [_serverURLLabel setText:[ServerManager serverBaseUrl]];
    }
    _serverURLLabel.adjustsFontSizeToFitWidth = YES;

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
                         
                         _loginContainer.y -= 10;
                         _signInButton.y -= 25;
                         _signUpButton.y -= 25;

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

                         _loginContainer.y += 20;
                         _signInButton.y += 50;
                         _signUpButton.y += 50;
                         
                     }
                     completion:nil];
}

#pragma mark - Override

- (NSString *) title {
    return NSLocalizedString(@"Login-Title", @"");
}

#pragma mark - Button Selectors

- (void) onForgotDetails {
    HUForgotPasswordViewController *vc = [[HUForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordView" bundle:nil];
    
    [self.navigationController pushViewController:vc
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
    
    HUSignUpViewController *vc = [[HUSignUpViewController alloc] initWithNibName:@"SignupView" bundle:nil];
    
    [[self navigationController] pushViewController:vc
                                           animated:YES];
}

-(IBAction) onServerTap{

    HUServerListViewController *vcServerList = [[HUServerListViewController alloc] initWithNibName:@"HUServerListViewController" bundle:nil];
    vcServerList.delegate = self;
    [self.navigationController pushViewController:vcServerList animated:YES];

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

-(void)addItemViewController:(id)controller didFinishEnteringItem:(NSString *)item
{
    self.selectedUrl = item;
    _serverURLLabel.text = item;
    [self.navigationController popToViewController:self animated:YES];
}

@end
