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

#import "ImageMessageCommentRow.h"
#import "StyleManupulator.h"
#import "UserManager.h"
#import "Utils.h"
#import "Models.h"

#define UIElementMargin 5
#define MessageHolderWidth 250
#define InfoLabelHeight 25


@implementation ImageMessageCommentRow

+(float) calcCellHeight:(NSString *)comment {
    
    CGRect textMessageLabelRect = CGRectMake(
                                             UIElementMargin,
                                             UIElementMargin,
                                             MessageHolderWidth - UIElementMargin * 2,
                                             300
                                             );
    
    CGSize labelSize = [comment sizeForBoundingSize:textMessageLabelRect.size
                                               font:MessageBodyFont];
    
    CGFloat labelHeight = labelSize.height;
    
    return labelHeight + UIElementMargin * 6 + InfoLabelHeight;
}


- (id)initWithComment:(ModelComment *)comment {
    
    if (self = [super init]) {
        
        NSString *userName = comment.user_name;
        NSString *userId = comment.user_id;
        NSString *postedComment = comment.comment;
        
        long created = comment.created;
        
        
        _viewMessageHolder = [[UIView alloc] init];
        [StyleManupulator attachTextMessageHolderBG:_viewMessageHolder];
        
        _labelMessage = [[UILabel alloc] init];
        [StyleManupulator attachTextMessageLabel:_labelMessage];
        
        _labelInfo = [[UILabel alloc] init];
        _labelInfo.numberOfLines = 1;
        [StyleManupulator attachTextMessageInfoLabel:_labelInfo];
        
        [self addSubview:_viewMessageHolder];
        [_viewMessageHolder addSubview:_labelMessage];
        [self addSubview:_labelInfo];
        

        BOOL isMyMessage = NO;
        ModelUser *loginedUser = [[UserManager defaultManager] getLoginedUser];
        
        if([loginedUser._id isEqualToString:userId]){
            isMyMessage = YES;
        }
        
        
        CGRect holderRect = CGRectMake(
                                       UIElementMargin,
                                       UIElementMargin,
                                       MessageHolderWidth,
                                       [ImageMessageCommentRow calcCellHeight:postedComment] - InfoLabelHeight
                                       );
        
        if(isMyMessage){
            holderRect = CGRectMake(
                                    [Utils getDisplayWidth] - UIElementMargin - MessageHolderWidth,
                                    UIElementMargin,
                                    MessageHolderWidth,
                                    [ImageMessageCommentRow calcCellHeight:postedComment] - UIElementMargin * 4 - InfoLabelHeight
                                    );
        }
        
        _viewMessageHolder.frame = holderRect;
        
        
        CGRect textMessageLabelRect = CGRectMake(
                                                 UIElementMargin,
                                                 UIElementMargin,
                                                 holderRect.size.width - UIElementMargin * 2,
                                                 holderRect.size.height - UIElementMargin * 2
                                                 );
        
        _labelMessage.frame = textMessageLabelRect;
        
        
        _labelMessage.text = postedComment;
        _labelMessage.numberOfLines = 0;
        [_labelMessage sizeToFit];
        
        
        CGRect infoLabelRect = CGRectMake(
                                          holderRect.origin.x,
                                          holderRect.size.height + UIElementMargin + 3,
                                          holderRect.size.width,
                                          InfoLabelHeight
                                          );
        
        
        _labelInfo.frame = infoLabelRect;
        _labelInfo.text = [Utils generateMessageInfoTextWithCreated:created withName:userName withId:userId];
        
        if(isMyMessage){
            _labelInfo.textAlignment = NSTextAlignmentRight;
        }

        
    }
    return self;
}


@end
