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
#import "HUProfileViewController+Style.h"
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

@interface HUProfileViewController () {
    HUEditableLabelView *_nameLabel;
    HUEditableLabelView *_lastLoginLabel;
    HUEditableLabelView *_aboutLabel;
    HUEditableLabelView *_genderLabel;
    HUEditableLabelView *_birthdayLabel;
    HUEditableLabelView *_onlineStatusLabel;
    UIButton            *_saveButton;
    UIButton            *_startConversationBtn;
    
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
    CS_RELEASE(_nameLabel);
    CS_RELEASE(_lastLoginLabel);
    CS_RELEASE(_aboutLabel);
    CS_RELEASE(_genderLabel);
    CS_RELEASE(_birthdayLabel);
    CS_RELEASE(_user);
    CS_RELEASE(_userAvatarImageView);
    CS_RELEASE(_onlineStatusLabel);
    
    CS_SUPER_DEALLOC;
}

#pragma mark - Initialization

- (id)initWithUser:(ModelUser *) user{
  
    if (self = [super init]) {
        
        _user = CS_RETAIN([ModelUser objectWithDictionary:[ModelUser objectToDictionary:user]]);
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;
        
        self.view.backgroundColor = [self viewBackgroundColor];

    }
    
    return self;
    
}


- (id)init {
    
    if (self = [super init]) {
        
        _views = [[NSMutableArray alloc] initWithCapacity:10];
        _isEditing = NO;
        _keyboardShowing = NO;
        
        self.view.backgroundColor = [self viewBackgroundColor];
        
    }
    
    return self;
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
    
    _aboutLabel.frame = CGRectMake(
                                   _aboutLabel.x,
                                   _aboutLabel.y,
                                   _aboutLabel.width,
                                   _aboutLabel.textView.contentSize.height
                                   );
    
    int width = CGRectGetWidth(self.view.frame) - kMargin * 2;
    int x = kMargin;
    int y = kMargin;
    
    for(UIView *view in _views){
        
        if(view == _userAvatarImageView){
            
            UIImage *originalImage = _avatarImage;
            float viewHeight = 200;
            
            if(originalImage == nil)
                originalImage = _userAvatarImageView.image;
            
            float imageWidth = originalImage.size.width;
            float viewWidth = _userAvatarImageView.width;
            
            float scale = viewWidth / imageWidth;
            
            if(originalImage != nil)
                viewHeight = originalImage.size.height * scale;
            
            _userAvatarImageView.frame = CGRectMake(
                                                    _userAvatarImageView.x,
                                                    _userAvatarImageView.y,
                                                    _userAvatarImageView.width,
                                                    viewHeight
                                                    );
        } else if (view == _startConversationBtn) {
            
            _startConversationBtn.frame = CGRectMake(
                                                     _startConversationBtn.x,
                                                     y,
                                                     _startConversationBtn.width,
                                                     kStartButtonHeight
                                                     );
            
        }else{
            view.frame = CGRectMake(x, y, width, view.frame.size.height);
            
        }
        
        if(view.frame.size.height != 0 && view.hidden != YES)
            y += view.frame.size.height + kMargin;
        
        
    }
    
    _contentView.contentSize = CGSizeMake(_contentView.contentSize.width,y + kMargin);
}

- (CGRect) frameByNumberOfElement:(int) number{
    
    int width = CGRectGetWidth(self.view.frame) - kMargin * 2;
    int x = kMargin;
    int height = 200;
    if(number == 0)
        height = 200;
    else if(number == 1)
        height = kStartButtonHeight;
    else
        height = kEditableLabelHeight;
    
    int y = kMargin;
    
    for(int i = 0;i < number ; i++){
        
        int lastElementHeight = kEditableLabelHeight;
        
        if(i == 0)
            lastElementHeight = 200;
        if(i == 1)
            lastElementHeight = kStartButtonHeight;
        
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
    
    _contentView = CS_RETAIN([self newContentView]);
    [self.view addSubview:_contentView];
    
    _userAvatarImageView = CS_RETAIN([self newUserAvatarImageView]);
    _userAvatarImageView.frame = [self frameByNumberOfElement:0];
    _userAvatarImageView.delegate = self;
    [_contentView addSubview:_userAvatarImageView];

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
    UIImage *arrow2 = [UIImage imageNamed:@"table_arrow_white"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:arrow2];
    imageView2.frame = CGRectMake(
                                  _startConversationBtn.width - arrow2.size.width - 5,
                                  5,
                                  arrow2.size.width,
                                  arrow2.size.height
                                  );
    [_startConversationBtn addSubview:imageView2];
    if ([myUser._id isEqualToString:self.user._id]) {
        _startConversationBtn.hidden = YES;
    }
    
    _nameLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Name", nil)]);
    _nameLabel.frame = [self frameByNumberOfElement:2];
    [_nameLabel setDelegate:self];
    [_contentView addSubview:_nameLabel];
    
    _lastLoginLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Last Login", nil)]);
    _lastLoginLabel.frame = [self frameByNumberOfElement:3];
    [_lastLoginLabel setDelegate:self];
    [_contentView addSubview:_lastLoginLabel];
    
    _aboutLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"About", nil)]);
    _aboutLabel.frame = [self frameByNumberOfElement:4];
    _aboutLabel.multiLine = YES;
    [_aboutLabel setDelegate:self];
    [_contentView addSubview:_aboutLabel];
    
    _birthdayLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Birthday", nil)]);
    _birthdayLabel.frame = [self frameByNumberOfElement:5];
    [_birthdayLabel setDelegate:self];
    [_contentView addSubview:_birthdayLabel];
    
    _genderLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Gender", nil)]);
    _genderLabel.frame = [self frameByNumberOfElement:6];
    [_genderLabel setDelegate:self];
    [_contentView addSubview:_genderLabel];
    
    _onlineStatusLabel = CS_RETAIN([self getEditorLabelByTitle:NSLocalizedString(@"Online Status", nil)]);
    _onlineStatusLabel.frame = [self frameByNumberOfElement:7];
    [_onlineStatusLabel setDelegate:self];
    [_contentView addSubview:_onlineStatusLabel];
    
    _saveButton = [self newSaveButtonWithSelector:@selector(onSave)];
    [self hideView:_saveButton];
    [_contentView addSubview:_saveButton];

    [_views addObject:_userAvatarImageView];
    [_views addObject:_startConversationBtn];
    [_views addObject:_nameLabel];
    [_views addObject:_lastLoginLabel];
    [_views addObject:_aboutLabel];
    [_views addObject:_birthdayLabel];
    [_views addObject:_genderLabel];
    [_views addObject:_saveButton];
    [_views addObject:_onlineStatusLabel];

    _genderActionSheet = [[UIActionSheet alloc]
                          initWithTitle:@"Select gender"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Male",nil),
                                                NSLocalizedString(@"Female",nil),
                                                NSLocalizedString(@"No declaration",nil), nil];
    
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
                                             
                                             [_genderLabel setEditerText:_user.gender];
                                             [_aboutLabel setEditerText:_user.about];
                                             [_nameLabel setEditerText:_user.name];
                                             
                                             if(_user.birthday != 0){
                                                 _birthdayDate = [NSDate dateWithTimeIntervalSince1970:_user.birthday];
                                             }
                                             
                                             
                                             [_onlineStatusLabel setEditerText:[_user.onlineStatus isEqualToString:@""] ? _onlineStatusDataSource[0] : [Utils convertOnlineStatusKeyForDisplay:_user.onlineStatus]];
                                             
                                             int stateIndex = 0;
                                             for(int i = 0 ; i < _onlineStatusDataSource.count ; i++){
                                                 
                                                 if([_onlineStatusDataSource[i] isEqualToString:[Utils convertOnlineStatusKeyForDisplay:_user.onlineStatus]]){
                                                     stateIndex = i;
                                                     break;
                                                 }
                                                 
                                             }
                                             
                                             [_onlineStatusLabel setIconImage:[UIImage imageNamed:_onlineStatusImageNamesArray[stateIndex]]];
                                             
                                             
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
        [_birthdayLabel setEditerText:dateString];
    }

    if(_user.lastLogin != 0){
        NSString *dateString2 = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:_user.lastLogin]];
        [_lastLoginLabel setEditerText:dateString2];
    }
    
}


-(void) loadAvatar{
    
    __weak HUProfileViewController *this = self;
    
    if( _user.imageUrl != nil &&  _user.imageUrl.length > 0){
        NSString *url = _user.imageUrl;
        
        UIImage *image = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:url]];
        
        if (image) {
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
- (void) startConversation{
    
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

@end
