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

#import "HUForgotPasswordViewController.h"
#import "HUControls.h"
#import "NSString+Extensions.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"

@implementation HUForgotPasswordViewController


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self addBackButton];
    
    // update server label with correct server name or url
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:serverBaseNamePrefered];
    if ([name length] > 0) {
        [_selectedServerLabel setText:name];
    }
    else {
        [_selectedServerLabel setText:[ServerManager serverBaseUrl]];
    }
    _selectedServerLabel.adjustsFontSizeToFitWidth = YES;
}

- (NSString *) title {
    
    return NSLocalizedString(@"ForgetPassword-Title", @"");
}

- (void) loadView {
    
    [super loadView];
     UIColor *color = [UIColor grayColor];
    _emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_emailField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    [_sendButton setTitle:NSLocalizedString(@"ForgotPassword-Send", @"") forState:UIControlStateNormal];

}


-(void) sendForgotPasswordRequest {
    
    [self.view endEditing:YES];
    
    if ([_emailField.text isValidEmail]) {

        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *result = [[DatabaseManager defaultManager] sendReminderSynchronous:_emailField.text];
            
            [[AlertViewManager defaultManager] dismiss];
            
            if([result rangeOfString:@"OK"].location != NSNotFound){
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"ForgotPassword-Sent", NULL)];
                _emailField.text = @"";
            }else{
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Email-Message", NULL)];
            }
            
        });
    }
    else {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Email-Message", NULL)];
        
    }
}

- (IBAction)onServerTap:(id)sender {
    HUServerListViewController *vcServerList = [[HUServerListViewController alloc] initWithNibName:@"HUServerListViewController" bundle:nil];
    vcServerList.delegate = self;
    [self.navigationController pushViewController:vcServerList animated:YES];
}

-(void)addItemViewController:(id)controller didFinishEnteringItem:(NSString *)item
{
    self.serverUrl = item;
    _selectedServerLabel.text = item;
    [self.navigationController popToViewController:self animated:YES];
}

@end
