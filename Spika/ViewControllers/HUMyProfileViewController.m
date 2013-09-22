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
#import "HUMyProfileViewController+Style.h"
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
#import "HUAvatarManager.h"

@interface HUMyProfileViewController () <HUImageUploadViewConrollerDelegate>{
    UIButton            *_saveButton;
    
    NSMutableArray *_views;
	NSArray *_genderDataSource, *_onlineStatusDataSource;
	NSArray *_onlineStatusImageNamesArray;
    
    BOOL                _isEditing;
    BOOL                _keyboardShowing;
    
    int                 _originalContainerHeight;
}

@property (nonatomic, strong) ModelUser *user;
@property (nonatomic, weak) UITextView	*activeTextView;
@property (nonatomic, strong) NSDate	*birthdayDate;
@property (nonatomic, strong) HUDatePicker *datePicker;
@property (nonatomic, strong) HUEditableLabelView *nameLabel;
@property (nonatomic, strong) HUEditableLabelView *aboutLabel;
@property (nonatomic, strong) HUEditableLabelView *birthdayLabel;
@property (nonatomic, strong) HUEditableLabelView *genderLabel;
@property (nonatomic, strong) HUEditableLabelView *onlineStatusLabel;
@property (nonatomic) CGFloat maximumScrollViewHeight;
@property (nonatomic, strong) HUPickerTableView	*pickerTableView;

@end

@implementation HUMyProfileViewController

#pragma mark - Dealloc

-(void) dealloc {
    
    CS_RELEASE(_nameLabel);
    CS_RELEASE(_aboutLabel);
    CS_RELEASE(_genderLabel);
    CS_RELEASE(_birthdayLabel);
	CS_RELEASE(_onlineStatusLabel);
    CS_RELEASE(_datePicker);
    
	if (_pickerTableView != nil)
		[_pickerTableView removePickerTableView];
    
	CS_RELEASE(_pickerTableView);

    CS_SUPER_DEALLOC;
    
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {

        _user = [UserManager defaultManager].getLoginedUser;
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;
        _datePicker = [[HUDatePicker alloc] init];
        _datePicker.delegate = self;
        
        self.view.backgroundColor = [self viewBackgroundColor];
		
		_pickerTableView = [HUPickerTableView pickerTableViewFor:self];
		
         
        
    }
    
    return self;
}

- (void) layoutViews{
    
    int width = CGRectGetWidth(self.view.frame) - kMargin * 2;
    int x = kMargin;
    int y = kMargin;
    
    for(UIView *view in _views){
        
        if(view == _userAvatarImageView){

            float imageWidth = _userAvatarImageView.downloadedImageSize.width;
            float imageHeight = _userAvatarImageView.downloadedImageSize.height;
			if (imageHeight == 0)
				continue;
            float scale = imageWidth / imageHeight;
            float viewHeight = _userAvatarImageView.width / scale;
            
            _userAvatarImageView.frame = CGRectMake(_userAvatarImageView.x, _userAvatarImageView.y,
													_userAvatarImageView.width, viewHeight);
            
            
        }else{
            view.frame = CGRectMake(x, y, width, view.frame.size.height);
            
        }
            
        if(view.frame.size.height != 0)
            y += view.frame.size.height + kMargin;
        
    }
    
    _contentView.contentSize = CGSizeMake(_contentView.contentSize.width,y + kMargin);
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

- (CGRect) frameByNumberOfElement:(int) number{
    
    int width = CGRectGetWidth(self.view.frame) - kMargin * 2;
    int x = kMargin;
    int height = CGRectGetWidth(self.view.frame) - kMargin * 2;
    if(number != 0)
        height = kEditableLabelHeight;
    
    int y = kMargin;
    
    for(int i = 0;i < number ; i++){
        
        int lastElementHeight = kEditableLabelHeight;
        
        if(i == 0)
            lastElementHeight = CGRectGetWidth(self.view.frame) - kMargin * 2;
        
        y += lastElementHeight + kMargin;
        
    }
    
    CGRect returnRect = CGRectMake(
                                   x,y,width,height
                                   );
    
    return returnRect;
}


#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    _genderDataSource = kGenderDataSource;
    _onlineStatusDataSource = kStatusDataSource;
    _onlineStatusImageNamesArray = kStatusImageNames;

    self.navigationItem.rightBarButtonItems = [self editProfileBarButtonItemWithSelector:@selector(tuggleEdit) editing:_isEditing];
    
    _contentView = [self newContentView];
    [self.view addSubview:_contentView];

    _userAvatarImageView = [self newUserAvatarImageView];
    _userAvatarImageView.frame = [self frameByNumberOfElement:0];
    _userAvatarImageView.delegate = self;
    [_contentView addSubview:_userAvatarImageView];

    _nameLabel = [self getEditorLabelByTitle:NSLocalizedString(@"Name", nil)];
    _nameLabel.frame = [self frameByNumberOfElement:1];
    [_nameLabel setDelegate:self];
    [_contentView addSubview:_nameLabel];
    
    _aboutLabel = [self getEditorLabelByTitle:NSLocalizedString(@"About", nil)];
    _aboutLabel.frame = [self frameByNumberOfElement:3];
    _aboutLabel.multiLine = YES;
    _aboutLabel.isAccessibilityElement = YES;
    _aboutLabel.accessibilityLabel = @"about";
    [_aboutLabel setDelegate:self];
    [_contentView addSubview:_aboutLabel];
    
    _birthdayLabel = [self getEditorLabelByTitle:NSLocalizedString(@"Birthday", nil)];
    _birthdayLabel.frame = [self frameByNumberOfElement:4];
    [_birthdayLabel setDelegate:self];
    [_contentView addSubview:_birthdayLabel];
    
    _genderLabel = [self getEditorLabelByTitle:NSLocalizedString(@"Gender", nil)];
    _genderLabel.frame = [self frameByNumberOfElement:5];
    [_genderLabel setDelegate:self];
    [_contentView addSubview:_genderLabel];
	
	_onlineStatusLabel = [self getEditorLabelByTitle:NSLocalizedString(@"Online Status", nil)];
    _onlineStatusLabel.frame = [self frameByNumberOfElement:6];
    [_onlineStatusLabel setDelegate:self];
    [_contentView addSubview:_onlineStatusLabel];
    
    _saveButton = [self newSaveButtonWithSelector:@selector(onSave)];
    [self hideView:_saveButton];
    [_contentView addSubview:_saveButton];
    
    [_views addObject:_userAvatarImageView];
    [_views addObject:_nameLabel];
    [_views addObject:_aboutLabel];
    [_views addObject:_birthdayLabel];
    [_views addObject:_genderLabel];
	[_views addObject:_onlineStatusLabel];
    [_views addObject:_saveButton];
    
    [self.view addSubview:_datePicker];
    
    [self populateWithData];
    [self loadAvatar];
    
    [self.userAvatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap:)]];
    [self.userAvatarImageView setUserInteractionEnabled:YES];
	
	[self setScrollingForEditableLabelViews];

}


- (NSString *) title {
    return NSLocalizedString(@"My Profile", nil);
}

- (void) populateWithData {
    
    [_genderLabel setEditerText:NSLocalizedString(_user.gender,nil)];
    [_aboutLabel setEditerText:_user.about];
    [_nameLabel setEditerText:_user.name];
	[_onlineStatusLabel setEditerText:[_user.onlineStatus isEqualToString:@""] ? _onlineStatusDataSource[0] : NSLocalizedString(_user.onlineStatus,nil)];
    
    int stateIndex = 0;
    
    for(int i = 0 ; i < _onlineStatusDataSource.count ; i++){
        
        if([_onlineStatusDataSource[i] isEqualToString:[Utils convertOnlineStatusKeyForDisplay:_user.onlineStatus]]){
            stateIndex = i;
            break;
        }
        
    }

    [_onlineStatusLabel setIconImage:[UIImage imageNamed:_onlineStatusImageNamesArray[stateIndex]]];

    
    if(_user.birthday != 0){
        _birthdayDate = [NSDate dateWithTimeIntervalSince1970:_user.birthday];
        [self displayDate];
    }

    [self layoutViews];

}

#pragma mark - Other

-(void) setScrollingForEditableLabelViews {
	
	HUEditableLabelView *labelView = nil;
    
	for (UIView *view in _contentView.subviews) {
		if ([view isKindOfClass:[HUEditableLabelView class]]) {
			labelView = (HUEditableLabelView *)view;
			[labelView setScrollEnabled:_isEditing];
		}
	}
}

- (void) tuggleEdit {
    
    [self.view endEditing:YES];
	[self hideDatePickerWithDuration:0.2];
	[self removePickerTableView];
	
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

        [_nameLabel setEditing:NO];
        [_aboutLabel setEditing:NO];
        [_birthdayLabel setEditing:NO];
        [_genderLabel setEditing:NO];
		[_onlineStatusLabel setEditing:NO];
        
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
        
        [_nameLabel setEditing:YES];
        [_aboutLabel setEditing:YES];
        [_birthdayLabel setEditing:YES];
        [_genderLabel setEditing:YES];
		[_onlineStatusLabel setEditing:YES];
        
    }
    
	[self setScrollingForEditableLabelViews];
    
}

- (void) onSave{
	
    __weak HUMyProfileViewController *this = self;
    
    [self hideDatePickerWithDuration:0.0];
    [self resignActiveTextViewAndHideKeyboard];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(![this validationAsync]){
            [[AlertViewManager defaultManager] dismiss];
            return;
        }

        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
        
        _user.name = [_nameLabel getEditorText];
        _user.about = [_aboutLabel getEditorText];
        
        NSString *genderKey = [[Utils getKeyForLocalizedString:[_genderLabel getEditorText]] lowercaseString];
        if(genderKey == nil){
            genderKey = [_genderLabel getEditorText];
        }
        
        _user.gender = genderKey;
        
        NSString *onlineStatusKey = [[Utils getKeyForLocalizedString:[_onlineStatusLabel getEditorText]] lowercaseString];
        if(onlineStatusKey == nil){
            onlineStatusKey = [_onlineStatusLabel getEditorText];
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

- (BOOL) validationAsync{
    
    if (![_nameLabel getEditorText] || [_nameLabel getEditorText].length == 0) {
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Missing-Username", @"")];
        
        return NO;
    }

    
    if(![[HUDataManager defaultManager] isNameOkay:[_nameLabel getEditorText]]){
        
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Invalid-Name", @"")];
        return NO;
        
    }

    
    NSDictionary *result = [[DatabaseManager defaultManager] checkUniqueSynchronous:@"username" value:[_nameLabel getEditorText]];
    
    if(result != nil){
        
        NSString *foundId = [result objectForKey:@"_id"];
        
        if(![[[UserManager defaultManager] getLoginedUser]._id isEqualToString:foundId]){
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Duplicate username", @"")];
            return NO;
        }
        
    }
    
    return YES;
}


#pragma mark - UITextFieldViewDelegate


- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if(_keyboardShowing == NO){
        _originalContainerHeight = _contentView.height;
    }else{

    }
    
    _keyboardShowing = YES;
    
    CGSize csz = _contentView.contentSize;
    CGSize bsz = _contentView.bounds.size;
    [_contentView setContentOffset:CGPointMake(_contentView.contentOffset.x,csz.height - bsz.height) animated:YES];
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _contentView.frame = CGRectMake(
                             _contentView.x,
                             _contentView.y,
                             _contentView.width ,
                             _originalContainerHeight  - kbSize.height
                             );
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    if(!_keyboardShowing)
        return;
    
    _keyboardShowing = NO;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _contentView.frame = CGRectMake(
                                 _contentView.x,
                                 _contentView.y,
                                 _contentView.width,
                                 _originalContainerHeight
                                 );
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}


-(void)resignActiveTextViewAndHideKeyboard
{
	if (_activeTextView != nil && [_activeTextView isFirstResponder])
	{
		_activeTextView = nil;
	}
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
 
    if (textView.superview == _birthdayLabel)
	{
		[self resignActiveTextViewAndHideKeyboard];
        [UIView animateWithDuration:0.2
             animations:^{
                 _datePicker.frame = CGRectMake(_datePicker.x, _datePicker.y - _datePicker.height,
												_datePicker.width, _datePicker.height);
             } completion:nil];
        return NO;
    }
	else
	{
		[self hideDatePickerWithDuration:0.0];
		if (textView.superview == _genderLabel) {
			[self resignActiveTextViewAndHideKeyboard];
			[self showPickerTableViewForPickerDataType:HUPickerGenderDataType];
			return NO;
		}
		else if (textView.superview == _onlineStatusLabel) {
			[self resignActiveTextViewAndHideKeyboard];
			[self showPickerTableViewForPickerDataType:HUPickerOnlineStatusDataType];
			return NO;
		}
		return YES;
	}
    
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
	_activeTextView = textView;

}
- (void)textFieldDidEndEditing:(UITextView *)textView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    HUEditableLabelView *superView = (HUEditableLabelView *) textView.superview;

    
    if([superView isKindOfClass:[HUEditableLabelView class]]){
        if(superView.multiLine){
            
            [superView adjustHeight];
            [self layoutViews];
            
        }else{
            if ([text isEqualToString:@"\n"]) {
                [textView resignFirstResponder];
				_activeTextView = nil;
                return NO;
            }
        }
    }
    
    return YES;
}

-(BOOL)checkIfDatePickerIsShown
{
	if (_datePicker.y != [Utils getDisplayHeight])
		return YES;
	else
		return NO;
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

-(void) datePickerSelected{
    
	[self hideDatePickerWithDuration:0.2];
	_birthdayDate = _datePicker.datePicker.date;
	[self displayDate];

}

-(void) displayDate {
    
    if(_birthdayDate != nil){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:kDefaultDateFormat];
        NSString *dateString = [format stringFromDate:_birthdayDate];
        [_birthdayLabel setEditerText:dateString];
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

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image
                 editingInfo:(NSDictionary*)editingInfo{
    
    
    [self dismissModalViewControllerAnimated:YES];
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
            
            [HUAvatarManager removeModelByID:this.user._id];
            
        });
    }];

}

#pragma mark - HUImageView delegate

- (void) downloadSucceed:(HUImageView *) imageView{
    [self layoutViews];
}

- (void) downloadFailed:(HUImageView *) imageView{
    _userAvatarImageView.image = [UIImage imageNamed:@"user_stub_large"];
    [self layoutViews];
}

#pragma mark - HUPickerTableView Methods

-(void) showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType
{
    
	[self hideDatePickerWithDuration:0.0];
    
	[self resignActiveTextViewAndHideKeyboard];
	
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
			if (indexPath.row == _genderDataSource.count - 1)
				[_genderLabel setEditerText:@""];
			else
				[_genderLabel setEditerText:NSLocalizedString(_pickerTableView.dataSourceArray[indexPath.row],nil)];
		} else if (pickerTableView.pickerDataType == HUPickerOnlineStatusDataType){
			[_onlineStatusLabel setEditerText:NSLocalizedString(_pickerTableView.dataSourceArray[indexPath.row],nil)];
            [_onlineStatusLabel setIconImage:[UIImage imageNamed:_onlineStatusImageNamesArray[indexPath.row]]];
        }

		_pickerTableView.holderView.hidden = YES;
		UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:indexPath];
		cell.selected = NO;
	}
}



@end
