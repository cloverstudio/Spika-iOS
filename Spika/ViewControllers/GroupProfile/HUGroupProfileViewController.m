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
#import "DatabaseManager.h"
#import "UserManager.h"
#import "ModelGroup.h"
#import "CSToast.h"
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
#import "HUTextView.h"
#import "HUImageView.h"
#import "HUNewGroupViewController.h"
#import "HUCachedImageLoader.h"
#import "HUUsersInGroupViewController.h"

@interface HUGroupProfileViewController (){
    UIImage *_avatarImage;
    int _originalContainerHeight;
    HUPickerTableView   *_pickerTableView;
}

-(void)showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType;
-(void)removePickerTableView;

@end

@implementation HUGroupProfileViewController


#pragma mark - Dealloc

-(void) dealloc {

}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil withGroup:(ModelGroup *) group{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _group = [ModelGroup jsonToObj:[ModelGroup toJSON:group]];
        self.title = _group.name;
        _isEditing = NO;
        
        
    }
    
    return self;
}

- (id)initWithGroup:(ModelGroup *) group{
    
    if (self = [super init]) {
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _group = [ModelGroup jsonToObj:[ModelGroup toJSON:group]];
        
        self.title = _group.name;
        [self populateViews];

    }
    
    return self;
}

- (id)init{
    
    if (self = [super init]) {
        _views = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}



- (void) viewDidLoad{
    _avatarView.delegate = self;
}


- (void) layoutViews {
    
    CGSize imageSize = _avatarView.downloadedImageSize;
    float viewHeight = 212;
    float imageWidth = imageSize.width;
    if(imageWidth != 0){
        float viewWidth = _avatarView.width;
        float scale = viewWidth / imageWidth;
        if(_avatarView.image != nil && scale != 0){
            viewHeight = imageSize.height * scale;
            [_avatarImageViewHeightConstraint setConstant:viewHeight];
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        float height = [_aboutValueLabel getContentHeight];
        _aboutValueLabel.frame = CGRectMake(_aboutValueLabel.x, _aboutValueLabel.y, _aboutValueLabel.width, height);
        [_aboutViewHeightConstraint setConstant:height + 40];
    });
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGPoint absolutePosition = [_aboutValueLabel convertPoint:_aboutValueLabel.frame.origin toView:_contentView];
        [_contentHeightConstraint setConstant:absolutePosition.y + _aboutValueLabel.height + 20];
    });
    */
}


#pragma mark - Override

- (NSString *) title {
    return _group.name;
}

-(void) loadView {
    
    [super loadView];

    _pickerTableView = [HUPickerTableView pickerTableViewFor:self];
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-groupprofile",nil)];

    [_startConversationBtn setTitle:NSLocalizedString(@"Start-Conversation", nil) forState:UIControlStateNormal];
    [_categoryLabel setText:NSLocalizedString(@"GroupCategory-Title", nil)];
    [_nameLabel setText:NSLocalizedString(@"Group-Name", nil)];
    [_aboutLabel setText:NSLocalizedString(@"Group-Profile", nil)];
    [_passwordLabel setText:NSLocalizedString(@"Password", nil)];
    [_groupOwnerLabel setText:NSLocalizedString(@"Group-Owner", nil)];
    [_memberLabel setText:NSLocalizedString(@"Members", nil)];
    
    _categoryValueLabel.enabled = NO;
    _nameValueLabel.enabled = NO;
    _groupOwnerValueLabel.enabled = NO;
    _passwordValueLabel.enabled = NO;
    _aboutValueLabel.editable = NO;
    
    [self populateViews];
}


- (void) addContactAddButton {
    
    self.navigationItem.rightBarButtonItems = [self addContactBarButtonItemsWithSelector:@selector(onAdd)];
}

- (void) addContactRemoveButton {
    
    self.navigationItem.rightBarButtonItems = [self removeContactBarButtonItemsWithSelector:@selector(onRemove)];
}

-(NSArray *) addContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Subscribe", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                 target:self
                                               selector:aSelector];
}

-(NSArray *) removeContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Unsubscribe", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                 target:self
                                               selector:aSelector];
}

- (void) populateViews{
    
    [_categoryValueLabel setText:_group.categoryName];
    [_nameValueLabel setText:_group.name];
    
    if(![self isKindOfClass:[HUNewGroupViewController class]]){
        
        [[DatabaseManager defaultManager] findUserWithID:_group.userId success:^(id result){
            
            _owner = result;
            [_groupOwnerValueLabel setText:_owner.name];
            
        } error:^(NSString *strError){
            
        }];
    
    }

    
    if(_group.password.length > 0)
        [_passwordValueLabel setText:NSLocalizedString(@"Password-Exists", nil)];
    else
        [_passwordValueLabel setText:NSLocalizedString(@"No-Password", nil)];
    
    [_aboutValueLabel setText:_group.description];


    [[DatabaseManager defaultManager] loadCategoryIconByName:_group.categoryName success:^(UIImage *image){
        
        [_categoryIconView setImage:image];
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

-(void)hideKeyboardFor:(UIView *)label {

}

#pragma mark - Load Categories

-(void)loadGroupCategory
{
    
    if(_isEditing == NO)
        return;
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending", nil)
										   message:nil];
	
	__weak HUGroupProfileViewController *this = self;
    void(^successBlock)(id result) = ^(NSArray *groupCategories)
	{
		[[AlertViewManager defaultManager] dismiss];
        [_pickerTableView showPickerTableViewInView:this.view
										 pickerDataType:HUPickerGroupCategoryDataType];
		_pickerTableView.dataSourceArray = groupCategories;
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager] findGroupCategories:successBlock error:errorBlock];
    
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
    
    if ([self isPasswordAlertNeeded:_group]) {
        [[AlertViewManager defaultManager] dismiss];
        [[AlertViewManager defaultManager] showInputPassword:@"Please input password"
                                                 resultBlock:^(NSString *password){
                                                     
                                                     if(password != nil && [[Utils MD5:password] isEqualToString:_group.password]) {
                                                         [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
                                                         [self savePassword:_group.password forGroup:_group._id];
                                                         [[DatabaseManager defaultManager] addGroupToFavorite:_group
                                                                                                       toUser:[[UserManager defaultManager] getLoginedUser]
                                                                                                      success:successBlock
                                                                                                        error:errorBlock];
                                                     }
                                                     else {
                                                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password", nil)];
                                                     }
                                                 }];
    } else {
        [[DatabaseManager defaultManager] addGroupToFavorite:_group
                                                      toUser:[[UserManager defaultManager] getLoginedUser]
                                                     success:successBlock
                                                       error:errorBlock];
    }
}

- (IBAction) startConversation{
    if ([self isPasswordAlertNeeded:_group]) {
        [[AlertViewManager defaultManager] showInputPassword:@"Please input password"
                                                 resultBlock:^(NSString *password){
                                                     
                                                     if(password != nil && [[Utils MD5:password] isEqualToString:_group.password]) {
                                                         [self savePassword:_group.password forGroup:_group._id];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:_group];
                                                     }
                                                     else {
                                                         [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Wrong password", nil)];
                                                     }
                                                 }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:_group];
    }
}

-(IBAction) openOwner{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:_owner];
}

- (IBAction)viewMembers:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUsersInGroup object:@{@"groupID" : _group._id}];
}



#pragma mark - Load Categories

-(IBAction)onCategoryOpen{
    [self.view endEditing:YES];
    [self showPickerTableViewForPickerDataType:HUPickerGroupCategoryDataType];
}


//////// following methods are used by extended classes - HUNewGroupViewController/HUMyGroupProfileViewController

#pragma mark - HUPickerTableView Methods

-(void)showPickerTableViewForPickerDataType:(HUPickerTableViewDataType)dataType
{
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
				cell = [[HUGroupsCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:cellIdentifier];
			}
			
			[cell populateWithData:groupCategory];
			
			cell.avatarImageView.image = [UIImage imageNamed:@"group_stub"];
			
            [HUCachedImageLoader imageFromUrl:groupCategory.imageUrl completionHandler:^(UIImage *image) {
                if(image)
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
			[_categoryValueLabel setText:groupCategory.title];
            
            if(groupCategory.imageUrl.length != 0){
                [[DatabaseManager defaultManager] loadCategoryIconByName:groupCategory.title success:^(UIImage *image){
                    
                    [_categoryIconView setImage:image];
                    
                    [self layoutViews];
                    
                }error:^(NSString *errStr){
                    
                }];
            }else{
                [_categoryIconView setImage:[UIImage imageNamed:@"group_stub_large"]];
            }
            
            
            
			_selectedCategoryID = groupCategory._id;
		}
		
		_pickerTableView.holderView.hidden = YES;
		UITableViewCell *cell = [pickerTableView cellForRowAtIndexPath:indexPath];
		cell.selected = NO;
	}
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self layoutViews];
    return YES;
}

#pragma mark - Group Password handeling
- (void)savePassword:(NSString *) password forGroup:(NSString *)groupId {
    
    NSString *key = [NSString stringWithFormat:@"group_pass_%@", groupId];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:password forKey:key];
    [userDefault synchronize];
}

- (NSString *)loadPasswordForGroup:(NSString *) groupId {
    
    NSString *key = [NSString stringWithFormat:@"group_pass_%@", groupId];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *password = [userDefault objectForKey:key];
    return password;
}

- (BOOL) isPasswordSavedForGroupCorrect:(ModelGroup *) group {
    BOOL isCorrect = NO;
    
    if ([group.password isEqualToString:[self loadPasswordForGroup:group._id]]) {
        isCorrect = YES;
    }
    
    return isCorrect;
}

- (BOOL) isPasswordAlertNeeded:(ModelGroup *) group {
    BOOL isNeeded = NO;
    
    if (group.password != nil && group.password.length > 0 && ![group.userId isEqualToString:[[UserManager defaultManager] getLoginedUser]._id]) {
        if ([self isPasswordSavedForGroupCorrect:group]) {
            isNeeded = NO;
        }
        else {
            isNeeded = YES;
        }
    }
    return isNeeded;
}

@end
