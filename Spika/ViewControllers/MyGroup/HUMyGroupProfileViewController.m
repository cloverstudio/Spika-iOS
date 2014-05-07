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

#import "HUMyGroupProfileViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "UIImagePickerController+Extensions.h"
#import "DatabaseManager.h"
#import "AppDelegate.h"
#import "HUImageView.h"
#import "UIResponder+Extension.h"
#import "HUBaseViewController+Style.h"
#import "AlertViewManager.h"
#import "CSToast.h"
#import "UserManager.h"
#import "CSNotificationView.h"
#import "HUEditableLabelView.h"
#import "HUPickerTableView.h"
#import "HUDataManager.h"
#import "Utils.h"
#import "HUPasswordChangeDialog.h"

@interface HUMyGroupProfileViewController (){
    BOOL                _keyboardShowing;
    UIImage             *_avatarImage;
}

@property BOOL didUpdateGroup;

@end

@implementation HUMyGroupProfileViewController

-(void) loadView {
    
    [super loadView];
    
    _isEditing = NO;
    self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
    
    [_saveButton setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
    [_deleteButton setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    
    _categoryValueLabel.enabled = NO;
    _nameValueLabel.enabled = NO;
    _groupOwnerValueLabel.enabled = NO;
    _passwordValueLabel.enabled = NO;
    _aboutValueLabel.editable = NO;
    
    _saveButton.hidden = YES;
    _saveButton.enabled = NO;
    
    _deleteButton.hidden = YES;
    _deleteButton.enabled = NO;
    
    [_avatarView setUserInteractionEnabled:NO];
    
    [self showKeyboardDoneButtonForTextView:_aboutValueLabel];
}

- (void) tuggleEdit{
    
    if(_keyboardShowing){
        [self.view endEditing:YES];
        _keyboardShowing = NO;
    }
    if(_isEditing){
        
        _isEditing = NO;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        _categoryValueLabel.enabled = NO;
        _nameValueLabel.enabled = NO;
        _groupOwnerValueLabel.enabled = NO;
        _passwordValueLabel.enabled = NO;
        _aboutValueLabel.editable = NO;
        
        _saveButton.hidden = YES;
        _saveButton.enabled = NO;
        
        _deleteButton.hidden = YES;
        _deleteButton.enabled = NO;
        
        [_avatarView setUserInteractionEnabled:NO];
        
    }else{
        _isEditing = YES;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        _categoryValueLabel.enabled = NO;
        _nameValueLabel.enabled = YES;
        _groupOwnerValueLabel.enabled = NO;
        _passwordValueLabel.enabled = NO;
        _aboutValueLabel.editable = YES;
        
        _saveButton.hidden = NO;
        _saveButton.enabled = YES;
        
        _deleteButton.hidden = NO;
        _deleteButton.enabled = YES;
        
        [_avatarView setUserInteractionEnabled:YES];
        
    }
    
    [self populateViews];
    [self layoutViews];
    
}

-(NSArray *) editProfileBarButtonItemWithSelector:(SEL)aSelector editing:(BOOL) editing{
	
	if(editing){
        return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                            backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                     target:self
                                                   selector:aSelector];
        
    }else{
        return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Edit", nil)
                                                      frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                            backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]
                                                     target:self
                                                   selector:aSelector];
        
    }
}


- (void) populateViews{
    [super populateViews];
}

#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_didUpdateGroup = NO;
}

#pragma mark - avatar

-(IBAction) avatarImageViewDidTap:(UITapGestureRecognizer *)recognizer {
    
    if(_isEditing == NO)
        return;
    
    void(^dismissBlock)(int buttonIndex) = ^(int buttonIndex){
        buttonIndex == 0 ? [self showPhotoCameraWithDelegate:self] : [self showPhotoLibraryWithDelegate:self];
    };
    
    void(^cancelBlock)(void) = ^{
        
        
    };
    
    [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"Please select source", nil)
                                message:nil
                                buttons:@[NSLocalizedString(@"Camera", nil),NSLocalizedString(@"Album", nil)]
                             showInView:self.view
                              onDismiss:dismissBlock
                               onCancel:cancelBlock];
    
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image
                 editingInfo:(NSDictionary*)editingInfo{
    
    
    _avatarImage = [image copy];
    _avatarView.image = image;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [self layoutViews];
}

-(IBAction) confirmDelete{
    HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"Confirm delete group", nil)
                                             delegate:self
                                          cancelTitle:NSLocalizedString(@"NO", nil)
                                           otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"YES", nil),nil]];
    [dialog show];
}

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if([dialog isKindOfClass:[HUPasswordChangeDialog class]]){
        
        HUPasswordChangeDialog *passwordDialog = (HUPasswordChangeDialog *) dialog;
        
        if(_group.password.length != 0){
            
            if([_group.password isEqualToString:[Utils MD5:passwordDialog.oldPasswordView.text]]){
                
                
                
            }else{
                
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"InvalidPassword", nil)];
                return;
                
            }
            
        }else{
            
            if([passwordDialog.oldPasswordView.text length] > 0){
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"InvalidPassword", nil)];
                return;
            }
            
        }
        
        if([passwordDialog.passwordView.text length] > 0){
            if(![[HUDataManager defaultManager] isPasswordOkay:passwordDialog.passwordView.text]){
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password message", @"")];
                return ;
            }
            
            if(![passwordDialog.passwordView.text isEqualToString:passwordDialog.confirmPasswordView.text]){
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"InvalidNewPassword", nil)];
                return;
            }
        }
        
        NSString *newPassword = passwordDialog.passwordView.text;
        
        if(newPassword.length != 0){
            _group.password = [Utils MD5:newPassword];
        }else{
            _group.password = @"";
        }
        
        HUMyGroupProfileViewController *this = self;
        
        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
        
        [[DatabaseManager defaultManager] updateGroup:_group avatarImage:_avatarImage success:^(BOOL isSuccess, NSString *errorStr) {
            
            [[AlertViewManager defaultManager] dismiss];
            
            if (isSuccess) {
                
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Group updated", nil)];
                [this tuggleEdit];
                
                [[DatabaseManager defaultManager] reloadGroup:_group success:^(id result) {
                    
                    this.group = result;
                    [this populateViews];
                    this.didUpdateGroup = YES;
                    
                } error:^(NSString *errorString) {
                    
                }];
                
            } else {
                [[AlertViewManager defaultManager] dismiss];
            }
            
        } error:^(NSString *errorString) {
            [[AlertViewManager defaultManager] dismiss];
        }];
        
        return;
    }
    
    if(index == 0) {
        [self onDelete];
    }
}

-(void) dialogDidPressCancel:(HUDialog *)dialog {

}

-(IBAction) onDelete {
    
    if(_keyboardShowing){
        [self.view endEditing:YES];
        _keyboardShowing = NO;
        [self hideKeyboardFor:nil];
    }
    
    DMErrorBlock errorBlock = ^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertViewManager defaultManager] dismiss];
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)];
        });
    };
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Processing", nil)
										   message:@""];
    
    [[DatabaseManager defaultManager] deleteGroup:_group success:^(BOOL isSuccess, NSString *errorString) {
        
        [[AlertViewManager defaultManager] dismiss];
        if (isSuccess) {
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Group deletedt", nil)];
            
            [[DatabaseManager defaultManager] reloadUser:[[UserManager defaultManager] getLoginedUser] success:^(id result){
                
                if(result != nil){
                    
                    [[AlertViewManager defaultManager] dismiss];
                    
                    [[UserManager defaultManager] setLoginedUser:(ModelUser *) result];
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuGroupsSelected object:nil];
                    
                }
                
            } error:^(NSString *errstr){
                
                [[AlertViewManager defaultManager] dismiss];
                
            }];
            
            
        } else {
            errorBlock(errorString);
        }
    } error:errorBlock];
    
}

-(IBAction) onSave{
    
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if(![self validationAsync]){
            return;
        }
        
        NSString *groupName = [_nameValueLabel text];
        NSString *description = [_aboutValueLabel text];
        
        if ((groupName == nil) || [groupName isEqualToString:@""]) {
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Name", nil)];
            return;
        }
        
        if (description == nil) description = @"";
        if (_selectedCategoryID == nil) _selectedCategoryID = @"";
        
        _group.name = groupName;
        
        _group.description = description;
        _group.categoryId = _selectedCategoryID;
        _group.categoryName = _categoryValueLabel.text;
        
        [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Processing", nil)
                                               message:@""];
        
        DMErrorBlock errorBlock = ^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AlertViewManager defaultManager] dismiss];
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)
                                                     message:errorString];
            });
        };
        
        __weak HUMyGroupProfileViewController *this = self;
        [[DatabaseManager defaultManager] updateGroup:_group avatarImage:_avatarImage success:^(BOOL isSuccess, NSString *errorStr) {
            
            [[AlertViewManager defaultManager] dismiss];
            
            if (isSuccess) {
                
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Group updated", nil)];
                [this tuggleEdit];
                
                
                [[DatabaseManager defaultManager] reloadGroup:_group success:^(id result) {
                    
                    this.group = result;
                    [this populateViews];
                    this.didUpdateGroup = YES;
                    
                } error:^(NSString *errorString) {
                    
                }];
                
            } else {
                errorBlock(errorStr);
            }
            
        } error:errorBlock];
        
    });
    
}

- (BOOL) validationAsync{
    
    if (![_nameValueLabel text] || [_nameValueLabel text].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Name", @"")];
        
        return NO;
    }
    
    if (![_aboutValueLabel text] || [_aboutValueLabel text].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Description", @"")];
        
        return NO;
    }
    
    if(![[HUDataManager defaultManager] isNameOkay:[_nameValueLabel text]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Name", @"")];
        
        return NO;
        
    }
    
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"findGroup/name" value:[_nameValueLabel text]];
    
    
    if(result != nil){
        
        NSString *foundId = [result objectForKey:@"_id"];
        
        if(![_group._id isEqualToString:foundId]){
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate username", @"")];
            return NO;
        }
        
    }
    
    
    return YES;
}


-(IBAction) onChangePassword{
    
    if(_isEditing == NO)
        return;
    
    HUPasswordChangeDialog *dialog = [[HUPasswordChangeDialog alloc] initWithText:NSLocalizedString(@"Change Group Password", nil)
                                                                         delegate:self
                                                                      cancelTitle:NSLocalizedString(@"Cancel", nil)
                                                                       otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"Save", nil),nil]];
    [dialog show];
}

#pragma mark - HUImageUploadViewConrollerDelegate Methods

- (void) imageUploadViewController:(HUImageUploadViewController *)viewController
                   didUpdateObject:(id)object
{
	
}

#pragma mark -

-(void)onBack:(id)sender
{
	if (_didUpdateGroup) {
		NSDictionary *info = @{ @"updated_group":self.group.copy };
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationGroupUpdated object:nil userInfo:info];
	}
	
	[super onBack:sender];
}

@end
