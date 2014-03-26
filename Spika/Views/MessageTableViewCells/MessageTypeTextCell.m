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

#import "MessageTypeTextCell.h"
#import "StyleManupulator.h"
#import "UserManager.h"
#import "StdTextView.h"
#import "Utils.h"
#import "MessageTypeTextCell+Style.h"

#import "UIImage+NoCache.h"

@interface MessageTypeTextCell () {
    UITextView     *_messageLabel;
}

@end

@implementation MessageTypeTextCell

#pragma mark - Initialization

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _messageLabel = [self newMessageLabel];
        [self.contentView addSubview:_messageLabel];
                
    }
    
    return self;
}

#pragma mark - View lifecycle

-(void) updateWithModel:(ModelMessage *)message {
    
    [super updateWithModel:message];
    
    _messageLabel.text = message.body;
    
    [self layoutIfNeeded];
}

#pragma mark - Override

- (void) layoutSubviews {

    [super layoutSubviews];
    
    _messageLabel.frame = [MessageCell frameForMessageLabel:self.message];
    [self layoutTimestampLabelBelowView:_messageLabel];
    
    [self layoutDeleteTimerInCorner];
}

-(void) layoutDeleteTimerInCorner {
        
    CGFloat xDeletePos = self.isUserMessage ? _messageLabel.x : _messageLabel.x + _messageLabel.width;
    CGFloat yDeletePos = _messageLabel.y + _messageLabel.relativeHeight - 10;
    
    self.deleteTimerButtonView.center = CGPointMake(xDeletePos, yDeletePos);
}


+ (BOOL) isArrowHidden {
    
    return NO;
}

+ (CGFloat) cellHeightForMessage:(ModelMessage *)message {
    
    CGFloat height = CGRectGetHeight([MessageCell frameForMessageLabel:message]);
    height += [MessageCell totalExtraHeight];
    
    return height;
}

@end
