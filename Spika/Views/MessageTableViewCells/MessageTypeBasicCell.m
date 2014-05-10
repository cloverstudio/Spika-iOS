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
    UIImageView *_unreadIconView;
}

#pragma mark - Dealloc 

-(void) dealloc {
    
    [_avatarIconView removeAllGestureRecognizers];
    [_deleteTimerButtonView removeAllGestureRecognizers];
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
        
        _unreadIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconUnread"]];
        [self.contentView addSubview:_unreadIconView];
        [_unreadIconView setHidden:YES];

        _deleteTimerButtonView = [[UIImageView alloc] init];
        _deleteTimerButtonView.image = [UIImage imageNamed:@"delete_timer"];
        _deleteTimerButtonView.userInteractionEnabled = YES;
        [_deleteTimerButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidTap:)]];
        [self.contentView addSubview:_deleteTimerButtonView];
        
        self.backgroundColor = [UIColor clearColor];
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
    
    _unreadIconView.frame = CGRectMake(_timestampLabel.x + _timestampLabel.width + 5, _timestampLabel.y + 8, 10, 8);
}

-(UILabel *) layoutTimestampLabelBelowView:(UIView *)view {
    
    self.contentView.height = self.height;
    
    CGFloat timestampWidth = _timestampLabel.width;
    _timestampLabel.frame = [MessageCell frameForInfoLabel:view.frame];
    _timestampLabel.width = timestampWidth;
    
    if (self.isUserMessage) {
        _timestampLabel.x = view.relativeWidth - _timestampLabel.width;
    }
    
    _unreadIconView.frame = CGRectMake(_timestampLabel.x + _timestampLabel.width + 5, _timestampLabel.y + 8, 10, 8);
    
    return _timestampLabel;
}

-(void) updateWithModel:(ModelMessage *)message {
        
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    
    _message = message;

    _isUserMessage = [UserManager messageBelongsToUser:message];
    _timestampLabel.text = [Utils generateMessageInfoText:message];
    
    if([user._id isEqualToString:message.from_user_id] && message.readAt == 0 && [message.message_target_type isEqualToString:@"user"]) {
        [_unreadIconView setHidden:NO];
    } else {
        [_unreadIconView setHidden:YES];
    }
    
    [self enableDeleteTimerIfNeeded];
}

#pragma mark - Override

+ (float) cellHeightForMessage:(ModelMessage *)message{
    
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

- (void) enableDeleteTimerIfNeeded {
    if (_message.deleteType > 0) {
        [_deleteTimerButtonView setFrame:CGRectMake(0, 0, 19, 22)];
        [self.contentView bringSubviewToFront:_deleteTimerButtonView];
        [_deleteTimerButtonView setHidden:NO];
    } else {
        [_deleteTimerButtonView setHidden:YES];
    }
}

- (void) layoutDeleteTimerInCorner {
    // override this in subclasses
}

#pragma mark - Selectors

-(void) tapGestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer {
        
    if ([tapRecognizer.view isEqual:_avatarIconView]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapAvatarImage:)]) {
            [self.delegate messageCell:self didTapAvatarImage:self.message];
        }
    }
    
    if ([tapRecognizer.view isEqual:_deleteTimerButtonView]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapDeleteTimer:)]) {
            [self.delegate messageCell:self didTapDeleteTimer:self.message];
        }
    }
}

-(void)willTransitionToState:(UITableViewCellStateMask)state{

    [super willTransitionToState:state];
    if((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask){
        [self recurseAndReplaceSubViewIfDeleteConfirmationControl:self.subviews];
        [self performSelector:@selector(recurseAndReplaceSubViewIfDeleteConfirmationControl:) withObject:self.subviews afterDelay:0];
    }
}
-(void)recurseAndReplaceSubViewIfDeleteConfirmationControl:(NSArray*)subviews{
    NSString *delete_button_name = @"delete";
    for (UIView *subview in subviews)
    {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationButton"])
        {
            UIButton *deleteButton = (UIButton *)subview;
            
            int y = [MessageCell frameForAvatarIconView:self.message].origin.y;
            
            [deleteButton setFrame:CGRectMake( 0, y, 82, 52)];
            [deleteButton setImage:[UIImage imageNamed:delete_button_name] forState:UIControlStateNormal];
            [deleteButton setTitle:@"" forState:UIControlStateNormal];
            [deleteButton setBackgroundColor:[UIColor clearColor]];
            for(UIView* view in subview.subviews){
                if([view isKindOfClass:[UILabel class]]){
                    [view removeFromSuperview];
                }
            }
        }
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"])
        {
            for(UIView* innerSubView in subview.subviews){
                if(![innerSubView isKindOfClass:[UIButton class]]){
                    [innerSubView removeFromSuperview];
                }
            }
        }
        if([subview.subviews count]>0){
            [self recurseAndReplaceSubViewIfDeleteConfirmationControl:subview.subviews];
        }
        
    }
}

@end
