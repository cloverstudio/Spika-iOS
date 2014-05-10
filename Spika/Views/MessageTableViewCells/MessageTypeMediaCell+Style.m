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

#import "MessageTypeMediaCell+Style.h"
#import "MAKVONotificationCenter.h"
#import "HPDefaultExtensions.h"
#import "UserManager.h"
#import "Utils.h"

#define kLeftContainerWidth     52
#define kRightContainerWidth    170
#define kSpaceBetweenContainers 2

@implementation MessageTypeMediaCell (Style)


-(HUCounterBalloonView *) newCommentCounterView {
    
    HUCounterBalloonView *counterView = [[HUCounterBalloonView alloc] initWithImage:[UIImage imageNamed:@"comment_number_ballon"]];
    counterView.textColor = [UIColor whiteColor];
    
    return counterView;
}



-(UIView *) newContainerView {
    
    UIView *containerView = [[UIView alloc] initWithFrame:[MessageCell frameForContainerView:self.message]];
    
    return containerView;
}

-(UIView *) newLeftImageView{
    
    UIView *leftView = [[UIView alloc] initWithFrame:[MessageCell frameForLeftImageView:nil]];
    leftView.backgroundColor = [MessageCell defaultBackgroundColor];
    leftView.opaque = YES;
    
    UIImageView *imageView = [CSKit imageViewWithImage:[self imageForLeftContentView:nil] highlightedImage:nil];
    imageView.center = CGRectGetCenter(leftView.bounds);
    [leftView addSubview:imageView];
    
    return leftView;
    
}

+(CGRect) frameForLeftImageView:(ModelMessage *)message {
    
    BOOL isMyMessage = [UserManager messageBelongsToUser:message];
    
    if(isMyMessage)
        return CGRectMake(0, 0, kLeftContainerWidth, kLeftContainerWidth);
    else
        return CGRectMake(kRightContainerWidth + kSpaceBetweenContainers, 0, kLeftContainerWidth, kLeftContainerWidth);
}

-(UITextView *) newRightLabelView {
    
    
    UITextView *rightView = [[UITextView alloc] initWithFrame:[MessageCell frameForRightLabelView:nil]];
    rightView.backgroundColor = [MessageCell defaultBackgroundColor];
    rightView.textColor = [UIColor darkGrayColor];
    rightView.textAlignment = NSTextAlignmentLeft;
    rightView.opaque = YES;
    rightView.font = kFontArialMTOfSize(kFontSizeSmall);
    rightView.editable = NO;
    
    return rightView;
    
}

+(CGRect) frameForRightLabelView:(ModelMessage *)message {
    
    BOOL isMyMessage = [UserManager messageBelongsToUser:message];
    
    CGRect frame = [MessageCell getFrameForContainerView:message leftFrame:nil rightFrame:nil];
    
    if(isMyMessage)
        return CGRectMake(kLeftContainerWidth + kSpaceBetweenContainers , 0, kRightContainerWidth,  frame.size.height);
    else
        return CGRectMake(0 , 0, kRightContainerWidth, frame.size.height);
    
}

+(UIColor *) defaultBackgroundColor {
    return [UIColor whiteColor];
}

+(CGRect) frameForContainerView:(ModelMessage *)message {
    
    CGRect rect = [MessageCell getFrameForContainerView:message leftFrame:nil rightFrame:nil];
    
    return rect;
    
    /*
    return CGRectMake(
        rect.origin.x,
        rect.origin.y - [MessageTypeMediaCell extraSpaceAtTheTop],
        rect.size.width,
        rect.size.height
    );
    */
    
}

+(CGRect) getFrameForContainerView:(ModelMessage *)message leftFrame:(CGRect *)leftFrame rightFrame:(CGRect *)rightFrame {

    CGSize messageBodySize = [message.body sizeForBoundingSize:CGSizeMake(kLeftContainerWidth, NSNotFound)
                                                          font:kFontArialMTOfSize(kFontSizeSmall)];
    
    CGRect avatarIconFrame = [MessageCell frameForAvatarIconView:message];
    CGRect arrowFrame = [MessageCell frameForArrowImageView:message];
    
    CGFloat containerWidth = kLeftContainerWidth + kRightContainerWidth + kSpaceBetweenContainers;
    
    CGFloat x = [UserManager messageBelongsToUser:message] ? CGRectGetMinX(arrowFrame) -  containerWidth : CGRectGetMaxX(arrowFrame) ;
    CGFloat height = MAX(messageBodySize.height + 15,CGRectGetHeight(avatarIconFrame));

    //CGFloat x = [Utils getDisplayWidth] - 10;
    
    CGRect containerFrame = CGRectMake(x,
                                       CGRectGetMinY(avatarIconFrame),
                                       containerWidth,
                                       height);
    
    return containerFrame;
    
}


@end
