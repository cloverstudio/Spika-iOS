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

#import "MessageTypeTextCell+Style.h"
#import "UserManager.h"

#define kMessageLabelWidth 160

@implementation MessageTypeTextCell (Style)

#pragma mark - Initialization

-(UITextView *) newMessageLabel {
    
    UITextView *label = [[UITextView alloc] initWithFrame:[MessageCell frameForMessageLabel:self.message]];
    label.font = kFontArialMTOfSize(kFontSizeSmall);
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor whiteColor];
    label.opaque = YES;
    label.dataDetectorTypes = UIDataDetectorTypeAll;
    label.editable = NO;
    
    return label;
}

#pragma mark - Frame

+ (CGRect) frameForMessageLabel:(ModelMessage *)message {
    
    CGSize messageBodySize = [message.body sizeForBoundingSize:CGSizeMake(kMessageLabelWidth, NSNotFound)
                                                          font:[MessageCell fontForMessageLabel]];
    messageBodySize.width = kMessageLabelWidth;
    
    CGRect avatarIconViewFrame = [MessageCell frameForAvatarIconView:message];
    CGRect arrowViewFrame = [MessageCell frameForArrowImageView:message];
    
    CGFloat height = MAX(messageBodySize.height * 1.3 + 15,CGRectGetHeight(avatarIconViewFrame));
    
    CGFloat x = [UserManager messageBelongsToUser:message] ? CGRectGetMinX(arrowViewFrame) - messageBodySize.width : CGRectGetMaxX(arrowViewFrame) ;
    
    return CGRectMake(x,
                      CGRectGetMinY(avatarIconViewFrame),
                      messageBodySize.width,
                      height);
}

#pragma mark - Font

+(UIFont *) fontForMessageLabel {
    return kFontArialMTOfSize(kFontSizeSmall);
}

@end
