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

#import <UIKit/UIKit.h>
#import "UIImage+NoCache.h"
#import "UIView+Margin.h"

typedef NS_ENUM(NSInteger, HUViewType) {
    
    HUViewTypeMain = 0,
    HUViewTypeLoading,
    HUViewTypeNoItems
};

typedef NS_ENUM(NSInteger, HUSharedColorType) {

    HUSharedColorTypeGreen = 0,
    HUSharedColorTypeDark,
    HUSharedColorTypeGray,
    HUSharedColorTypeRed,
    HUSharedColorTypeDarkGreen,

};

@interface HUBaseViewController : UIViewController {
    
	BOOL			_isDebugMode;
    BOOL            _allowSwipe;
    UIBarButtonItem *_leftButtonShowMenu;
    UIBarButtonItem *_leftButtonHideMenu;
    UITextView      *_textViewForKeyboardWithDoneButton;
    
}

@property (nonatomic, readonly) BOOL isViewOpened;
@property (nonatomic, readwrite) HUViewType viewType;

- (BOOL) showTutorialIfCan:(NSString *)message;
- (void) showOneTimeAfterBootMessage:(NSString *)message key:(NSString *)key;

#pragma mark - PushNotification
- (void) presentPushNotificationView:(UIView *)view;
- (void) presentPushNotificationView:(UIView *)view completion:(CSVoidBlock)block;

- (void) dismissPushNotificationView:(UIView *)view;
- (void) dismissPushNotificationView:(UIView *)view completion:(CSVoidBlock)block;

#pragma mark - View States
- (void) showViewType:(HUViewType)viewType animated:(BOOL)animated;

#pragma mark - Keyboard Notifications
- (void) subscribeForKeyboardWillShowNotificationUsingBlock:(void (^)(NSNotification *note))block;
- (void) subscribeForKeyboardWillChangeFrameNotificationUsingBlock:(void (^)(NSNotification *note))block;
- (void) subscribeForKeyboardWillHideNotificationUsingBlock:(void (^)(NSNotification *note))block;

- (void) unsubscribeForKeyboardWillShowNotification;
- (void) unsubscribeForKeyboardWillChangeFrameNotification;
- (void) unsubscribeForKeyboardWillHideNotification;

#pragma mark - Titles
- (NSString *) loadingTitle;
- (NSString *) noItemsTitle;

#pragma mark - Adding Buttons

- (void) addSlideButtonItem;
- (void) addBackButton;

- (void) hideMenuBtn;
- (void) showMenuBtn;

- (void) hideView:(UIView *)view;
- (void) showView:(UIView *)view height:(int) height;

- (void) onBack:(id) sender;

- (void)runOnMainQueueWithoutDeadlocking:(CSVoidBlock)block;

#pragma mark - Keyboard Done Button

- (void) showKeyboardDoneButtonForTextView:(UITextView *) textView;

@end
