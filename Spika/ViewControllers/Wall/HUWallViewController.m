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

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "HUWallViewController.h"
#import "HUWallViewController+Style.h"
#import "Utils.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "HUImageUploadViewController.h"
#import "AppDelegate.h"
#import "ImageDetailVC.h"
#import "HUPhotoDetailViewController.h"
#import "VideoDetailVC.h"
#import "LocationViewController.h"
#import "LoadingViewCell.h"
#import "AlertViewManager.h"
#import "HPGrowingTextView.h"
#import "UIImage+NoCache.h"
#import "UIImagePickerController+Extensions.h"
#import "HUVoiceRecorderViewController.h"
#import "HUVoiceMessageDetailViewController.h"
#import "ModelMessage.h"
#import "HUVideoRecorderViewController.h"
#import "NSNotification+Extensions.h"
#import "HUBaseViewController+Style.h"
#import "HUDeleteViewController.h"
#import "HUDeleteInformationViewController.h"
#import "TransitionDelegate.h"
#import "HUCachedImageLoader.h"
#import "MessageTypeEmoticonCell.h"
#import "MessageTypeNewsCell.h"
#import "MessageTypeTextCell.h"


@interface HUWallViewController () <HPGrowingTextViewDelegate> {

    ModelUser           *_targetUser;
    UIView              *_contentView;
    UIView              *_messageInputContainer;
    UIButton            *_mediaButton;
    UIButton            *_sendButton;
    HPGrowingTextView   *_messageInputTextField;
    
    CSLazyLoadController *_lazyLoadController;
    
    HUMediaPanelView      *_HUMediaPanelView;
    
    BOOL                _isMediaPanelShown;
    __block BOOL        _shouldShowKeyboard;
    __block BOOL        _shouldShowMediaPanel;
    __block BOOL        _isKeyboardShown;
    
    ModelMessage        *_lastSelectedMessage;
	
	id					_notificationObserver;
    
    NSTimer             *timer;
}

@property (nonatomic, strong) ModelGroup *targetGroup;
@property (readwrite) BOOL isKeyboardShown;
@property (nonatomic, strong) TransitionDelegate *transitionDelegate;

#pragma mark - Animations
- (void) animateKeyboardWillShow:(NSNotification *)aNotification;
- (void) animateKeyboardWillHide:(NSNotification *)aNotification;

@end

@implementation HUWallViewController

#pragma mark - Memory Management

- (void) dealloc{
    
    [self.tableView setEditing:NO];
    
    [_contentView removeObserver:self
                      forKeyPath:@"frame"];
    
    [_reloadTimer invalidate];
    _reloadTimer = nil;
	
	if (_targetMode == ModeGroup) {
		[[NSNotificationCenter defaultCenter] removeObserver:_notificationObserver];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        _targetMode = 0;
        _currentPage = 0;
        _flgPullEnough = NO;
        _flgLoadAll = NO;
        _isLastPage = NO;
        
        _lazyLoadController = [CSLazyLoadController new];
    }
    
    return self;
}

- (id)initWithUser:(ModelUser *)user {
    
    if (self = [self init]) {
        
        _targetUser = user;
        _targetMode = ModeUser;
        _loadingNewPage = NO;
        
        [self getPage:_currentPage];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastGroupId = [defaults objectForKey:LastOpenedGroupWall];
        if(lastGroupId){
            
            [[DatabaseManager defaultManager] deleteWatchinGroupLog:user._id];
            
            [defaults removeObjectForKey:LastOpenedGroupWall];
            [defaults synchronize];
        }
    }
    return self;
}

- (id)initWithGroup:(ModelGroup *)group {
    
    if (self = [self init]) {
        
        _targetGroup = group;
        _targetMode = ModeGroup;
        _loadingNewPage = NO;
        
        
        [self getPage:_currentPage];
        
		__weak HUWallViewController *this = self;
		_notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NotificationGroupUpdated
																				  object:nil
																				   queue:nil
																			  usingBlock:^(NSNotification *note)
		{
			ModelGroup *newGroup = note.userInfo[@"updated_group"];
			this.targetGroup = newGroup;
			[this reload];
		}];
        
        ModelUser *user = [[UserManager defaultManager] getLoginedUser];
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastGroupId = [defaults objectForKey:LastOpenedGroupWall];
        if(lastGroupId){
            
            [[DatabaseManager defaultManager] deleteWatchinGroupLog:user._id];

            [defaults removeObjectForKey:LastOpenedGroupWall];
            [defaults synchronize];

            
        }
        
        if(![user isInFavoriteGroups:group]){
            [[DatabaseManager defaultManager] insertWatchinGroupLog:user._id groupId:group._id];            

            [defaults setValue:group._id forKey:LastOpenedGroupWall];
            [defaults synchronize];
            
        }
        
        
        if(group.deleted){
            [self deletedGroup];
        }
    
    }
    
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"frame"]) {
        
        _contentViewFrame = _contentView.frame;
    }
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.view addGestureRecognizer:tap];
    
    _allowSwipe = NO;
    
    _contentView = [self contentView];
    [self setContentViewTopShadow:_contentView];
    [self.view addSubview:_contentView];
    
    _contentViewFrame = _contentView.frame;
    
    [_contentView addObserver:self
                   forKeyPath:@"frame"
                      options:0
                      context:NULL];
    
    [self.tableView removeFromSuperview];
    self.tableView = [self messagesTableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = self.isCellSelectionEnabled;
    
    [_contentView addSubview:self.tableView];
    
    
    _messageInputContainer = [self messageInputContainer];
    [self setShadowOnTopOfInputView:_messageInputContainer];
    [_contentView addSubview:_messageInputContainer];
    
    _mediaButton = [self mediaButton];
    [_mediaButton addTarget:self
                     action:@selector(onMediaButton)
           forControlEvents:UIControlEventTouchUpInside];
    
    _sendButton = [self sendButton];
    [_sendButton addTarget:self
                    action:@selector(onSend)
          forControlEvents:UIControlEventTouchUpInside];
    
    _messageInputTextField = [self messageInputTextField];
    _messageInputTextField.delegate = self;
    
    [_messageInputContainer addSubview:_mediaButton];
    [_messageInputContainer addSubview:_sendButton];
    [_messageInputContainer addSubview:_messageInputTextField];

    _HUMediaPanelView = [self mediaPanelView];
    _HUMediaPanelView.delegate = self;
    [_contentView addSubview:_HUMediaPanelView];
    
	[self reload];
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    [self.view endEditing:YES];
    [self hideMediaMenu];
}

-(void) backButtonDidPress:(id)sender {
    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    
    __weak HUWallViewController *this = self;
    
    [super viewWillAppear:animated];
    
    
    [self subscribeForKeyboardWillShowNotificationUsingBlock:^(NSNotification *note) {
       
        this.isKeyboardShown = YES;
        
    }];

    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillShow:note];
    }];
    

    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        
        this.isKeyboardShown = NO;
        [this animateKeyboardWillHide:note];
        
    }];
    
	[this reload];

    if(_targetUser != nil)
        [[HUPushNotificationManager defaultManager] setTarget:_targetUser];
    
    if(_targetGroup != nil)
        [[HUPushNotificationManager defaultManager] setTarget:_targetGroup];    
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startTimer];

}

- (void) viewWillDisappear:(BOOL)animated {
    
    [self stopTimer];
    
    [super viewWillDisappear:animated];
    
    [self unsubscribeForKeyboardWillShowNotification];
    
    [self unsubscribeForKeyboardWillChangeFrameNotification];
    
    [self unsubscribeForKeyboardWillHideNotification];
}

- (void) viewDidLoad{
    
    [super viewDidLoad];
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-wall",nil)];
    self.transitionDelegate = [[TransitionDelegate alloc] init];
}

#pragma mark - Override

- (NSString *) title {
    
    if(_targetGroup != nil)
        return _targetGroup.name;
    if(_targetUser != nil)
        return _targetUser.name;

    return @"";
    
}

- (BOOL) isCellSelectionEnabled {
    
    return NO;
}

#pragma mark - Button Selectors

- (void) onProfile {
    
    if(_targetGroup == nil && _targetUser == nil)
        return;
    
    [self showProfileForUser:_targetUser group:_targetGroup];
    
}

- (void) onMediaButton {
    
    if (!_isMediaPanelShown) {
        
        _shouldShowKeyboard = NO;
        [_HUMediaPanelView resetState];
        [self showMediaMenu];
    }
    else {
        
        _shouldShowKeyboard = NO;
        [self hideMediaMenu];
    }
}

- (void) onSend {

    [self.view endEditing:YES];
    
    NSString *messageText = _messageInputTextField.text;
    if(messageText && [messageText length] != 0) {
        [self sendMessage:messageText];
    }
    
    _messageInputTextField.text = @"";
}

#pragma mark - Animations

- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect contentViewFrame = self.view.bounds;
    contentViewFrame.size.height -= kbSize.height;
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect messageInputHolderFrame = [self frameForMessageInputContainer];
    
    messageInputHolderFrame.origin.y -= (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                         CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                         0 ) + CGRectGetHeight([self frameForMediaPanel]);
    
    messageInputHolderFrame.size.height += (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                            CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                            0);

    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^{
                         
                         _contentView.frame = contentViewFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         [self scrollToBottom];
                         
                     }

     ];
     
     
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^{
                         
                         _contentView.frame = self.view.bounds;
                     }
                     completion:^(BOOL finished) {
                     
                         if (_shouldShowMediaPanel) {
                             [self showMediaMenu];
                             _shouldShowMediaPanel = NO;
                         }
                             
                     }
     ];
     
     
}

- (void) showMediaMenu {
    
    if (_isMediaPanelShown) {
        return;
    }
    
    if (_isKeyboardShown) {
        _shouldShowMediaPanel = YES;
        [_messageInputTextField resignFirstResponder];
        return;
    }
    
    _mediaButton.enabled = NO;
    
    CGRect messageInputHolderFrame = [self frameForMessageInputContainer];
    
    messageInputHolderFrame.origin.y -= (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                         CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                         0 ) + CGRectGetHeight([self frameForMediaPanel]);
    
    messageInputHolderFrame.size.height += (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                            CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                            0);
    
    CGRect HUMediaPanelViewFrame = [self frameForMediaPanel];
    HUMediaPanelViewFrame = CGRectMake(0,
                                     CGRectGetMaxY(messageInputHolderFrame),
                                     CGRectGetWidth(HUMediaPanelViewFrame),
                                     CGRectGetHeight(HUMediaPanelViewFrame));
    
    CGRect tableViewFrame = [self frameForMessagesTableView];
    tableViewFrame = CGRectMake(CGRectGetMinX(tableViewFrame),
                                CGRectGetMinY(tableViewFrame),
                                CGRectGetWidth(tableViewFrame),
                                CGRectGetMinY(messageInputHolderFrame));
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         
                         _mediaButton.transform = CGAffineTransformMakeRotation(M_PI);
                         _messageInputContainer.frame = messageInputHolderFrame;
                         _HUMediaPanelView.frame = HUMediaPanelViewFrame;
                         self.tableView.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         _mediaButton.enabled = YES;
                         _isMediaPanelShown = YES;
                     }];
}

- (void) hideMediaMenu {
    
    if (!_isMediaPanelShown) {
        return;
    }
    
    _mediaButton.enabled = NO;
    
    CGRect messageInputHolderFrame = [self frameForMessageInputContainer];
    
    messageInputHolderFrame.origin.y -= (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                         CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                         0);
    
    messageInputHolderFrame.size.height += (CGRectGetHeight(_messageInputTextField.frame) > 36 ?
                                            CGRectGetHeight(_messageInputTextField.frame) - 36 :
                                            0);
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                     
                         _mediaButton.transform = CGAffineTransformIdentity;
                         _messageInputContainer.frame = messageInputHolderFrame;
                         _HUMediaPanelView.frame = [self frameForMediaPanel];
                         self.tableView.frame = [self frameForMessagesTableView];
                         
                     }
                     completion:^(BOOL finished) {
                     
                         _mediaButton.enabled = YES;
                         _isMediaPanelShown = NO;
                         
                         if (_shouldShowKeyboard) {
                             
                             _shouldShowKeyboard = NO;
                             [_messageInputTextField becomeFirstResponder];
                             
                         }
                         
                     }];
}

- (void) scrollToBottom {
    
    if(self.items.count == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.items.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition: UITableViewScrollPositionTop
                                  animated: YES];
}

- (void) scrollToFirstRowInLastPage {
    
    if(self.items.count == 0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.items.count-PagingMessageFetchNum inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition: UITableViewScrollPositionTop
                                  animated: NO];
}
#pragma mark - Timer Selectors
/*
- (void) onReloadTimer {
    
    [self reload];
}
 */
#pragma mark - Data Actions

- (void) sendMessage:(NSString *)message {
    
    __weak HUWallViewController *this = self;
    
    [[DatabaseManager defaultManager] sendTextMessage:_targetMode
                                               toUser:_targetUser
                                              toGroup:_targetGroup
                                                 from:[[UserManager defaultManager] getLoginedUser]
                                              message:message
                                              success:^(BOOL isSuccess,NSString *errStr){
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if(isSuccess == YES){
                                                          
                                                          [CSToast showToast:NSLocalizedString(@"Message sent", nil) withDuration:3.0];
                                                          
                                                          [this reload];
                                                          
                                                          _messageInputTextField.text = @"";
                                                      }
                                                      else {
                                                          
                                                          [CSToast showToast:errStr withDuration:3.0];
                                                          
                                                      }
                                                  });
                                                  
                                              } error:^(NSString *errStr){
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      //[[AlertViewManager defaultManager] dismiss];
                                                  });
                                              }];
    
}

- (void) dropViewDidBeginRefreshing:(id)sender {

}

- (void) getPage:(int) page {
    
    if(_targetMode == ModeUser) {
        
        [self loadUserMessages:page shouldHideLoadingCell:YES];
    }
    
    if(_targetMode == ModeGroup){
        
        [self loadGroupMessages:page shouldHideLoadingCell:YES];
    }
}

- (void) reload {
    
    // find index of message to update
    for(int i = 0; i < self.items.count ; i++){
        
        ModelMessage *message = [self.items objectAtIndex:i];
        
        if([message isKindOfClass:[ModelMessage class]]){
            
            if([message._id isEqualToString:_lastSelectedMessage._id]){
                
                NSIndexPath *durPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray *paths = [NSArray arrayWithObject:durPath];
                [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
        }
        
    }
    
    if(_targetMode == ModeUser){
        [self loadUserMessages:0 shouldHideLoadingCell:NO];
    }
    
    if(_targetMode == ModeGroup){
        [self loadGroupMessages:0 shouldHideLoadingCell:NO];
    }
}

- (void) reloadAll {
    [self.items removeAllObjects];
    [self reload];
}

- (void) loadUserMessages:(NSInteger)page shouldHideLoadingCell:(BOOL)hideLoadingCell {
    
    __weak HUWallViewController *this = self;
    
    [[DatabaseManager defaultManager] findUserMessagesByUser:[[UserManager defaultManager] getLoginedUser]
                                                     partner:_targetUser
                                                        page:page
                                                     success:^(NSArray *aryMessages){

         dispatch_async(dispatch_get_main_queue(), ^{
            
             if(aryMessages.count < PagingMessageFetchNum)
                 _isLastPage = YES;
             
             NSArray *tmpMessages = [Utils filterMessagesForApperaToWall:aryMessages];
             
             BOOL somethingChenged = [this isFindChanges:tmpMessages];
             BOOL findNewMessage = [this isFindNewMessage:tmpMessages];
             
             if(somethingChenged){
                 
                 [self setTableItems:[Utils mergeMessagesForApperaToWall:aryMessages oldMessages:self.items]];
             }
             
             if(findNewMessage)
                 [this performSelector:@selector(scrollToBottom)
                            withObject:nil
                            afterDelay:0.5f];
             
             if (hideLoadingCell) {
                 
                 
                 _loadingNewPage = NO;
                 
                 if([tmpMessages count] == 0)
                     _flgLoadAll = YES;
                 
                 double delayInSeconds = 1.0;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     [[AlertViewManager defaultManager] dismiss];
                     [_loadingViewCell hide];
                 });
                 
                 [self scrollToFirstRowInLastPage];
             }
         });
                                                         
     } error:^(NSString *errStr){
         /*
         dispatch_async(dispatch_get_main_queue(), ^{
             
         });
          */
     }];
}

- (void) loadGroupMessages:(NSInteger)page shouldHideLoadingCell:(BOOL)hideLoadingCell {

    __weak HUWallViewController *this = self;
    
    [[DatabaseManager defaultManager] findMessagesByGroup:_targetGroup
                                                     page:page
                                                  success:^(NSArray *aryMessages){
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          NSArray *tmpMessages = [Utils filterMessagesForApperaToWall:aryMessages];
                                                          
                                                          BOOL somethingChenged = [this isFindChanges:tmpMessages];
                                                          BOOL findNewMessage = [this isFindNewMessage:tmpMessages];
                                                          
                                                          if(somethingChenged){
                                                              
                                                              [self setTableItems:[Utils mergeMessagesForApperaToWall:aryMessages oldMessages:self.items]];
                                                          }
                                                          
                                                          if(findNewMessage)
                                                              [this performSelector:@selector(scrollToBottom)
                                                                         withObject:nil
                                                                         afterDelay:0.5f];
                                                          
                                                          if (hideLoadingCell) {
                                                              
                                                              
                                                              _loadingNewPage = NO;
                                                              
                                                              if([tmpMessages count] == 0)
                                                                  _flgLoadAll = YES;
                                                              
                                                              double delayInSeconds = 1.0;
                                                              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                  [[AlertViewManager defaultManager] dismiss];
                                                                  [_loadingViewCell hide];
                                                              });
                                                              
                                                              [self scrollToFirstRowInLastPage];
                                                          }
                                                      });
                                                  } error:^(NSString *errStr){
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                      });
                                                  }];
}

- (void) sendEmoticon:(NSDictionary *)emoticon {

    
    [[DatabaseManager defaultManager] sendEmoticonMessage:_targetMode
                                                   toUser:_targetUser
                                                  toGroup:_targetGroup
                                                     from:[[UserManager defaultManager] getLoginedUser]
                                             emoticonData:emoticon
                                                  success:^(BOOL isSuccess,NSString *errStr){
                                                      
                                                      if(isSuccess == YES){
                                                          
                                                          [CSToast showToast:NSLocalizedString(@"Message sent", nil) withDuration:3.0];
                                                          
                                                          [self reload];
                                                      }
                                                      else {
                                                       
                                                          [CSToast showToast:errStr withDuration:3.0];
                                                      }
                                                  }
                                                      error:^(NSString *errStr){
                                                          
                                                          [CSToast showToast:errStr withDuration:3.0];
                                                      }];
}

- (void) sendLocation:(NSDictionary *)location {
    
}

- (void) sendVoice:(NSURL *)url title:(NSString *)title{
    
    [[DatabaseManager defaultManager] sendVoiceMessage:_targetUser
                                               toGroup:_targetGroup
                                                  from:[[UserManager defaultManager] getLoginedUser]
                                               fileURL:url
                                                 title:title
                                               success:^(BOOL isSuccess, NSString *errorString) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[AlertViewManager defaultManager] dismiss];
            [self.navigationController popToViewController:self animated:YES];
            if(isSuccess == YES){
                
                [CSToast showToast:NSLocalizedString(@"Voice sent", nil) withDuration:3.0];
                [self reload];
                
            }else {
                
                [CSToast showToast:errorString withDuration:3.0];
                
            }
            
        });
        
        
    } error:^(NSString *errorString) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertViewManager defaultManager] dismiss];
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)
												 message:errorString];
        });
        
    }];

}

#pragma mark - Getter 


#pragma mark - Private Methods

- (void) showProfileForUser:(ModelUser *)user group:(ModelGroup *)group {
    
    if(_targetMode == TargetTypeUser)
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile
                                                            object:user];
    
    if(_targetMode == TargetTypeGroup)
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupProfile
                                                            object:group];
    
}

- (BOOL) isFindNewMessage:(NSArray *) newMessages{
    
    if(self.items.count == 0)
        return YES;
    
    long lastTimestampInNewMessages = 0;
    for(ModelMessage *newMessage in newMessages){
        
        if(newMessage.created > lastTimestampInNewMessages)
            lastTimestampInNewMessages = newMessage.created;
        
    }
    
    long lastTimestampInOldMessages = 0;
    for(ModelMessage *oldMessage in self.items){
        
        if(oldMessage.created > lastTimestampInOldMessages)
            lastTimestampInOldMessages = oldMessage.created;
        
    }
    
    return lastTimestampInNewMessages > lastTimestampInOldMessages;
    
}



- (BOOL) isFindChanges:(NSArray *) newMessages{
    
    BOOL somethingChanged = NO;
    
    if(self.items.count == 0)
        return YES;
    
    for(ModelMessage *origMessage in newMessages){
        
        BOOL messageExists = NO;
        
        for(ModelMessage *newMessage in self.items) {
            
            if([origMessage._id isEqualToString:newMessage._id]){
                
                messageExists = YES;
                
                if((origMessage.modified != newMessage.modified) || (origMessage.comment_count != newMessage.comment_count)){
                    somethingChanged = YES;
                    break;
                }
            }
        }
        
        if(messageExists == NO){
            
            somethingChanged = YES;
            break;
        }
        
        if(somethingChanged == YES)
            break;
        
    }
    
    return somethingChanged;
}

-(void) openUimageUploadVC:(UIImage *)image {
    
    HUImageUploadViewController *vc = [HUImageUploadViewController wallUploadViewControllerWithImage:image];
    vc.targetGroup = _targetGroup;
    vc.targetUser = _targetUser;
    
    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
    
}

-(void) sendVideo:(NSURL *)url{
    
    HUVideoRecorderViewController *vc = [[HUVideoRecorderViewController alloc] initWithFileURL:url];
    vc.targetGroup = _targetGroup;
    vc.targetUser = _targetUser;
    
    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITableViewDataSource methods

- (NSString *)cellIdentifierForMessage:(ModelMessage *)message {
    
    NSString *cellIdentifier = nil;
    
    if([message.message_type isEqualToString:MessageTypeImage]){
        
        cellIdentifier = @"cellidentifierImage";
    }
    else if([message.message_type isEqualToString:MessageTypeEmoticon]){
        
        cellIdentifier = @"cellidentifierEmoticon";
    }
    else if([message.message_type isEqualToString:MessageTypeVideo]){
        
        cellIdentifier = @"cellidentifierVideo";
    }
    else if([message.message_type isEqualToString:MessageTypeLocation]){
    
        cellIdentifier = @"cellidentifierLocation";
    }
    else if([message.message_type isEqualToString:MessageTypeVoice]){
        
        cellIdentifier = @"cellidentifierVoice";
    }
    else if([message.message_type isEqualToString:MessageTypeNews]){
        
        cellIdentifier = @"cellidentifierNews";
    }
    else {
        
        cellIdentifier = @"cellidentifierText";
    }
    
    NSAssert(cellIdentifier != nil, @"No cell identifier found for provided message type!");
    
    return cellIdentifier;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ModelMessage *message = [self.items objectAtIndex:indexPath.row];
    
    float height = 0.0;
    
    if([message.message_type isEqualToString:MessageTypeImage]){
        height = [MessageTypeImageCell cellHeightForMessage:message];
        
    }else if([message.message_type isEqualToString:MessageTypeEmoticon]){
        height = [MessageTypeEmoticonCell cellHeightForMessage:message];
        
    }else if([message.message_type isEqualToString:MessageTypeVideo]){
        height = [MessageTypeVideoCell cellHeightForMessage:message];
        
    }else if([message.message_type isEqualToString:MessageTypeLocation]){
        height = [MessageTypeLocationCell cellHeightForMessage:message];
        
    }else if([message.message_type isEqualToString:MessageTypeVoice]){
        height = [MessageTypeVoiceCell cellHeightForMessage:message];
        
    }else if([message.message_type isEqualToString:MessageTypeNews]){
        height = [MessageTypeNewsCell cellHeightForMessage:message];
        
    }else{
        height = [MessageTypeTextCell cellHeightForMessage:message];
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Hackish temp solution for crash
    if (!(indexPath.row < [self.items count])) {
        if(_loadingViewCell == nil) {
            _loadingViewCell =  [[LoadingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingview"];
            [_loadingViewCell hide];
        }
        return _loadingViewCell;
    }
    
    
    ModelMessage *message = [self.items objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = [self cellIdentifierForMessage:message];

    MessageTypeBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        
        cell = [[message.tableViewCellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:cellIdentifier];
        [cell setDelegate:self];
    }
     
    MessageTypeBasicCell *wallCell = (MessageTypeBasicCell *)cell;
    [wallCell updateWithModel:message];
    
    wallCell.avatarIconView.image = [UIImage imageNamed:@"user_stub"];
    
    [HUCachedImageLoader imageFromUrl:message.avatarThumbUrl completionHandler:^(UIImage *image) {
        if(image)
            wallCell.avatarIconView.image = image;
    }];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!(indexPath.row < [self.items count])) {
        //Hackish temp solution for crash
        return NO;
    }
    
    ModelMessage *message = [self.items objectAtIndex:indexPath.row];
    if ([UserManager messageBelongsToUser:message]) {
        return YES;
    }
    else {
        return NO;
    }
}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ModelMessage *message = [self.items objectAtIndex:indexPath.row];
        [self showDeleteDialogForMessage:message];
    }
}

- (void) showDeleteDialogForMessage:(ModelMessage*) message{
    HUDeleteViewController *deleteDialog =[[HUDeleteViewController alloc] initWithNibName:@"HUDeleteViewController" bundle:nil];
    deleteDialog.message = message;
    
    [deleteDialog setTransitioningDelegate:self.transitionDelegate];
    deleteDialog.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:deleteDialog animated:YES completion:NULL];
    [self.tableView setEditing:NO];
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    if(scrollView.contentOffset.y < 0 && _loadingNewPage == NO && _isLastPage == NO){
        [self dropViewDidBeginRefreshing];
    }
}

- (void) dropViewDidBeginRefreshing{

    //[self killScroll];
    
    _currentPage++;
    _loadingNewPage = YES;
    [self getPage:_currentPage];

    [_loadingViewCell show];
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
}

#pragma mark - HPGrowingTextViewDelegate


- (void) growingTextView:(HPGrowingTextView *)growingTextView
        willChangeHeight:(float)height {
    
    CGRect messageInputTextFieldFrame = [self frameForMessageInputTextField];
    
    if (height < CGRectGetHeight(messageInputTextFieldFrame)) {
        return;
    }
    
    height -= CGRectGetHeight(messageInputTextFieldFrame);
    
    CGRect viewHolderFrame = [self frameForMessageInputContainer];
    viewHolderFrame.origin.y -= height;
    viewHolderFrame.size.height += height;
    
    _messageInputContainer.frame = viewHolderFrame;
    
    CGRect textInputFrame = messageInputTextFieldFrame;
    
    if(_mediaButton.hidden == NO)
        _messageInputTextField.frame = textInputFrame;
}   

- (BOOL) growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {

    BOOL shouldReturn = _isMediaPanelShown ? NO : YES;
    
    if (_isMediaPanelShown) {
        _shouldShowKeyboard = YES;
        [self hideMediaMenu];
    }

    return shouldReturn;
    
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView{
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if (CFStringCompare((CFStringRef) mediaType,  kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage* picture = [info objectForKey:UIImagePickerControllerEditedImage];
        if (picture)
            [self performSelector:@selector(openUimageUploadVC:)
                       withObject:picture
                       afterDelay:0.5];
    }

    if (CFStringCompare((CFStringRef) mediaType,  kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        if (url) {				
            [self performSelector:@selector(sendVideo:)
                       withObject:url
                       afterDelay:0.5];
		}
    }
    
}

#pragma mark - HUMediaPanelViewDelegate

- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
  didSelectCameraButton:(UIButton *)button {

    [self hideMediaMenu];
    
    [self showPhotoCameraWithDelegate:self];
    
}

- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
   didSelectVideoButton:(UIButton *)button {

    [self hideMediaMenu];
    
    [self showVideoCameraWithDelegate:self];
    
}

- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
   didSelectAlbumButton:(UIButton *)button {

    [self hideMediaMenu];
    
    [self showPhotoLibraryWithDelegate:self];
    
}


- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
      didSelectEmoticon:(NSDictionary *)emoticonData {

    [self hideMediaMenu];
    
    [self sendEmoticon:emoticonData];
    
}

- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
didSelectLocationButton:(UIButton *)button {
    
    [self hideMediaMenu];
    
    //[self sendMessage:@"location"];
    
    ModelMessage *message = [[ModelMessage alloc] init];
    message.to_user_id=_targetUser._id;
    message.to_user_name=_targetUser.name;
    message.group_id=_targetGroup._id;
    message.group_name=_targetGroup.name;
    message.from_user_id = [[UserManager defaultManager] getLoginedUser]._id;
    message.from_user_name = [[UserManager defaultManager] getLoginedUser].name;
    
    LocationViewController *locationVC = [[LocationViewController alloc] initWithTargetUser:_targetUser targetGroup:_targetGroup targetMode:_targetMode];
    [self hideMediaMenu];
    [[AppDelegate getInstance].navigationController pushViewController:locationVC animated:YES];
    
}

- (void) mediaPanelView:(HUMediaPanelView *)mediaPanelView
   didSelectVoiceButton:(UIButton *)button {
    
    [self hideMediaMenu];
    
    // CALL VOICE RECORDER
    HUVoiceRecorderViewController *voiceRecorderViewController = [[HUVoiceRecorderViewController alloc] init];
    voiceRecorderViewController.delegate = self;
    [self.navigationController pushViewController:voiceRecorderViewController animated:YES];
    
//    [self sendMessage:@"voice"];
    
}

#pragma mark - MessageCellDelegate 

-(void) messageCell:(MessageTypeBasicCell *)cell didTapAvatarImage:(ModelMessage *)message {
    
    [[DatabaseManager defaultManager] findUserWithID:message.from_user_id success:^(id result) {
        
        ModelUser *user = (ModelUser *) result;
        
        NSString *notificationName = [UserManager messageBelongsToUser:message] ?
        NotificationSideMenuMyProfileSelected :
        NotificationShowProfile ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:user];

    } error:^(NSString *errorString) {
 
    }];
    
}

-(void) messageCell:(MessageTypeBasicCell *)cell didTapDeleteTimer:(ModelMessage *)message {
    
    if ([UserManager messageBelongsToUser:message]) {
        [self showDeleteDialogForMessage:message];
    }
    else {
        HUDeleteInformationViewController *deleteDialog =[[HUDeleteInformationViewController alloc] initWithNibName:@"HUDeleteInformationViewController" bundle:nil];
        deleteDialog.message = message;
        
        [deleteDialog setTransitioningDelegate:self.transitionDelegate];
        deleteDialog.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:deleteDialog animated:YES completion:NULL];
    }
}


#pragma mark - MessageImageCellDelegate

-(void) messageImageCell:(MessageTypeImageCell *)messageImageCell didTapPhotoView:(ModelMessage *)message {
    
    _lastSelectedMessage = message;
    
    HUPhotoDetailViewController *viewController = [[HUPhotoDetailViewController alloc] initWithMessage:message];
    [[AppDelegate getInstance].navigationController pushViewController:viewController animated:YES];
}

#pragma mark - MessageVideoCellDelegate

-(void) messageVideoCell:(MessageTypeVideoCell *)messageVideoCell didTapVideoMessage:(ModelMessage *)message {
    
    _lastSelectedMessage = message;
    
    VideoDetailVC *vc = [[VideoDetailVC alloc] initWithMessage:message];
    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
}

#pragma mark - MessageVoiceCellDelegate

-(void) messageVoiceCell:(MessageTypeVoiceCell *)messageVoiceCell didTapVoiceMessage:(ModelMessage *)message {
    
    _lastSelectedMessage = message;
    
    HUVoiceMessageDetailViewController *voicePlayerViewController = [[HUVoiceMessageDetailViewController alloc] init];
    voicePlayerViewController.message = message;
    [self.navigationController pushViewController:voicePlayerViewController animated:YES];
    
}
#pragma mark - MessageLocationCellDelegate

-(void) messageLocationCell:(MessageTypeLocationCell *)messageLocationCell didTapLocationMessage:(ModelMessage *)message {
    
    LocationViewController *vc = [[LocationViewController alloc] initWithMessage:message];
    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
}

#pragma mark - HUVoiceRecorderViewControllerDelegate

- (void)voiceRecorderViewController:(HUVoiceRecorderViewController *)sender sendAudio:(NSURL *)url title:(NSString *)title{
    
    [self sendVoice:url title:title];
}

#pragma mark - Notification Methods

-(void)didUpdateGroup:(NSNotification *)aNotification
{
	
}

- (void) hideMediaPanel{
    _mediaButton.hidden = YES;
    
    _messageInputTextField.frame = CGRectMake(
        _messageInputTextField.x - _mediaButton.width,
        _messageInputTextField.y,
        _messageInputTextField.width + _mediaButton.width,
        _messageInputTextField.height
    );
         
}

- (void) deletedGroup{
   
    UIView *blockView = [[UIView alloc] init];
    blockView.backgroundColor = [UIColor blackColor];
    blockView.frame = CGRectMake(
        0,
        0,
        self.view.width,
        self.view.height
    );
    blockView.alpha = 0.7;
    
    [self.view addSubview:blockView];
    
    [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"GroupDeleted", nil)];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
	[self hideMediaMenu];
}

#pragma mark - Timer functions

- (void) startTimer {
    
    if ([self isMemberOfClass:[HUWallViewController class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkMessageTimestampsForDelete) userInfo:nil repeats:YES];
    }
}

- (void) stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) checkMessageTimestampsForDelete {
    
    int now = [[NSDate date] timeIntervalSince1970];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for(int i = 0; i < self.items.count ; i++){
            
            ModelMessage *message = [self.items objectAtIndex:i];
            
            if ((message.deleteAt > 0) && (message.deleteAt < now)) {
                [self reloadAll];
            }

            
        }
    });
    
}

@end
