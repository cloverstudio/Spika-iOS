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

#import <Foundation/Foundation.h>

@class ModelUser;

@protocol HUPushNotificationTarget;

@interface HUPushNotificationModel : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) id<HUPushNotificationTarget> target;

#pragma mark - Initialization

-(id) initWithUserInfo:(NSDictionary *)userInfo;

+(id) pushNotificationWithUserInfo:(NSDictionary *)userInfo target:(id<HUPushNotificationTarget>)target;

#pragma mark - Convenience method

-(void) push;
-(void) remove;

#pragma mark - Construction

-(UIView *) loadView:(CGRect)rect;

#pragma mark - Selector

-(void) pushNotificationDidTap:(UITapGestureRecognizer *)recognizer;

#pragma mark - Datasource

-(BOOL) hasCancelButton;

//if time interval == 0, then the notification won't hide
-(CGFloat) hidesAfterTimeInterval;

@end

@protocol HUPushNotificationTarget <NSObject>
-(NSString *) targetId;
-(NSString *) titleTextForUserInfo:(NSDictionary *)userInfo;
-(NSString *) bodyTextForUserInfo:(NSDictionary *)userInfo;
-(void) pushNotificationDidPress:(UITapGestureRecognizer *)recognizer;
@end