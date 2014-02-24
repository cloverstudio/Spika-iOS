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

#import "HUDefaultMessageNotification.h"
#import "NSDictionary+KeyPath.h"
#import "HUImageView.h"
#import "CSGraphics.h"
#import "UILabel+Extensions.h"
#import "HUCachedImageLoader.h"

@implementation HUDefaultMessageNotification

-(UIView *) loadView:(CGRect)rect {
    
    UIView *contentView = [super loadView:rect];
    contentView.height = 60;
    
    UIView *colorView = [[UIView alloc] initWithFrame:contentView.bounds];
    colorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.81f];
    [contentView addSubview:colorView];
    
    HUImageView *avatarIconView = [[HUImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    avatarIconView.image = [UIImage imageNamed:@"user_stub"];
    [contentView addSubview:avatarIconView];
    
    NSString *titleText = [self.target titleTextForUserInfo:self.userInfo];
    
    UILabel *titleLabel = [UILabel labelWithText:[titleText uppercaseString] font:kFontArialMTBoldOfSize(kFontSizeMiddium)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.center = CGPointShiftUp(avatarIconView.center, 10);
    titleLabel.x = avatarIconView.relativeWidth + 5;
    [contentView addSubview:titleLabel];
    
    NSString *message = [self.target bodyTextForUserInfo:self.userInfo];
    
    UILabel *messageLabel = [UILabel labelWithText:message];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.center = CGPointShiftDown(avatarIconView.center, 10);
    messageLabel.x = avatarIconView.relativeWidth + 5;
    [contentView addSubview:messageLabel];
    
    NSString *userId = [self.target targetId];
    [HUCachedImageLoader thumbnailFromUserId:userId completionHandler:^(UIImage *image) {
        if(image)
            avatarIconView.image = image;
    }];

    
    return contentView;
    
}

-(void) pushNotificationDidTap:(UITapGestureRecognizer *)recognizer {
    
    [self.target pushNotificationDidPress:recognizer];
    
    [self remove];
}

-(CGFloat) hidesAfterTimeInterval {
	return 2.0f;
}

#pragma mark -

-(NSString *)titleTextForModel:(id<HUPushNotificationTarget>)model
{
	return @"";
}

-(NSString *)bodyTextForUserInfo:(NSDictionary *)userInfo
{
	return @"";
}

-(NSString *)userIdForModel:(id<HUPushNotificationTarget>)model
{
	return @"";
}

@end
