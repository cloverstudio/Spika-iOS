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

#import "HUGroupsCategoryTableViewCell+Style.h"

#define kBackgroundViewWidth    264

@implementation HUGroupsCategoryTableViewCell (Style)

#pragma mark - UIView

- (UIView *) aBackgroundView {
    
    UIView *view = [CSKit viewWithFrame:[HUGroupsCategoryTableViewCell frameForBackgroundView]];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

#pragma mark - UIImageView

- (UIImageView *) anAvatarImageView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[HUGroupsCategoryTableViewCell frameForAvatarImageView]];
    imageView.backgroundColor = [UIColor clearColor];
    
    return imageView;
}

#pragma mark - UILabel
- (UILabel *) groupNameLabel {
    
    UILabel *label = [CSKit labelWithFrame:[HUGroupsCategoryTableViewCell frameForGroupNameLabel]
                                      font:[HUGroupsCategoryTableViewCell fontForGroupNameLabel]
                                 textColor:[self textColorForGroupNameLabel]
                             textAlignment:NSTextAlignmentLeft
                                      text:nil];
    label.numberOfLines = 0;
    
    return label;
}


#pragma mark - Frames

+ (CGRect) frameForBackgroundView{
    
    return CGRectMake(6, 0, 314, 75);
}

+ (CGRect) frameForAvatarImageView {
    
	CGRect backViewFrame = [self frameForBackgroundView];
    CGFloat height = backViewFrame.size.height - 5;
    return CGRectMake(backViewFrame.origin.x + 2.5f, backViewFrame.origin.y + 2.5f, height, height);
    
}

+ (CGRect) frameForGroupNameLabel{
    
    CGRect avatarImageFrame = [self frameForAvatarImageView];
    return CGRectMake(CGRectGetMaxX(avatarImageFrame) + 10,
                      CGRectGetMinY(avatarImageFrame),
                      200, CGRectGetHeight(avatarImageFrame));
    
}

+ (CGRect) frameForFavouriteButton {
    
    return CGRectMake(kBackgroundViewWidth-35, 15, 31, 26);
}

-(CGRect) frameForFavoriteIcon {
    return CGRectMake(250, 55, 16.5, 14.5);
}

-(CGRect) frameForMessageOffIcon {
    return CGRectMake(290, 55, 16, 14.5);
}

-(CGRect) frameForMessageOnIcon {
    return CGRectMake(290, 48, 16, 22);
}


#pragma mark - Colors

- (UIColor *) textColorForGroupNameLabel {
    
    return [UIColor blackColor];
}

#pragma mark - Fonts

+ (UIFont *) fontForGroupNameLabel {
    
    return kFontArialMTOfSize(kFontSizeMiddium);
}


@end
