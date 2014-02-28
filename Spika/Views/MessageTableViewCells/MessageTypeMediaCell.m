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

#import "MessageTypeMediaCell.h"
#import "MessageTypeMediaCell+Style.h"
#import "Models.h"
#import "UserManager.h"

@interface MessageTypeMediaCell (){
    UIView *_mediaIconView;
}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) HUCounterBalloonView *counterView;
@end


@implementation MessageTypeMediaCell

#pragma mark - Dealloc

- (void)dealloc {
    
    [_containerView removeAllGestureRecognizers];
    
}

#pragma mark - Initialization

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _containerView = [self newContainerView];
        _label = [self newRightLabelView];
        _mediaIconView = [self newLeftImageView];
        
        [_containerView addSubview:_label];
        [_containerView addSubview:_mediaIconView];
        
        [_containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidTap:)]];
        
        [self.contentView addSubview:_containerView];
        
        [self initCounter];
    }
    
    return self;
}

- (void) initCounter {
    _counterView = [self newCommentCounterView];
    [_containerView addSubview:_counterView];
}

#pragma mark - View lifecycle

-(void) layoutSubviews {
    [super layoutSubviews];
    
    _containerView.frame = [MessageCell frameForContainerView:self.message];
    [self layoutTimestampLabelBelowView:_containerView];
    
    [self layoutDeleteTimerInCorner];
}

-(void) layoutDeleteTimerInCorner {
    
    CGFloat xDeletePos = self.isUserMessage ? _containerView.x : _containerView.x + _containerView.width;
    CGFloat yDeletePos = _containerView.y + _containerView.height - 5;
    
    self.deleteTimerButtonView.center = CGPointMake(xDeletePos, yDeletePos);
}


-(void) updateWithModel:(ModelMessage *)message {
    
    [super updateWithModel:message];
    
    _mediaIconView.frame = [MessageCell frameForLeftImageView:message];
    _label.frame = [MessageCell frameForRightLabelView:message];
    
    [self updateCounterWithModel:message];

    _label.text = [self textForRightContentView:message];
}


-(void) updateCounterWithModel:(ModelMessage *)message {
    [_counterView updateWithModel:message];
    
    BOOL isMine = [UserManager messageBelongsToUser:message];
    
    if(isMine)
        _counterView.frame = CGRectMake(40,
                                        -1 * [MessageTypeMediaCell extraSpaceAtTheTop],
                                        _counterView.width,
                                        _counterView.height);
    else
        _counterView.frame = CGRectMake(160,
                                        -1 * [MessageTypeMediaCell extraSpaceAtTheTop],
                                        _counterView.width,
                                        _counterView.height);
}

#pragma mark - Override

+(CGFloat) extraSpaceAtTheTop {
    return 10;
}

+(CGFloat) cellHeightForMessage:(ModelMessage *)message {
    CGFloat height = [MessageCell frameForContainerView:message].size.height;
    height += [MessageCell totalExtraHeight];
    
    return height;
}


+(BOOL) isArrowHidden {
    return NO;
}

+(BOOL) isTimestampHidden {
    return NO;
}

-(UIImage *) imageForLeftContentView:(ModelMessage *)message {
    NSAssert(NO, @"You have to override this method!");
    return nil;
}

-(NSString *) textForRightContentView:(ModelMessage *)message {
    NSAssert(NO, @"You have to override this method!");
    return nil;
}

-(void) handleDelegateCallback {
    NSAssert(NO, @"Override this method!");
}

#pragma mark - Selectors

-(void) tapGestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer {
    
    [super tapGestureRecognizerDidTap:tapRecognizer];
    
    if ([tapRecognizer.view isEqual:_containerView]) {
        [self handleDelegateCallback];
    }
    
}


#pragma mark - Notification selectors

#pragma mark - Setter

#pragma mark - Getter

#pragma mark - Delegate

@end
