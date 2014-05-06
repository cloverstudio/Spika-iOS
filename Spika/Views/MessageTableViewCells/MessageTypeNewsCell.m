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

#import "MessageTypeNewsCell.h"
#import "Models.h"
#import "Utils.h"

#define NewsLabelWidth 290
#define NewsButtonHeight 40

@implementation MessageTypeNewsCell{
    UILabel     *_messageLabel;
    UIView      *_container;
    UIButton    *_openURLButton;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _container = [[UIView alloc] init];
        _container.frame = CGRectMake(
            10,
            10,
            [Utils getDisplayWidth] - 20,
            100
        );
        
        _container.backgroundColor = kHUColorWhite;
        
        [self addSubview:_container];
        
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [MessageCell fontForMessageLabel];
        _messageLabel.textColor = [UIColor darkGrayColor];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.frame = CGRectMake(
            5,
            5,
            NewsLabelWidth,
            100
        );
        
        _openURLButton = [[UIButton alloc] init];
        
        _openURLButton.frame =  CGRectMake(
                                          10,
                                          _messageLabel.y + _messageLabel.height + 5,
                                          _container.width,
                                          NewsButtonHeight
        );
        
        _openURLButton.backgroundColor = kHUColorLightRed;
        [_openURLButton setTitle:NSLocalizedString(@"OpenWeb", nil) forState:UIControlStateNormal];
        _openURLButton.titleLabel.font = kFontArialMTBoldOfSize(kFontSizeMiddium);
        _openURLButton.titleLabel.textColor = kHUColorWhite;
        [_openURLButton addTarget:self action:@selector(openURL) forControlEvents:UIControlEventTouchDown];
        [_container addSubview:_messageLabel];
        [self addSubview:_openURLButton];
        
    }
    return self;
}

-(void) layoutSubviews {
    
    [super layoutSubviews];
    
 }

-(void) openURL{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.message.messageUrl]];
}
-(void) updateWithModel:(ModelMessage *)message {
    
    [super updateWithModel:message];
    
    _messageLabel.text = message.body;
    
    _messageLabel.frame = CGRectMake(
                                     5,
                                     5,
                                     NewsLabelWidth,
                                     [MessageCell calcLabelHeight:message]
                                     );
    
    _container.frame = CGRectMake(
                                  10,
                                  10,
                                  [Utils getDisplayWidth] - 20,
                                  _messageLabel.height + 5 
                                  );
    
    if(message.messageUrl != nil && message.messageUrl.length >0){
        _openURLButton.hidden = NO;
        _openURLButton.frame =  CGRectMake(
                                           10,
                                           _container.y + _container.height + 5,
                                           _container.width,
                                           NewsButtonHeight
                                           );
        
    }else{
        _openURLButton.hidden = YES;
    }
    
}

+ (BOOL) isArrowHidden {
    return YES;
}

+ (BOOL) isTimestampHidden {
    return YES;
}

+ (BOOL) isAvatarIconHidden {
    return YES;
}

+ (CGFloat) calcLabelHeight:(ModelMessage *)message {
    
    CGSize messageBodySize = [message.body sizeForBoundingSize:CGSizeMake(NewsLabelWidth, NSNotFound)
                                                          font:[MessageCell fontForMessageLabel]];
    messageBodySize.width = NewsLabelWidth;
    
    return messageBodySize.height;
    
}
+ (float) cellHeightForMessage:(ModelMessage *)message {
    
    CGFloat height = [MessageCell calcLabelHeight:message];
    
    //margin between text label and container
    height += 15;
    
    // bottom margin
    height += 10;
    
    if(message.messageUrl != nil && message.messageUrl.length >0){
        height += NewsButtonHeight;
        //margin between text label and button
        height += 10;
    }
    
    return height;
}

+(UIFont *) fontForMessageLabel {
    return kFontArialMTOfSize(kFontSizeMiddium);
}

@end
