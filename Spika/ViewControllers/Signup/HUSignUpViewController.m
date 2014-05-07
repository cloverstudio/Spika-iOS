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
#import "HUServerListViewController.h"

#define kTagSignUpSucceededAlert    700

@interface HUSignUpViewController ()

@end

@implementation HUSignUpViewController

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    
    [_signInButton setTitle:NSLocalizedString(@"Login-Title", @"") forState:UIControlStateNormal];
    [_signUpButton setTitle:NSLocalizedString(@"SignUp-Title", @"") forState:UIControlStateNormal];

  
    UIColor *color = [UIColor grayColor];
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_usernameField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_emailField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_passwordField.placeholder attributes:@{NSForegroundColorAttributeName: color}];

    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:serverBaseNamePrefered];
    if ([name length] > 0) {
        [_selectServerLabel setText:name];
    }
    else {
        [_selectServerLabel setText:[ServerManager serverBaseUrl]];
    }
    _selectServerLabel.adjustsFontSizeToFitWidth = YES;
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
    
    // update server label with correct server name or url
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:serverBaseNamePrefered];
    if ([name length] > 0) {
        [_selectServerLabel setText:name];
    }
    else {
        [_selectServerLabel setText:[ServerManager serverBaseUrl]];
    }
    _selectServerLabel.adjustsFontSizeToFitWidth = YES;
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
                         _signInButton.y -= 25;
                         _signUpButton.y -= 25;
                         _signUpInfoView.y -= 25;
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
                         _signInButton.y += 50;
                         _signUpButton.y += 50;
                         _signUpInfoView.y += 50;
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

- (IBAction)onServerTap:(id)sender {
    HUServerListViewController *vcServerList = [[HUServerListViewController alloc] initWithNibName:@"HUServerListViewController" bundle:nil];
    vcServerList.delegate = self;
    [self.navigationController pushViewController:vcServerList animated:YES];
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
    
    return YES;
}

- (void) onSignIn {

    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - HUDialogDelegate

- (void)dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index {

}

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

-(void)addItemViewController:(id)controller didFinishEnteringItem:(NSString *)item
{
    self.selectedUrl = item;
    _selectServerLabel.text = item;
    [self.navigationController popToViewController:self animated:YES];
}

@end
