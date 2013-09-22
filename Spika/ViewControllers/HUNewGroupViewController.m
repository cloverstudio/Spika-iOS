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
#import "HUNewGroupViewController+Style.h"
#import "HUGroupProfileViewController+Style.h"
#import "CSToast.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "HUImageView.h"
#import "HUBaseViewController+Style.h"
#import "UIImagePickerController+Extensions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "AlertViewManager.h"
#import "HUDataManager.h"

@interface HUNewGroupViewController (){
    BOOL                _keyboardShowing;
    UIButton            *_saveButton;
    UIImage             *_avatarImage;
}

@property (nonatomic, weak) UITextView *activeTextView;

@end

@implementation HUNewGroupViewController

#pragma mark - Dealloc

-(void) dealloc {
    CS_RELEASE(_saveButton);
    CS_SUPER_DEALLOC;
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        _keyboardShowing = NO;
        

        
    }
    
    return self;
}

#pragma mark - Override

- (void) viewDidLoad{
    
    [super viewDidLoad];
    
    [self hideStartConverstationBtn];
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-group-add",nil)];
    
    self.view.backgroundColor = [self viewBackgroundColor];

    _saveButton = [self newSaveButtonWithSelector:@selector(onSave)];
    [_contentView addSubview:_saveButton];
    [_views addObject:_saveButton];
    
    // activate editors
	[_categoryLabel setEditing:YES];
    [_nameLabel setEditing:YES];
    [_passwordLabel setEditing:YES];
    CGRect rect = _passwordLabel.frame;
    rect.size.height = kEditableLabelHeight;
    _passwordLabel.frame = rect;
    
    _groupOwnerLabel.hidden = YES;

    
    [_aboutLabel setEditing:YES];
    
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap:)]];
    [_avatarView setUserInteractionEnabled:YES];
    
    
}

- (void) viewWillAppear:(BOOL)animated{
        
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(onBack:)];
    self.navigationItem.title = NSLocalizedString(@"New Group", nil);

    [self layoutViews];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self layoutViews];
}

- (void)onBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) onSave{
	
	[self resignActiveTextViewAndHideKeyboard];
    [self.view endEditing:YES];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(![self validationAsync]){
            return;
        }

        NSString *groupName = [_nameLabel getEditorText];
        NSString *groupPassword = [_passwordLabel getEditorText];
        NSString *description = [_aboutLabel getEditorText];
        
        if (groupPassword == nil) groupPassword = @"";
        
        if (description == nil) description = @"";
        if (_selectedCategoryID == nil) _selectedCategoryID = @"";
        
        [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Processing", nil)
                                               message:@""];
        
        [[DatabaseManager defaultManager]
         
         createGroup:groupName
         description:description
         password:groupPassword
         categoryID:_selectedCategoryID
         categoryName:_categoryLabel.textView.text
         ower:[[UserManager defaultManager] getLoginedUser]
         avatarImage:_avatarImage
         success:^(BOOL isSuccess, NSString *errStr) {
             
             [[UserManager defaultManager] reloadUserDataWithCompletion:^(id result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [[AlertViewManager defaultManager] dismiss];

                     if (isSuccess == YES) {
                         
                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Group created successfully", nil)];
                         [self dismissModalViewControllerAnimated:YES];
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
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate groupname", @"")];
        
        return NO;
        
    }
    
    return YES;
}


#pragma mark - avatar

-(void) avatarImageViewDidTap:(UITapGestureRecognizer *)recognizer {
    
    
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

@end
