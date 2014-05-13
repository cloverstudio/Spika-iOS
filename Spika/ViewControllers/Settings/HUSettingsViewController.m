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

#import "HUSettingsViewController.h"
#import "UILabel+Extensions.h"
#import "HUPasswordConfirmViewController.h"
#import "HUPasswordSetNewViewController.h"
#import "UIResponder+Extension.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "RCSwitch.h"
#import "HUPasswordChangeDialog.h"
#import "UserManager.h"
#import "AlertViewManager.h"
#import "HUDataManager.h"

@interface HUSettingsViewController ()

@end

@implementation HUSettingsViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];
    
    [self addSlideButtonItem];
    
	self.title = NSLocalizedString(@"SETTINGS", nil);
}

- (void) viewWillAppear:(BOOL)animated {
    _passwordLabel.text = NSLocalizedString(@"PASSWORD", nil);
    _changePasswordButton.titleLabel.text = NSLocalizedString(@"Change Password", nil);
    _passcodeProtectLabel.text = NSLocalizedString(@"PASSCODE PROTECT", nil);
    [_passcodeProtectSwitch setOn:[self passwordExists]];
    _clearCacheButton.titleLabel.text = NSLocalizedString(@"CLEAR CACHE", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector

-(void) clearCacheDidTap:(id)sender {
	   
	[[DatabaseManager defaultManager] clearCache];
	[[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Cache cleared", nil)];
}


-(void) savePassword:(NSString *)newPassword {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:newPassword forKey:UserDefaultPassword];
	[defaults synchronize];
}

-(void) passwordActiveDidChangeValue:(UISwitch *)sender {
    
	[[UIResponder currentFirstResponder] resignFirstResponder];
	if (sender.isOn) {
		[self showSetNewPasswordModalViewController];
	} else {
		[self showConfirmPasswordModalViewController];
	}
}

-(void) showConfirmPasswordModalViewController {
	
	HUPasswordConfirmViewController *viewController = [HUPasswordConfirmViewController passwordViewController:^(_HUPasswordBaseViewController *controller, BOOL isSuccess) {
		if (isSuccess) {
			[self savePassword:nil];
		} else {
			[_passcodeProtectSwitch setOn:YES animated:NO];
		}
	}];
	
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
}

-(void) showSetNewPasswordModalViewController {
    
	HUPasswordSetNewViewController *viewController = [HUPasswordSetNewViewController passwordViewController:^(id controller, NSString *newPassword, BOOL isSuccess) {
		if (isSuccess) {
			[self savePassword:newPassword];
		} else {
			[_passcodeProtectSwitch setOn:NO animated:NO];
		}
	}];
	
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
}

-(BOOL) passwordExists {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword]);
}

- (void) changePassword
{
    HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"Confirm Email", nil)
                                             delegate:self
                                          cancelTitle:NSLocalizedString(@"NO", nil)
                                           otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"YES", nil),nil]];
    [dialog show];
}


-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if(index == 0){
        
        ModelUser *user = [[UserManager defaultManager] getLoginedUser];
        NSString *email = user.email;
        
        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *result = [[DatabaseManager defaultManager] sendReminderSynchronous:email];
            
            [[AlertViewManager defaultManager] dismiss];
            
            if([result rangeOfString:@"OK"].location != NSNotFound){
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"ForgotPassword-Sent", NULL)];
            }else{
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Email-Message", NULL)];
            }
            
        });
    }
}

- (void)dialogDidPressCancel:(HUDialog *)dialog {

}

- (void) changePasswordClicked {
    [self changePassword];
}

- (void) passcodeProtectClicked {
    [self passwordActiveDidChangeValue:_passcodeProtectSwitch];
}

- (void) clearCacheClicked {
    [self clearCacheDidTap:nil];
}



@end
