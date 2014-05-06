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
#import "HUProfileViewController.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "Models.h"
#import "UserManager.h"
#import "NSDateFormatter+SharedFormatter.h"
#import "HUEditableLabelView.h"
#import "HUBaseViewController+Style.h"
#import "AppDelegate.h"
#import "AutoScrollLabel.h"
#import "AlertViewManager.h"
#import "Utils.h"
#import "HUImageView.h"

@interface HUProfileViewController () {

    UIButton            *_saveButton;
    
    ModelUser *_user;
    
    NSMutableArray *_views;
    
    BOOL                _isEditing;
    BOOL                _keyboardShowing;
    
    NSDate              *_birthdayDate;
    
    UIActionSheet       *_genderActionSheet;
    UIImage             *_avatarImage;
    
    NSArray *_genderDataSource, *_onlineStatusDataSource;
	NSArray *_onlineStatusImageNamesArray;

}

@property (nonatomic) CGFloat maximumScrollViewHeight;

@end


@implementation HUProfileViewController


#pragma mark - Dealloc

-(void) dealloc {

}

#pragma mark - Initialization

- (id)initWithUser:(ModelUser *) user{
  
    if (self = [super init]) {
        
        _user = [ModelUser objectWithDictionary:[ModelUser objectToDictionary:user]];
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;
        

    }
    
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil withUser:(ModelUser *)user{

    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        
        _user = [ModelUser objectWithDictionary:[ModelUser objectToDictionary:user]];
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;

        
    }
    
    return self;
    
}

- (void) viewDidLoad{
    _userAvatarImageView.delegate = self;
}

- (void) hideView:(UIView *)view{
    CGRect rect = view.frame;
    rect.size.height = 0;
    view.frame = rect;
}

- (void) showView:(UIView *)view height:(int) height{
    CGRect rect = view.frame;
    rect.size.height = height;
    view.frame = rect;
}

- (void) layoutViews{
    
    UIImage *originalImage = _avatarImage;
    CGSize imageSize = _userAvatarImageView.downloadedImageSize;
    
    float viewHeight = 200;
    
    if(originalImage == nil)
        originalImage = _userAvatarImageView.image;
    
    float imageWidth = imageSize.width;
    
    if(imageWidth != 0){
        
        float viewWidth = _userAvatarImageView.width;
        
        float scale = viewWidth / imageWidth;
        
        if(originalImage != nil && scale != 0){
            viewHeight = imageSize.height * scale;
            [_avatarImageViewHeightConstraint setConstant:viewHeight];
        }

        
    }

    [_aboutValueLabel sizeToFit];
    int aboutViewHeight = _aboutValueLabel.size.height + 40;
    
    if(_aboutViewHeightConstraint.constant < aboutViewHeight)
        [_aboutViewHeightConstraint setConstant:aboutViewHeight];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGPoint absolutePosition = [_bottomElement convertPoint:_bottomElement.frame.origin toView:_contentView];
        [_contentHeightConstraint setConstant:absolutePosition.y + _bottomElement.height + 20];
    });
    
    
}

#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];

    _onlineStatusDataSource = kStatusDataSource;
    _onlineStatusImageNamesArray = kStatusImageNames;

    ModelUser *myUser = [UserManager defaultManager].getLoginedUser;
    
    if (![myUser._id isEqualToString:self.user._id]) {
        
        if (![myUser.contacts containsObject:self.user._id]) {
            [self addContactAddButton];
        }else{
            [self addContactRemoveButton];
        }
        
        [self showTutorialIfCan:NSLocalizedString(@"tutorial-userprofile",nil)];
        
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [_startConversationBtn setTitle:NSLocalizedString(@"Start-Conversation", nil) forState:UIControlStateNormal];
    [_nameLabel setText:NSLocalizedString(@"Name", nil)];
    [_lastLoginLabel setText:NSLocalizedString(@"Last Login", nil)];
    [_aboutLabel setText:NSLocalizedString(@"About", nil)];
    [_birthdayLabel setText:NSLocalizedString(@"Birthday", nil)];
    [_genderLabel setText:NSLocalizedString(@"Gender", nil)];
    [_statusLabel setText:NSLocalizedString(@"Online Status", nil)];
    
    [self populateWithData];
    
}


#pragma mark - Adding Button

- (void) addContactAddButton {
    
    self.navigationItem.rightBarButtonItems = [self addContactBarButtonItemsWithSelector:@selector(onAddContact:)];
}

- (void) addContactRemoveButton {
    
    self.navigationItem.rightBarButtonItems = [self removeContactBarButtonItemsWithSelector:@selector(onRemoveContact:)];
}


-(void) backButtonDidPress:(id)sender {
    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
}


- (NSString *) title {
    return self.user.name;
}

- (void) populateWithData {
    
    __weak HUProfileViewController *this = self;
    
    [[DatabaseManager defaultManager] reloadUser:_user
                                         success:^(id result) {
                                             _user = result;
                                             
                                             [_nameValueLabel setText:_user.name];

                                             [_aboutValueLabel setText:_user.about];
                                             
                                             if(_user.birthday != 0){
                                                 _birthdayDate = [NSDate dateWithTimeIntervalSince1970:_user.birthday];
                                             }
                                             
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
                                             
                                             
                                             [this displayDate];
                                             [this layoutViews];
                                             [this loadAvatar];
                                             
                                         }
                                           error:^(NSString *errorString) {
                                               NSLog(@"failed to reload user");
                                           }];
                                             
    
}

-(void) displayDate{

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDefaultDateFormat];
    
    if(_birthdayDate != nil){
        NSString *dateString = [format stringFromDate:_birthdayDate];
        [_birthdayValueLabel setText:dateString];
    }else{
        [_birthdayValueLabel setText:@""];
    }

    if(_user.lastLogin != 0){
        NSString *dateString2 = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:_user.lastLogin]];
        [_lastLoginValueLabel setText:dateString2];
    }
    
}


-(void) loadAvatar{
        
    if( _user.imageUrl != nil &&  _user.imageUrl.length > 0){
        NSString *url = _user.imageUrl;
        
        UIImage *image = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:url]];
        
        if (image) {
            _avatarImage = image;
            _userAvatarImageView.image = image;
            [self layoutViews];
        }else{
            [_userAvatarImageView startDownload:[NSURL URLWithString:url]];
        }
    }
}

- (void) downloadSucceed:(id) sender{
    [self performSelector:@selector(layoutViews) withObject:nil afterDelay:0.1];
}

#pragma mark - Button Selectors
- (IBAction)startConversation:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:_user];
    
}

- (void) onAddContact:(id)sender {
    
    __weak HUProfileViewController *this = self;
    
    ModelUser *myUser = [UserManager defaultManager].getLoginedUser;
    
    int currentContacts = myUser.contacts.count;
    int contactMax = myUser.maxContactNum;
    
    if(currentContacts >= contactMax){
        [[AlertViewManager defaultManager] showAlert:[NSString stringWithFormat:NSLocalizedString(@"Max Contact Exceeded",nil),contactMax]];
        return;
    }
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    [[DatabaseManager defaultManager] updateUserAddRemoveContacts:myUser
                                                        contactId:self.user._id
                                                          success:^(BOOL succees,NSString *errStr){
                                                              
              [[DatabaseManager defaultManager] reloadUser:[[UserManager defaultManager] getLoginedUser] success:^(id result){
                  
                  if(result != nil){
                      
                      [[AlertViewManager defaultManager] dismiss];
                      [[UserManager defaultManager] setLoginedUser:(ModelUser *) result];
                      [this addContactRemoveButton];
                      
                  }
                  
              } error:^(NSString *errstr){
                  
                  [[AlertViewManager defaultManager] dismiss];
                  
              }];

              
          } error:^(NSString *errStr) {
              [[AlertViewManager defaultManager] dismiss];
              [CSToast showToast:errStr withDuration:3.0];
              
    }];
    
    
    
    
}

- (void) onRemoveContact:(id)sender {
    
    __weak HUProfileViewController *this = self;
    
    ModelUser *myUser = [UserManager defaultManager].getLoginedUser;
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    [[DatabaseManager defaultManager] updateUserAddRemoveContacts:myUser
                                                        contactId:self.user._id
                                                          success:^(BOOL success, NSString *errStr) {
                                                              
          [[DatabaseManager defaultManager] reloadUser:[[UserManager defaultManager] getLoginedUser] success:^(id result){
              
              if(result != nil){
                  
                  [[AlertViewManager defaultManager] dismiss];
                  [[UserManager defaultManager] setLoginedUser:(ModelUser *) result];
                  [this addContactAddButton];
                  
              }
              
          } error:^(NSString *errstr){
              
              [[AlertViewManager defaultManager] dismiss];
              
          }];
          
      } error:^(NSString *errStr) {
          [[AlertViewManager defaultManager] dismiss];
          [CSToast showToast:errStr withDuration:3.0];
          
      }];
    
    
    
    
}

-(NSArray *) addContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Add-Contact", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                 target:self
                                               selector:aSelector];
}

-(NSArray *) removeContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Remove-Contact", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                 target:self
                                               selector:aSelector];
}


@end
