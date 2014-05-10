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

#import "HUMyProfileViewController.h"
#import "HUBaseViewController.h"
#import "UserManager.h"
#import "HUImageUploadViewController.h"
#import "AppDelegate.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "UIImagePickerController+Extensions.h"
#import "NSNotification+Extensions.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "HUBaseViewController+Style.h"
#import "NSDateFormatter+SharedFormatter.h"
#import "HUEditableLabelView.h"
#import "HUDatePicker.h"
#import "Utils.h"
#import "HUImageView.h"
#import "HUPickerTableView.h"
#import "AlertViewManager.h"
#import "HUDataManager.h"
#import "HUTextView.h"

@interface HUMyProfileViewController () <HUImageUploadViewConrollerDelegate>{
    
    NSMutableArray *_views;
	NSArray *_genderDataSource, *_onlineStatusDataSource;
	NSArray *_onlineStatusImageNamesArray;
    CGSize _keyboardSize;
    
    BOOL                _isEditing;
    BOOL                _keyboardShowing;
    int                 _originalContainerHeight;
}

@property (nonatomic, strong) ModelUser *user;
@property (nonatomic, weak) UITextView	*activeTextView;
@property (nonatomic, strong) NSDate	*birthdayDate;
@property (nonatomic, strong) HUDatePicker *datePicker;
@property (nonatomic) CGFloat maximumScrollViewHeight;
@property (nonatomic, strong) HUPickerTableView	*pickerTableView;

@end

@implementation HUMyProfileViewController

#pragma mark - Dealloc

-(void) dealloc {
    
	if (_pickerTableView != nil) {
		[_pickerTableView removePickerTableView];
    }
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _user = [UserManager defaultManager].getLoginedUser;
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;
        _datePicker = [[HUDatePicker alloc] init];
        _datePicker.delegate = self;
		
		_pickerTableView = [HUPickerTableView pickerTableViewFor:self];
		
        
        
    }
    
    return self;
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    __weak HUMyProfileViewController *this = self;
    
    [super viewWillAppear:animated];
    
    [self subscribeForKeyboardWillShowNotificationUsingBlock:^(NSNotification *note) {
        
    }];
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        [this animateKeyboardWillShow:note];
    }];
    
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        [this animateKeyboardWillHide:note];
    }];
        
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self unsubscribeForKeyboardWillShowNotification];
    
    [self unsubscribeForKeyboardWillChangeFrameNotification];
    
    [self unsubscribeForKeyboardWillHideNotification];
    
}


#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    _genderDataSource = kGenderDataSource;
    _onlineStatusDataSource = kStatusDataSource;
    _onlineStatusImageNamesArray = kStatusImageNames;

    self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
    
    [_nameLabel setText:NSLocalizedString(@"Name", nil)];
    [_aboutLabel setText:NSLocalizedString(@"About", nil)];
    [_birthdayLabel setText:NSLocalizedString(@"Birthday", nil)];
    [_genderLabel setText:NSLocalizedString(@"Gender", nil)];
    [_statusLabel setText:NSLocalizedString(@"Online Status", nil)];

    [_saveButton setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
    
    _userAvatarImageView.delegate = self;
    
    [self.view addSubview:_datePicker];
    
    [self disableEditors];
    [self populateWithData];
    [self loadAvatar];
    
    [self showKeyboardDoneButtonForTextView:_aboutValueLabel];
}


- (NSString *) title {
    return NSLocalizedString(@"My Profile", nil);
}

- (void) populateWithData {
    
    [_nameValueLabel setText:_user.name];
    [_genderValueLabel setText:NSLocalizedString(_user.gender,nil)];
    [_aboutValueLabel setText:_user.about];
    
    if(_user.birthday != 0){
        _birthdayDate = [NSDate dateWithTimeIntervalSince1970:_user.birthday];
    }
    
    NSString *onlineStatusString = [_user.onlineStatus isEqualToString:@""] ? _onlineStatusDataSource[0] : [Utils convertOnlineStatusKeyForDB:_user.onlineStatus];
    [_statusValueLabel setText:NSLocalizedString(onlineStatusString,nil)];
    
    int stateIndex = 0;
    for(int i = 0 ; i < _onlineStatusDataSource.count ; i++){
        
        if([_onlineStatusDataSource[i] isEqualToString:[Utils convertOnlineStatusKeyForDB:_user.onlineStatus]]){
            stateIndex = i;
            break;
        }
        
    }
    
    [_onlineStatusIconView setImage:[UIImage imageNamed:_onlineStatusImageNamesArray[stateIndex]]];

    [self displayDate];
    [self layoutViews];

    [_contentView scrollsToTop];
    
}

- (void) layoutViews{
    
    CGSize imageSize = _userAvatarImageView.downloadedImageSize;
    
    float viewHeight = 200;
    
    float imageWidth = imageSize.width;
    
    if(imageWidth != 0){
        
        float viewWidth = _userAvatarImageView.width;
        
        float scale = viewWidth / imageWidth;
        
        if(_userAvatarImageView.image != nil && scale != 0){
            viewHeight = imageSize.height * scale;
            [_avatarImageViewHeightConstraint setConstant:viewHeight];
        }
        
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        float height = [_aboutValueLabel getContentHeight];
        _aboutValueLabel.frame = CGRectMake(_aboutValueLabel.x, _aboutValueLabel.y, _aboutValueLabel.width, height);
        [_aboutViewHeightConstraint setConstant:height + 40];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGPoint absolutePosition = [_saveButton convertPoint:_saveButton.frame.origin toView:_contentView];
        [_contentHeightConstraint setConstant:absolutePosition.y / 2 + _saveButton.height + 20];
    });

    
}

-(void) disableEditors{
    _nameValueLabel.enabled = NO;
    _aboutValueLabel.editable = NO;
    _birthdayValueLabel.enabled = NO;
    _genderValueLabel.enabled = NO;
    _statusValueLabel.enabled = NO;
    _saveButton.alpha = 0.0;
    _saveButton.enabled = NO;
    _aboutValueLabel.userInteractionEnabled = NO;
    
    [_userAvatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap:)]];
    [_userAvatarImageView setUserInteractionEnabled:NO];

}

-(void) enableEditors{
    _nameValueLabel.enabled = YES;
    _aboutValueLabel.editable = YES;
    _birthdayValueLabel.enabled = YES;
    _genderValueLabel.enabled = YES;
    _statusValueLabel.enabled = YES;
    _saveButton.alpha = 1.0;
    _saveButton.enabled = YES;
    _aboutValueLabel.userInteractionEnabled = YES;
    
    [_userAvatarImageView removeGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap:)]];
    [_userAvatarImageView setUserInteractionEnabled:YES];

}

-(void) displayDate {
    
    if(_birthdayDate != nil){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:kDefaultDateFormat];
        NSString *dateString = [format stringFromDate:_birthdayDate];
        [_birthdayValueLabel setText:dateString];
    }else{
        [_birthdayValueLabel setText:@""];
    }
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

#pragma mark - avatar

-(void) avatarImageViewDidTap:(UITapGestureRecognizer *)recognizer {
    
    if (!_isEditing)
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

-(void) loadAvatar{
    
    if( _user.imageUrl != nil &&  _user.imageUrl.length > 0){
        NSString *url = _user.imageUrl;
        [_userAvatarImageView startDownload:[NSURL URLWithString:url]];
    }
    
    
}


#pragma mark - HUImageView delegate

- (void) downloadSucceed:(HUImageView *) imageView{
    [self layoutViews];
}

- (void) downloadFailed:(HUImageView *) imageView{
    _userAvatarImageView.image = [UIImage imageNamed:@"user_stub_large"];
    [self layoutViews];
}



#pragma mark - Keyboard Handling

- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    _keyboardShowing = YES;
    _keyboardSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _contentView.height = self.view.height - _keyboardSize.height;
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    _keyboardShowing = NO;
    _contentView.height = self.view.height;
}

#pragma mark - Other


- (BOOL) validationAsync{
    
    if (![_nameValueLabel text] || [_nameValueLabel text].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Username", @"")];
        
        return NO;
    }
    
    
    if(![[HUDataManager defaultManager] isNameOkay:[_nameValueLabel text]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Name", @"")];
        return NO;
        
    }
    
    
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"findUser/name" value:[_nameValueLabel text]];
    
    if(result != nil){
        
        NSString *foundId = [result objectForKey:@"_id"];
        
        if(![[[UserManager defaultManager] getLoginedUser]._id isEqualToString:foundId]){
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate username", @"")];
            return NO;
        }
        
    }
    
    return YES;
}



- (void) onSave{
    __weak HUMyProfileViewController *this = self;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(![this validationAsync]){
            [[AlertViewManager defaultManager] dismiss];
            return;
        }
        
        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
        
        _user.name = _nameValueLabel.text;
        _user.about = _aboutValueLabel.text;
        
        NSString *genderKey = [[Utils getKeyForLocalizedString:_genderValueLabel.text] lowercaseString];
        if(genderKey == nil){
            genderKey = _genderValueLabel.text;
        }
        
        _user.gender = genderKey;
        
        NSString *onlineStatusKey = [[Utils getKeyForLocalizedString:_statusValueLabel.text] lowercaseString];
        if(onlineStatusKey == nil){
            onlineStatusKey = _statusValueLabel.text;
        }
        
        _user.onlineStatus = onlineStatusKey;
        
        _user.birthday = [_birthdayDate timeIntervalSince1970];
        
        [[DatabaseManager defaultManager] updateUser:_user
                                            oldEmail:_user.email
                                             success:^(BOOL isSuccess, NSString *errStr){
                                                 
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     
                                                     if (isSuccess) {
                                                         
                                                         [[UserManager defaultManager] reloadUserDataWithCompletion:^(id result) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 [[AlertViewManager defaultManager] dismiss];
                                                                 
                                                                 [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Saved", nil)];
                                                                 
                                                                 this.user = [[UserManager defaultManager] getLoginedUser];
                                                                 [this populateWithData];
                                                                 
                                                             });
                                                         }];
                                                         
                                                     }
                                                     else {
                                                         [[AlertViewManager defaultManager] dismiss];
                                                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Failed to save", nil)];
                                                     }
                                                     
                                                     [this tuggleEdit];
                                                     
                                                 });
                                                 
                                             } error:^(NSString *errStr){
                                                 [[AlertViewManager defaultManager] dismiss];
                                                 [CSToast showToast:errStr withDuration:3.0];
                                             }];
        
    });
}


- (void) tuggleEdit {
    
    [self.view endEditing:YES];
	
    if(_isEditing){
        _isEditing = NO;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self hideView:_saveButton];
                             [self layoutViews];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];

        [self disableEditors];
        
        [self populateWithData];
     
    }else{
        
     
        _isEditing = YES;
        
        self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self showView:_saveButton height:36];
                             [self layoutViews];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
        
        [self enableEditors];
    
     }
    
}

#pragma mark - DatePicker

-(void) datePickerSelected{
    
	[self hideDatePickerWithDuration:0.2];
	_birthdayDate = _datePicker.datePicker.date;
	[self displayDate];
    
}

-(void)hideDatePickerWithDuration:(NSTimeInterval)duration
{
	if ([self checkIfDatePickerIsShown])
	{
		[UIView animateWithDuration:duration
						 animations:^
         {
             _datePicker.frame = CGRectMake(_datePicker.x, [Utils getDisplayHeight],
                                            _datePicker.width, _datePicker.height);
         }
						 completion:nil];
	}
}

-(BOOL)checkIfDatePickerIsShown
{
	if (_datePicker.y != [Utils getDisplayHeight])
		return YES;
	else
		return NO;
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image
                 editingInfo:(NSDictionary*)editingInfo{
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [self performSelector:@selector(openUimageUploadViewController:)
               withObject:image
               afterDelay:0.5];
}

-(void) openUimageUploadViewController:(UIImage *)image {
    
    HUImageUploadViewController *viewController = [HUImageUploadViewController userAvatarUploadViewControllerWithImage:image];
    viewController.targetUser = _user;
    viewController.delegate = self;
    
    [[AppDelegate getInstance].navigationController pushViewController:viewController animated:YES];
}


#pragma mark - HUImageUploadViewConrollerDelegate


- (void) imageUploadViewController:(HUImageUploadViewController *)viewController
                   didUpdateObject:(id)object {
    
    __weak HUMyProfileViewController *this = self;
    
    [[UserManager defaultManager] reloadUserDataWithCompletion:^(id result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AlertViewManager defaultManager] dismiss];
            
            [CSToast showToast:NSLocalizedString(@"Saved", nil) withDuration:3.0];
            
            this.user = [[UserManager defaultManager] getLoginedUser];
            [this populateWithData];
            [this loadAvatar];
            
        });
    }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self hideDatePickerWithDuration:0.0];
    
    if (textField == _birthdayValueLabel)
	{
        
        if([self checkIfDatePickerIsShown])
            return NO;
        
		[self.view endEditing:YES];
        [UIView animateWithDuration:0.2
                         animations:^{
                             _datePicker.frame = CGRectMake(_datePicker.x, _datePicker.y - _datePicker.height,
                                                            _datePicker.width, _datePicker.height);
                         } completion:nil];
        return NO;
    }

    if (textField == _genderValueLabel) {
        [self.view endEditing:YES];
        [self showPickerTableViewForPickerDataType:HUPickerGenderDataType];
        return NO;
    }
    
    if (textField == _statusValueLabel) {
        [self.view endEditing:YES];
        [self showPickerTableViewForPickerDataType:HUPickerOnlineStatusDataType];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        _activeTextView = nil;
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [self layoutViews];
    
    return YES;
}


#pragma mark - HUPickerTableView Methods

-(void) showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType
{

    _pickerTableView.dataSource = self;
    _pickerTableView.delegate = self;
    
	[_pickerTableView showPickerTableViewInView:self.view
								 pickerDataType:dataType];
    
	if (dataType == HUPickerGenderDataType)
		_pickerTableView.dataSourceArray = _genderDataSource;
    
	else if (dataType == HUPickerOnlineStatusDataType)
		_pickerTableView.dataSourceArray = _onlineStatusDataSource;
    
}

-(void)removePickerTableView
{
	[_pickerTableView removePickerTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isKindOfClass:[HUPickerTableView class]])
	{
		HUPickerTableView *pickerTableView = (HUPickerTableView *)tableView;
		
		CGFloat height = pickerTableView.dataSourceArray.count * kPickerCellHeight;
		pickerTableView.frame = CGRectMake(0, 0, 260, height);
		pickerTableView.center = CGPointMake(_pickerTableView.holderView.size.width / 2,
											 _pickerTableView.holderView.size.height / 2);
		
		return pickerTableView.dataSourceArray.count;
	}
	return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isKindOfClass:[HUPickerTableView class]])
	{
		static NSString *cellIdentifier = @"CellIdentifier";
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			cell.contentView.backgroundColor = [UIColor whiteColor];
			cell.textLabel.textColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
		}
		
		cell.textLabel.text = NSLocalizedString(_pickerTableView.dataSourceArray[indexPath.row],nil);
		
		if (_pickerTableView.pickerDataType == HUPickerGenderDataType) {
			cell.imageView.image = nil;
			if (indexPath.row == _pickerTableView.dataSourceArray.count - 1)
				cell.textLabel.textColor = [UIColor blackColor];
			else
				cell.textLabel.textColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
		} else if (_pickerTableView.pickerDataType == HUPickerOnlineStatusDataType) {
			cell.imageView.image = [UIImage imageNamed:_onlineStatusImageNamesArray[indexPath.row]];
		}
		return cell;
	}
	else
		return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	if ([tableView isKindOfClass:[HUPickerTableView class]])
	{
		HUPickerTableView *pickerTableView = (HUPickerTableView *)tableView;
		if (pickerTableView.pickerDataType == HUPickerGenderDataType) {
            NSString *selectedValue = _pickerTableView.dataSourceArray[indexPath.row];
            
			if (indexPath.row == _genderDataSource.count - 1)
				[_genderValueLabel setText:@""];
			else
				[_genderValueLabel setText:NSLocalizedString(selectedValue,nil)];
            
		} else if (pickerTableView.pickerDataType == HUPickerOnlineStatusDataType){
            NSString *selectedValue = _pickerTableView.dataSourceArray[indexPath.row];
            
			[_statusValueLabel setText:NSLocalizedString(selectedValue,nil)];
            [_onlineStatusIconView setImage:[UIImage imageNamed:_onlineStatusImageNamesArray[indexPath.row]]];
        }
        
		_pickerTableView.holderView.hidden = YES;
		UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:indexPath];
		cell.selected = NO;
	}
    
    
}


@end
