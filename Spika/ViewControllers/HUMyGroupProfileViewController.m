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
#import "HUMyGroupProfileViewController+Style.h"
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
#import "CSDispatcher.h"
#import "HUEditableLabelView.h"
#import "HUPickerTableView.h"
#import "HUDataManager.h"
#import "Utils.h"
#import "HUPasswordChangeDialog.h"

@interface HUMyGroupProfileViewController (){
    BOOL                _isEditing;
    BOOL                _keyboardShowing;
    UIButton            *_saveButton;
    UIButton            *_deleteButton;
    UIImage             *_avatarImage;
}

@property BOOL didUpdateGroup;

@end

@implementation HUMyGroupProfileViewController

-(void) loadView {
    
    [super loadView];
    
    _isEditing = NO;
    self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
    
    _saveButton = [self newSaveButtonWithSelector:@selector(onSave)];
    _saveButton.topMargin = 10;
    [self hideView:_saveButton];
    [_contentView addSubview:_saveButton];
    [_views addObject:_saveButton];
    
    _deleteButton = [self newDeleteButtonWithSelector:@selector(confirmDelete)];
    _deleteButton.topMargin = 10;
    [self hideView:_deleteButton];
    [_contentView addSubview:_deleteButton];
    [_views addObject:_deleteButton];
    
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap:)]];
    [_avatarView setUserInteractionEnabled:YES];
    
    //[_passwordLabel setPasswordEntry:YES];
}

- (void) tuggleEdit{
    
    
    /*
    if(_keyboardShowing){
        [self.view endEditing:YES];
        _keyboardShowing = NO;
    }
    if(_isEditing){
        
        
        _isEditing = NO;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self hideView:_passwordLabel];
                             [self hideView:_saveButton];
                             [self hideView:_deleteButton];
                             [self layoutViews];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        [_nameLabel setEditing:NO];
        [_passwordLabel setEditing:NO];
        [_aboutLabel setEditing:NO];
		[_categoryLabel setEditing:NO];
        
        _startConversationBtn.hidden = NO;
        _groupOwnerLabel.hidden = NO;
        
        [self populateViews];
        
    }else{
        _isEditing = YES;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self showView:_passwordLabel height:kEditableLabelHeight];
                             [self showView:_saveButton height:36];
                             [self showView:_deleteButton height:36];
                             [self layoutViews];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        [_nameLabel setEditing:YES];
        [_passwordLabel setEditing:YES];
        [_aboutLabel setEditing:YES];
		[_categoryLabel setEditing:YES];
        
        _startConversationBtn.hidden = YES;
        _groupOwnerLabel.hidden = YES;

        
    }
    
    [self layoutViews];
    */
}

- (void) populateViews{
    [super populateViews];
    
    //[_passwordLabel setEditerText:_group.password];
}

-(void) loadAvatar{
    [super loadAvatar];
    
    if(_avatarImage != nil){
        [_avatarView setImage:_avatarImage];
    }
        
}


#pragma mark - View Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_didUpdateGroup = NO;
}

#pragma mark - avatar

-(void) avatarImageViewDidTap:(UITapGestureRecognizer *)recognizer {
    
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
    [self dismissModalViewControllerAnimated:YES];
    [self layoutViews];
    
}

-(void) confirmDelete{
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
    
    if(index == 0)
        [self onDelete];
    
}

-(void) onDelete {
    
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

-(void) onSave{
	
    /*
	[self resignActiveTextViewAndHideKeyboard];
    
    if(_keyboardShowing){
        [self.view endEditing:YES];
        _keyboardShowing = NO;
        [self hideKeyboardFor:nil];
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        
        if(![self validationAsync]){
            return;
        }
        
        NSString *groupName = [_nameLabel getEditorText];
        NSString *groupPassword = [_passwordLabel getEditorText];
        NSString *description = [_aboutLabel getEditorText];
        
        if (groupPassword == nil) groupPassword = @"";
        
        if ((groupName == nil) || [groupName isEqualToString:@""]) {
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Name", nil)];
            return;
        }
        
        if (description == nil) description = @"";
        if (_selectedCategoryID == nil) _selectedCategoryID = @"";
        
        _group.name = groupName;
        
        if(![groupPassword isEqualToString:@""]){
            groupPassword = [Utils MD5:groupPassword];
        }
        
        _group.password = groupPassword;
        _group.description = description;
        _group.categoryId = _selectedCategoryID;
        _group.categoryName = _categoryLabel.textView.text;
        
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
    */
}


- (BOOL) validationAsync{
    
    /*
    if (![_nameLabel getEditorText] || [_nameLabel getEditorText].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Name", @"")];
        
        return NO;
    }
    
    if (![_aboutLabel getEditorText] || [_aboutLabel getEditorText].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Group-Description", @"")];
        
        return NO;
    }
    
    if(![[HUDataManager defaultManager] isNameOkay:[_nameLabel getEditorText]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Name", @"")];
        
        return NO;
        
    }
    
    if([_passwordLabel getEditorText] != nil && [_passwordLabel getEditorText].length > 0 && ![[HUDataManager defaultManager] isPasswordOkay:[_passwordLabel getEditorText]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password message", @"")];
        
        return NO;
        
    }
    
    
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"groupname" value:[_nameLabel getEditorText]];
    
    if(result != nil){
        
        NSString *foundId = [result objectForKey:@"_id"];
        
        if(![_group._id isEqualToString:foundId]){

            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate groupname", @"")];
            
            return NO;
            
        }
        
    }
    
     */
    
    return YES;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    // open password change dialog
    if (textView.superview == _passwordLabel) {
        
        HUPasswordChangeDialog *dialog = [[HUPasswordChangeDialog alloc] initWithText:NSLocalizedString(@"Change Group Password", nil)
                                                                             delegate:self
                                                                          cancelTitle:NSLocalizedString(@"Cancel", nil)
                                                                           otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"Save", nil),nil]];
        [dialog show];
        
		return YES;
	}
    
    return [super textViewShouldBeginEditing:textView];
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
