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

#import "MessageTypeBasicCell.h"
#import "Models.h"
#import "UserManager.h"
#import "StyleManupulator.h"
#import "Utils.h"

#define kUIElementMargin     5
#define kArrowImageWidth    11
#define kArrowImageHeight   34
#define kIconImageViewHeight 52

@implementation MessageTypeBasicCell {
    UIImageView *_arrowImageView;
}

#pragma mark - Dealloc 

-(void) dealloc {
    
    [_avatarIconView removeAllGestureRecognizers];
    
}

#pragma mark - Initialization

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:[MessageCell frameForArrowImageView:nil]];
        _arrowImageView.image = [UIImage imageNamed:@"cell_arrow"];
        if (![MessageCell isArrowHidden]) {
            [self.contentView addSubview:_arrowImageView];
        }
        
        _avatarIconView = [[UIImageView alloc] initWithFrame:[MessageCell frameForAvatarIconView:nil]];
        _avatarIconView.backgroundColor = [UIColor clearColor];
		_avatarIconView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarIconView.userInteractionEnabled = YES;
        [_avatarIconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidTap:)]];
        if (![MessageCell isAvatarIconHidden]) {
            [self.contentView addSubview:_avatarIconView];
        }
        
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.numberOfLines = 2;
        _timestampLabel.textAlignment = NSTextAlignmentRight;
        [StyleManupulator attachTextMessageInfoLabel:_timestampLabel];
        if (![MessageCell isTimestampHidden]) {
            [self.contentView addSubview:_timestampLabel];
        }
        
        
    }
    
    return self;
}

#pragma mark - View lifecycle

-(void) layoutSubviews {
    
    _avatarIconView.frame = [MessageCell frameForAvatarIconView:self.message];
    
    _arrowImageView.frame = [MessageCell frameForArrowImageView:self.message];
    _arrowImageView.transform = self.isUserMessage ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity ;
    _timestampLabel.frame = [MessageCell frameForInfoLabel:CGRectMake(0, 0, 300, _avatarIconView.height)];
    [_timestampLabel sizeToFit];
}

-(UILabel *) layoutTimestampLabelBelowView:(UIView *)view {
    
    self.contentView.height = self.height;
    
    CGFloat timestampWidth = _timestampLabel.width;
    _timestampLabel.frame = [MessageCell frameForInfoLabel:view.frame];
    _timestampLabel.width = timestampWidth;
    
    if (self.isUserMessage) {
        _timestampLabel.x = view.relativeWidth - _timestampLabel.width;
    }
    
    return _timestampLabel;
}

-(void) updateWithModel:(ModelMessage *)message {
    
    _message = message;

    _isUserMessage = [UserManager messageBelongsToUser:message];
    _timestampLabel.text = [Utils generateMessageInfoText:message];
}

#pragma mark - Override

+ (CGFloat) cellHeightForMessage:(ModelMessage *)message{
    
    NSAssert(NO, @"You have to override this method!");
    return 0;
    
}

+ (BOOL) isArrowHidden {
    return YES;
}

+ (BOOL) isTimestampHidden {
    return NO;
}

+ (BOOL) isAvatarIconHidden {
    return NO;
}

+(CGFloat) heightForTimestampLabel {
    return 25;
}

+(CGFloat) extraSpaceAtTheBottom {
    return 10;
}

+(CGFloat) extraSpaceAtTheTop {
    return 0;
}

+(CGFloat) totalExtraHeight {
    CGFloat height = [MessageCell heightForTimestampLabel];
    height += [MessageCell extraSpaceAtTheTop];
    height += [MessageCell extraSpaceAtTheBottom];
    return height;
}

#pragma mark - Frames

+ (CGRect) frameForAvatarIconView:(ModelMessage *)message {
    
    CGFloat offset = 10;
    CGFloat x = [UserManager messageBelongsToUser:message] ? [CSKit frame].size.width - kIconImageViewHeight - offset : offset ;
    CGFloat y = [MessageCell extraSpaceAtTheTop] + 5;
    return CGRectMake(x, y, kIconImageViewHeight, kIconImageViewHeight);
}

+ (CGRect) frameForArrowImageView:(ModelMessage *)message {
    
    CGRect iconImageViewFrame = [MessageCell frameForAvatarIconView:message];
    
    CGFloat x = [UserManager messageBelongsToUser:message] ? CGRectGetMinX(iconImageViewFrame) - kArrowImageWidth - 5 : CGRectGetMaxX(iconImageViewFrame) + 5 ;
    
    return CGRectMake(x,
                      CGRectGetMidY(iconImageViewFrame) - kArrowImageHeight / 2,
                      kArrowImageWidth,
                      kArrowImageHeight);
}

+ (CGRect) frameForInfoLabel:(CGRect)viewFrame {
    
    return  CGRectMake(CGRectGetMinX(viewFrame),
                       CGRectGetMaxY(viewFrame),
                       viewFrame.size.width - kUIElementMargin * 2,
                       [[self class] heightForTimestampLabel]
                       );
    
    
}

#pragma mark - Selectors

-(void) tapGestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer {
    
    if ([tapRecognizer.view isEqual:_avatarIconView]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapAvatarImage:)]) {
            [self.delegate messageCell:self didTapAvatarImage:self.message];
        }
    }
}

@end
