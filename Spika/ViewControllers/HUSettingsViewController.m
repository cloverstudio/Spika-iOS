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
#import "HUSettingsViewController+Style.h"
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

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];

    [self addSlideButtonItem];
    
	self.title = NSLocalizedString(@"SETTINGS", nil);
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.allowsSelection = NO;
	self.tableView.scrollEnabled = NO;
	
	self.tableView.y = 10;
	self.tableView.height -= 10;
	
	UIButton *clearCacheButton = [self newClearCacheButtonWithSelector:@selector(clearCacheDidTap:)];
	clearCacheButton.center = self.view.center;
	clearCacheButton.y = self.view.height - self.navigationController.navigationBar.height - clearCacheButton.height*1.5f - 18;
	[self.view addSubview:clearCacheButton];
    
    
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
    [HUAvatarManager clearCache];
	
	[[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Cache cleared", nil)];
}

-(void) apiEndpointDidChange:(UITextField *)textField {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	DMErrorBlock errorBlock = ^(NSString *error) {
		[CSToast showToast:NSLocalizedString(@"API Endpoint contains error", nil) withDuration:1.0f];
		textField.text = [defaults objectForKey:UserDefaultAPIEndpoint];
	};
	
	DMUpdateBlock successBlock = ^(BOOL success, NSString *error) {
		if (success) {
			
		} else {
			errorBlock(error);
		}
	};
	
	[[DatabaseManager defaultManager] changeAPIEndpoint:textField.text
												success:successBlock
												  error:errorBlock];
	
}

-(void) savePassword:(NSString *)newPassword {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:newPassword forKey:UserDefaultPassword];
	[defaults synchronize];
}

-(void) passwordActiveDidChangeValue:(RCSwitch *)sender {

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
			[self.passwordSwitch setOn:YES animated:NO];
		}
	}];
	
	[self presentModalViewController:viewController animated:YES];
}

-(void) showSetNewPasswordModalViewController {

	HUPasswordSetNewViewController *viewController = [HUPasswordSetNewViewController passwordViewController:^(id controller, NSString *newPassword, BOOL isSuccess) {
		if (isSuccess) {
			[self savePassword:newPassword];
		} else {
			[self.passwordSwitch setOn:NO animated:NO];
		}
	}];
	
	[self presentModalViewController:viewController animated:YES];
}

-(BOOL) passwordExists {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword]);
}

#pragma mark - UITableViewDatasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 2;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return 60;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"CellIdentifier";
	
	UITableViewCell *cell = [CSKit tableViewCellDefault:cellIdentifier tableView:tableView];

	[self provideCellContent:cell forIndexPath:indexPath];
	
	return cell;
}


- (void)changePassword
{
    HUPasswordChangeDialog *dialog = [[HUPasswordChangeDialog alloc] initWithText:NSLocalizedString(@"Confirm delete group", nil)
                                                                         delegate:self
                                                                      cancelTitle:NSLocalizedString(@"Cancel", nil)
                                                                       otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"Save", nil),nil]];
    [dialog show];
}

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if(index != 0)
        return;
    
    HUPasswordChangeDialog *passwordDialog = (HUPasswordChangeDialog *) dialog;
    
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    
    if(![passwordDialog.oldPasswordView.text isEqualToString:user.password]){
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"InvalidPassword", nil)];
        return;
    }
    
    if(![[HUDataManager defaultManager] isPasswordOkay:passwordDialog.passwordView.text]){
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password message", @"")];
        return ;
    }
    
    if(![passwordDialog.passwordView.text isEqualToString:passwordDialog.confirmPasswordView.text]){
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"InvalidNewPassword", nil)];
        return;
    }
    
    [[DatabaseManager defaultManager] updatePassword:user newPassword:passwordDialog.passwordView.text
        success:^(BOOL succees,NSString *errStr){
            
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"PasswordChanged", nil)];
            
            
            [[DatabaseManager defaultManager] reloadUser:user
                success:^(id result) {
                    ModelUser *newuser = (ModelUser *) result;
                    
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:passwordDialog.passwordView.text forKey:UserDefaultLastLoginPass];
                    [userDefault setObject:passwordDialog.passwordView.text forKey:UserPassword];
                    [userDefault synchronize];
                    
                    newuser.password = passwordDialog.passwordView.text;
                    [[UserManager defaultManager] setLoginedUser:newuser];

                }
                error:^(NSString *errorString) {
                    NSLog(@"failed to reload user");
            }];

            

            
        } error:^(NSString *errStr){
            
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"FailedToChangePassword", nil)];
            
    }];
}

-(void) dialogDidPressCancel:(HUDialog *)dialog{
    
}

@end
