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

#import "HUGroupProfileViewController.h"
#import "HUGroupProfileViewController+Style.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "ModelGroup.h"
#import "CSToast.h"
#import "CSDispatcher.h"
#import "HUEditableLabelView.h"
#import "UIImagePickerController+Extensions.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "UserManager.h"
#import "HUBaseViewController+Style.h"
#import "AlertViewManager.h"
#import "HUPickerTableView.h"
#import "HUGroupsCategoryTableViewCell.h"
#import "HUDataManager.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface HUGroupProfileViewController (){
    UIImage *_avatarImage;
    int _originalContainerHeight;
}

-(void)resignActiveTextViewAndHideKeyboard;

-(void)showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType;
-(void)removePickerTableView;

@end

@implementation HUGroupProfileViewController


#pragma mark - Dealloc

-(void) dealloc {
    
    CS_RELEASE(_contentView);
    CS_RELEASE(_avatarView);
    CS_RELEASE(_nameLabel);
    CS_RELEASE(_passwordLabel);
    CS_RELEASE(_aboutLabel);
	CS_RELEASE(_categoryLabel);
    CS_RELEASE(_group);
    
    CS_SUPER_DEALLOC;
}

#pragma mark - Initialization

- (id)initWithGroup:(ModelGroup *) group{
    
    if (self = [super init]) {
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        self.view.backgroundColor = [self viewBackgroundColor];
        _group = CS_RETAIN([ModelGroup jsonToObj:[ModelGroup toJSON:group]]);
		_pickerTableView = [HUPickerTableView pickerTableViewFor:self];
        
        self.title = _group.name;
        [self populateViews];

    }
    
    return self;
}

- (id)init{
    
    if (self = [super init]) {
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        self.view.backgroundColor = [self viewBackgroundColor];
		_pickerTableView = [HUPickerTableView pickerTableViewFor:self];
    }
    
    return self;
}


- (void) layoutViews{
    
    int width = CGRectGetWidth(self.view.frame) - kMargin * 2;
    int x = kMargin;
    int y = kMargin;
    
    for (UIView *view in _views)
	{
        
        y += view.topMargin;
        
        if (view == _avatarView)
		{
            
            UIImage *originalImage = _avatarImage;
            if(originalImage == nil)
                originalImage = _avatarView.image;

            
            float imageWidth = originalImage.size.width;
            float imageHeight = originalImage.size.height;
			if (imageHeight == 0)
				continue;
            
            float scale = imageWidth / imageHeight;
            float viewHeight = _avatarView.width / scale;
            
            _avatarView.frame = CGRectMake(_avatarView.x, _avatarView.y,
										   _avatarView.width, viewHeight);
            
            if(_avatarImage != nil){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    _avatarView.image = _avatarImage;
                });
            }
        
            
        } else if (view == _startConversationBtn) {
            
            _startConversationBtn.frame = CGRectMake(
                                              _startConversationBtn.x,
                                              y,
                                              _startConversationBtn.width,
                                              kStartButtonHeight
                                              );
            
        }else if (view == _categoryLabel) {
            
            _categoryLabel.frame = CGRectMake(
                                              _categoryLabel.x,
                                              y,
                                              _categoryLabel.width,
                                              _categoryLabel.textView.contentSize.height
                                              );
            
        }else if (view == _aboutLabel) {
            _aboutLabel.frame = CGRectMake(
                                           _aboutLabel.x,
                                           y,
                                           _aboutLabel.width,
                                           _aboutLabel.textView.contentSize.height
                                           );
            
        }else{
            view.frame = CGRectMake(x, y, width, view.frame.size.height);
            
        }
        
        if(view.hidden == NO){
            y += view.frame.size.height + kMargin + view.bottomMargin;
        }
        
    }
    
    _contentView.contentSize = CGSizeMake(_contentView.contentSize.width,y + kMargin);
    
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


#pragma mark - Override

- (NSString *) title {
    return _group.name;
}

-(void) loadView {
    
    [super loadView];
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-groupprofile",nil)];
    
    _contentView = CS_RETAIN([self newContentView]);
    [self.view addSubview:_contentView];
    
    _avatarView = CS_RETAIN([self newAvatarImageView]);
    _avatarView.frame = [self frameByNumberOfElement:0];
    _avatarView.delegate = self;
    [_contentView addSubview:_avatarView];
    
    _startConversationBtn = CS_RETAIN([self startConversationButton]);
    _startConversationBtn.frame = [self frameByNumberOfElement:1];
    _startConversationBtn.frame = CGRectMake(
        _startConversationBtn.x,
        _startConversationBtn.y,
        _startConversationBtn.width,
        kStartButtonHeight
    );
    
    [_startConversationBtn addTarget:self action:@selector(startConversation) forControlEvents:UIControlEventTouchDown];
    [_contentView addSubview:_startConversationBtn];

    UIImage *arrow = [UIImage imageNamed:@"table_arrow_white"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:arrow];
    imageView.frame = CGRectMake(
                                 _startConversationBtn.width - arrow.size.width - 5,
                                 5,
                                 arrow.size.width,
                                 arrow.size.height
                                 );
    [_startConversationBtn addSubview:imageView];
    
    _categoryLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Category", nil)]);
    _categoryLabel.frame = [self frameByNumberOfElement:2];
    [_categoryLabel setMultiLine:NO];
    [_categoryLabel setEditing:NO];
    [_categoryLabel setDelegate:self];
    [_contentView addSubview:_categoryLabel];

    _nameLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Name", nil)]);
    _nameLabel.frame = [self frameByNumberOfElement:3];
    [_nameLabel setMultiLine:NO];
    [_nameLabel setEditing:NO];
    [_nameLabel setDelegate:self];
    [_contentView addSubview:_nameLabel];
    
    _passwordLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Password", nil)]);
    _passwordLabel.frame = [self frameByNumberOfElement:4];
    [_passwordLabel setMultiLine:NO];
    [_passwordLabel setEditing:NO];
    [_passwordLabel setDelegate:self];
    [_contentView addSubview:_passwordLabel];
    
    _groupOwnerLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"GroupOwner", nil)]);
    _groupOwnerLabel.frame = [self frameByNumberOfElement:5];
    [_groupOwnerLabel setMultiLine:NO];
    [_groupOwnerLabel setEditing:NO];
    [_groupOwnerLabel setDelegate:self];
    [_contentView addSubview:_groupOwnerLabel];
    UIImage *arrow2 = [UIImage imageNamed:@"table_arrow_gray"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:arrow2];
    imageView2.frame = CGRectMake(
        _groupOwnerLabel.width - arrow2.size.width - 5,
        5,
        arrow2.size.width,
        arrow2.size.height
    );
    [_groupOwnerLabel addSubview:imageView2];

    
    _aboutLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"About", nil)]);
    _aboutLabel.frame = [self frameByNumberOfElement:6];
    _aboutLabel.multiLine = YES;
    [_aboutLabel setEditing:NO];
    [_aboutLabel setDelegate:self];
    [_contentView addSubview:_aboutLabel];
    
    [_views addObject:_avatarView];
    [_views addObject:_startConversationBtn];
    [_views addObject:_categoryLabel];
    [_views addObject:_nameLabel];
    [_views addObject:_passwordLabel];
    [_views addObject:_groupOwnerLabel];
    [_views addObject:_aboutLabel];

}


- (void) viewWillAppear:(BOOL)animated {
    
    __weak HUGroupProfileViewController *this = self;
    
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


- (void) addContactAddButton {
    
    self.navigationItem.rightBarButtonItems = [self addContactBarButtonItemsWithSelector:@selector(onAdd)];
}

- (void) addContactRemoveButton {
    
    self.navigationItem.rightBarButtonItems = [self removeContactBarButtonItemsWithSelector:@selector(onRemove)];
}

- (void) populateViews{

    [_categoryLabel setEditerText:_group.categoryName];
    [_nameLabel setEditerText:_group.name];
    
    _selectedCategoryID = _group.categoryId;
    
    
    [[DatabaseManager defaultManager] findUserWithID:_group.userId success:^(id result){

        _owner = result;
        [_groupOwnerLabel setEditerText:_owner.name];
        
    } error:^(NSString *strError){
        
        
        
    }];
    
    if(_group.password.length > 0)
        [_passwordLabel setEditerText:NSLocalizedString(@"Password-Exists", nil)];
    else
        [_passwordLabel setEditerText:NSLocalizedString(@"No-Password", nil)];
    
    [_aboutLabel setEditerText:_group.description];
    
    [[DatabaseManager defaultManager] loadCategoryIconByName:_group.categoryName success:^(UIImage *image){
        
        [_categoryLabel setIconImage:image];
        
        [self performSelector:@selector(layoutViews) withObject:nil afterDelay:0.1];
        
    }error:^(NSString *errStr){
        
    }];
    
    
    [self layoutViews];
    [self loadAvatar];
    [self updateAddButton];
    
}

-(void) updateAddButton{
    
    if(_group.deleted == NO && [[[UserManager defaultManager] getLoginedUser]._id isEqualToString:_group.userId]){
        
    }else{
        if([[[UserManager defaultManager] getLoginedUser] isInFavoriteGroups:_group])
            [self addContactRemoveButton];
        else
            [self addContactAddButton];
    }
    
}

-(void) loadAvatar{
    
    if(_group == nil)
        return;
    
    
    if( _group.imageUrl != nil &&  _group.imageUrl.length > 0){
        
        NSString *url = _group.imageUrl;
        
        _avatarImage = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:url]];
        
        if (_avatarImage) {
            _avatarView.image = _avatarImage;
            [self layoutViews];
        }else{
            [_avatarView startDownload:[NSURL URLWithString:url]];
        }

    }
    
}

- (void) downloadSucceed:(id) sender{
    [self performSelector:@selector(layoutViews) withObject:nil afterDelay:0.1];
}

#pragma mark - UITextFieldViewDelegate

-(void)resignActiveTextViewAndHideKeyboard
{
	if (_activeTextView != nil && [_activeTextView isFirstResponder]) {
		[_activeTextView resignFirstResponder];
		_activeTextView = nil;
	}
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (textView.superview == _categoryLabel) {
		[self resignActiveTextViewAndHideKeyboard];
		[self showPickerTableViewForPickerDataType:HUPickerGroupCategoryDataType];
		return NO;
	}
    
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textField{
    _activeTextView = textField;
}

- (void)textFieldDidEndEditing:(UITextView *)textField{
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    HUEditableLabelView *superView = (HUEditableLabelView *) textView.superview;
    
    if([superView isKindOfClass:[HUEditableLabelView class]]){
        if(superView.multiLine){
            
            superView.frame = CGRectMake(
                                         superView.x,
                                         superView.y,
                                         superView.width,
                                         textView.contentSize.height
                                         );
            
            [self layoutViews];
            
        }else{
            if ([text isEqualToString:@"\n"]) {
				
				if ([textView isEqual:_passwordLabel.textView])
				{
					if ([[HUDataManager defaultManager] isPasswordOkay:_passwordLabel.textView.text] == NO) {
						[CSToast showToast:NSLocalizedString(@"Wrong password message", nil) withDuration:2.0];
					}
				}
				
                [textView resignFirstResponder];
				_activeTextView = nil;
                return NO;
            }
        }
    }
    
    return YES;
}

-(void)onTouch:(id)textView{
    if(textView == _groupOwnerLabel){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:_owner];
        
    }
}

#pragma mark - Load Categories

-(void)loadGroupCategory
{
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending", nil)
										   message:nil];
	
	__weak HUGroupProfileViewController *this = self;
    void(^successBlock)(id result) = ^(NSArray *groupCategories)
	{
		[[AlertViewManager defaultManager] dismiss];
        [this.pickerTableView showPickerTableViewInView:this.view
										 pickerDataType:HUPickerGroupCategoryDataType];
		this.pickerTableView.dataSourceArray = groupCategories;
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager] findGroupCategories:successBlock error:errorBlock];
    
}

#pragma mark - HUPickerTableView Methods

-(void)showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType
{
	[self resignActiveTextViewAndHideKeyboard];
	
	[self loadGroupCategory];
}

-(void)removePickerTableView
{
	[_pickerTableView removePickerTableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isKindOfClass:[HUPickerTableView class]]) {
        ModelGroupCategory *groupCategory = [_pickerTableView.dataSourceArray objectAtIndex:indexPath.row];
        return [HUGroupsCategoryTableViewCell heightForCellWithGroup:groupCategory];
    }
    
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_pickerTableView.dataSourceArray.count == 0)
		return 0;
	
	if ([tableView isKindOfClass:[HUPickerTableView class]])
	{
		HUPickerTableView *pickerTableView = (HUPickerTableView *)tableView;
		
		ModelGroupCategory *groupCategory = [_pickerTableView.dataSourceArray objectAtIndex:0];
		NSInteger numberOfRows = pickerTableView.dataSourceArray.count <= 4 ? pickerTableView.dataSourceArray.count : 4;
		CGFloat height = numberOfRows * [HUGroupsCategoryTableViewCell heightForCellWithGroup:groupCategory];
		pickerTableView.frame = CGRectMake(0, 0, 320, height);
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
		HUPickerTableView *pickerTableView = (HUPickerTableView *)tableView;
		
		if (pickerTableView.pickerDataType == HUPickerGroupCategoryDataType)
		{
			ModelGroupCategory *groupCategory = [pickerTableView.dataSourceArray objectAtIndex:indexPath.row];
			
			static NSString *cellIdentifier = @"MyCategoryCellIdentifier";
			
			HUGroupsCategoryTableViewCell *cell = (HUGroupsCategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
			
			if(cell == nil) {
				cell = CS_AUTORELEASE([[HUGroupsCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
																		   reuseIdentifier:cellIdentifier]);
			}
			
			[cell populateWithData:groupCategory];
			
			cell.avatarImageView.image = [UIImage imageNamed:@"group_stub"];
			
			[HUAvatarManager avatarImageForUrl:groupCategory.imageUrl atIndexPath:indexPath width:kListViewBigWidth completionHandler:^(UIImage *image, NSIndexPath *indexPath) {
				cell.avatarImageView.image = image;
			}];
			
			return cell;
		}
		else
			return nil;
	}
	else
		return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isKindOfClass:[HUPickerTableView class]])
	{
		HUPickerTableView *pickerTableView = (HUPickerTableView *)tableView;

		if (pickerTableView.pickerDataType == HUPickerGroupCategoryDataType) {
			ModelGroupCategory *groupCategory = [_pickerTableView.dataSourceArray objectAtIndex:indexPath.row];
			[_categoryLabel setEditerText:groupCategory.title];

            
            [[DatabaseManager defaultManager] loadCategoryIconByName:groupCategory.title success:^(UIImage *image){
                
                [_categoryLabel setIconImage:image];
                
                [self layoutViews];
                
            }error:^(NSString *errStr){
                
            }];
            
            
			_selectedCategoryID = groupCategory._id;
		}
		
		_pickerTableView.holderView.hidden = YES;
		UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:indexPath];
		cell.selected = NO;
	}
}

#pragma mark AddRemoveFronFavorite

-(void) onRemove{
    
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    void(^successBlock)(BOOL success, NSString *error) = ^(BOOL success, NSString *error)
	{
        
        
        if(success){
            
            [[DatabaseManager defaultManager] reloadUser:[[UserManager defaultManager] getLoginedUser] success:^(id result){
                
                if(result != nil){
                    
                    [[AlertViewManager defaultManager] dismiss];
                    
                    [[UserManager defaultManager] setLoginedUser:(ModelUser *) result];
                    [self updateAddButton];
                    
                }
                
            } error:^(NSString *errstr){
                
                [[AlertViewManager defaultManager] dismiss];
                
            }];
            
        }
        
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager]
        removeGroupFromFavorite:_group
                            toUser:[[UserManager defaultManager] getLoginedUser]
                            success:successBlock error:errorBlock];
    
    
}

-(void) onAdd{
    
    ModelUser *myUser = [UserManager defaultManager].getLoginedUser;
    
    int currentFavorites = myUser.favouriteGroups.count;
    int favoriteMax = myUser.maxFavoriteNum;
    
    if(currentFavorites >= favoriteMax){
        [[AlertViewManager defaultManager] showAlert:[NSString stringWithFormat:NSLocalizedString(@"Max Favorite Exceeded",nil),favoriteMax]];
        return;
    }

    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    void(^successBlock)(BOOL success, NSString *error) = ^(BOOL success, NSString *error)
	{
        
        
        if(success){
            
            [[DatabaseManager defaultManager] reloadUser:[[UserManager defaultManager] getLoginedUser] success:^(id result){
                
                if(result != nil){
                    
                    [[AlertViewManager defaultManager] dismiss];
                    
                    [[UserManager defaultManager] setLoginedUser:(ModelUser *) result];
                    [self updateAddButton];
                    
                }
                
            } error:^(NSString *errstr){
                
                [[AlertViewManager defaultManager] dismiss];
                
            }];
            
        }
        
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager]
     addGroupToFavorite:_group
     toUser:[[UserManager defaultManager] getLoginedUser]
     success:successBlock error:errorBlock];
    
}

- (void) startConversation{
    
    
    if(_group.password != nil && _group.password.length > 0 && ![_group.userId isEqualToString:[[UserManager defaultManager] getLoginedUser]._id]){
        
        [[AlertViewManager defaultManager] showInputPassword:@"Please input password"
                                                 resultBlock:^(NSString *password){
                                                     
                                                     if(password != nil && [password isEqualToString:_group.password])
                                                         
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:_group];
                                                     
                                                     else{
                                                         
                                                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password", nil)];
                                                         
                                                     }
                                                     
                                                 }];
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:_group];
        
    }
    
    
    
    
}

-(void)hideStartConverstationBtn{
    [_startConversationBtn removeFromSuperview];
    [_views removeObject:_startConversationBtn];
}

@end
