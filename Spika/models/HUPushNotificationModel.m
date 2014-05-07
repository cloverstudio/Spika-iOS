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

#import "HUPushNotificationModel.h"
#import "HUPushNotificationModel+Style.h"
#import "HUPushNotificationManager.h"
#import "CSGraphics.h"

@implementation HUPushNotificationModel

#pragma mark - Dealloc

#pragma mark - Initialization

-(id) initWithUserInfo:(NSDictionary *)userInfo {
    
    if (self = [super init]) {
        
        self.userInfo = userInfo;
    }
    
    return self;
}

+(id) pushNotificationWithUserInfo:(NSDictionary *)userInfo target:(id<HUPushNotificationTarget>)target {
    
    HUPushNotificationModel *model = [[self alloc] initWithUserInfo:userInfo];
    model.target = target;
    return model;
}

#pragma mark - Convenience method

-(void) push {
    
    [[HUPushNotificationManager defaultManager] addPushNotification:self];
}

-(void) remove {
    
    [[HUPushNotificationManager defaultManager] removePushNotification:self];
}

#pragma mark - Construction

-(UIView *) loadView:(CGRect)rect {
    
    UIView *contentView = [[UIView alloc] initWithFrame:rect];

    UIView *touchView = [[UIView alloc] initWithFrame:contentView.bounds];
    [touchView addTapGestureRecognizerWithTarget:self selector:@selector(pushNotificationDidTap:)];
    [contentView addSubview:touchView];
    
    UIButton *button = nil;
    if (self.hasCancelButton) {
        
        button = [self newCancelButtonWithSelector:@selector(closeButtonDidTouchInsideOut:)];
        button.position = CGPointMake(rect.size.width - button.width - 10, 10);
        [contentView addSubview:button];
        
    }
    
    //bring to front after all views from subclasses are done initializing
    dispatch_async(dispatch_get_main_queue(), ^{
        [contentView bringSubviewToFront:touchView];
        if (button) {
            [contentView bringSubviewToFront:button];
        }
    });
    
    return contentView;
}

#pragma mark - Selector

-(void) pushNotificationDidTap:(UITapGestureRecognizer *)recognizer {
    
}

-(void) closeButtonDidTouchInsideOut:(UIButton *)button {
    [self remove];
}

#pragma mark - Datasource

-(BOOL) hasCancelButton {
    return YES;
}

-(CGFloat) hidesAfterTimeInterval {
	return 0.0f;
}

@end
