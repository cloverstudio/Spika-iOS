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

#import "HUNewGroupViewController.h"
#import "CSToast.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "HUImageView.h"
#import "HUBaseViewController+Style.h"
#import "UIImagePickerController+Extensions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "AlertViewManager.h"
#import "HUDataManager.h"
#import "HUPickerTableView.h"
#import "HUGroupsCategoryTableViewCell.h"
#import "HUTextView.h"

@interface HUNewGroupViewController (){
    BOOL                _keyboardShowing;
    UIImage             *_avatarImage;
}

@property (nonatomic, weak) UITextView *activeTextView;

@end

@implementation HUNewGroupViewController

#pragma mark - Initialization

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        _keyboardShowing = NO;
    }
    
    return self;
}

#pragma mark - Override

-(void) loadView {
    
    [super loadView];
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-group-add",nil)];
    
    _categoryValueLabel.enabled = NO;
    _nameValueLabel.enabled = YES;
    _groupOwnerValueLabel.enabled = NO;
    _passwordValueLabel.enabled = YES;
    _aboutValueLabel.editable = YES;
    
    [_categoryValueLabel setText:@""];
    [_nameValueLabel setText:@""];
    [_groupOwnerValueLabel setText:[[UserManager defaultManager] getLoginedUser].name];
    [_passwordValueLabel setText:@""];
    [_aboutValueLabel setText:@""];
    
    [_saveButton setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [_categoryIconView setImage:nil];
    
    _isEditing = YES;
    
    [self showKeyboardDoneButtonForTextView:_aboutValueLabel];
    
}

-(void) updateAddButton{
}

- (void) layoutViews{
    [super layoutViews];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGPoint absolutePosition = [_cancelButton convertPoint:_cancelButton.frame.origin toView:_contentView];
        [_contentHeightConstraint setConstant:absolutePosition.y + _cancelButton.height + 20];
    });
    
    [_groupOwnerValueLabel setText:[[UserManager defaultManager] getLoginedUser].name];
    
}

- (void) viewWillAppear:(BOOL)animated{
        
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(onBack:)];
    self.navigationItem.title = NSLocalizedString(@"New Group", nil);

    HUNewGroupViewController *this = self;
    
    [self subscribeForKeyboardWillShowNotificationUsingBlock:^(NSNotification *note) {
        
    }];
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        [this animateKeyboardWillShow:note];
    }];
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        [this animateKeyboardWillHide:note];
    }];
    
    [self layoutViews];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self unsubscribeForKeyboardWillShowNotification];
    
    [self unsubscribeForKeyboardWillChangeFrameNotification];
    
    [self unsubscribeForKeyboardWillHideNotification];
    
}

#pragma mark - Keyboard Handling

- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    _keyboardShowing = YES;
    CGSize keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _contentView.height = self.view.height - keyboardSize.height;
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    _keyboardShowing = NO;
    _contentView.height = self.view.height;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self layoutViews];
}

- (IBAction)onBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction) onSave{
	
    [self.view endEditing:YES];
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Processing", nil)
                                           message:@""];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(![self validationAsync]){
            [[AlertViewManager defaultManager] dismiss];
            return;
        }

        NSString *groupName = [_nameValueLabel text];
        NSString *groupPassword = [_passwordValueLabel text];
        NSString *description = [_aboutValueLabel text];
        
        if (groupPassword == nil) groupPassword = @"";
        
        if (description == nil) description = @"";
        if (_selectedCategoryID == nil) _selectedCategoryID = @"";
        
        HUNewGroupViewController *this = self;
        
        [[DatabaseManager defaultManager]
         
         createGroup:groupName
         description:description
         password:groupPassword
         categoryID:_selectedCategoryID
         categoryName:_categoryValueLabel.text
         ower:[[UserManager defaultManager] getLoginedUser]
         avatarImage:_avatarImage
         success:^(BOOL isSuccess, NSString *errStr) {
             
             [[UserManager defaultManager] reloadUserDataWithCompletion:^(id result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [[AlertViewManager defaultManager] dismiss];

                     if (isSuccess == YES) {
                         
                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Group created successfully", nil)];
                         [this onBack:nil];
                         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuGroupsSelected object:nil];

                     } else {
                         [CSToast showToast:errStr withDuration:3.0];
                     }
                 });
             }];
             
             [CSToast showToast:NSLocalizedString(@"Success!", nil) withDuration:3.0];
             
         } error:^(NSString *errStr) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[AlertViewManager defaultManager] dismiss];
             });
         }];
        
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
    
    if([_passwordValueLabel text] != nil && [_passwordValueLabel text].length > 0 && ![[HUDataManager defaultManager] isPasswordOkay:[_passwordValueLabel text]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password message", @"")];
        
        return NO;
        
    }

    
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"findGroup/name" value:[_nameValueLabel text]];
    
    if(result != nil){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate groupname", @"")];
        
        return NO;
        
    }

    return YES;
}


#pragma mark - avatar


-(IBAction) avatarImageViewDidTap:(UITapGestureRecognizer *)recognizer {
    
    
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

@end
