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

#import "MessageTypeImageCell.h"
#import "StyleManupulator.h"
#import "MessageTypeImageCell+Style.h"

#import "UserManager.h"
#import "Utils.h"
#import "DatabaseManager.h"
#import "NSString+MD5.h"
#import "CSGraphics.h"


@interface MessageTypeImageCell ()

//@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) HUCounterBalloonView *counterView;

@end

@implementation MessageTypeImageCell

#pragma mark - Dealloc

- (void)dealloc {
    
//    [_photoView removeAllGestureRecognizers];
    [_anImageView removeAllGestureRecognizers];
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        BOOL isHidden = [MessageCell isImageContainerBackgroundColorHidden];
        
        _containerView = [self newContainerView];
        [_containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidTap:)]];
        if (isHidden) {
            _containerView.backgroundColor = [UIColor clearColor];
        }
        [self.contentView addSubview:_containerView];
        
        _anImageView = [[HUImageView alloc] initWithFrame:CGRectContract(_containerView.bounds, !isHidden ? 5 : 0)];
        _anImageView.userInteractionEnabled = YES;
        _anImageView.delegate = self;
        [_containerView addSubview:_anImageView];
        
//        _photoView = [[UIImageView alloc] initWithFrame:CGRectContract(_containerView.bounds, !isHidden ? 5 : 0)];
//        _photoView.userInteractionEnabled = YES;
//        [_containerView addSubview:_photoView];
        
        if ([MessageCell isCommentCounterHidden] == NO) {
            _counterView = [self newCommentCounterView];
//            _counterView.center = CGPointMake(_photoView.relativeWidth, _photoView.y);
            _counterView.center = CGPointMake(_anImageView.relativeWidth, _anImageView.y);
            [_containerView addSubview:_counterView];
        }
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void) layoutSubviews {
    
    [super layoutSubviews];
        
    _containerView.frame = [MessageCell frameForContainerView:self.message];
//    CGFloat x = self.isUserMessage ? _photoView.x : _photoView.relativeWidth;
//    _counterView.center = CGPointMake(x, _photoView.y);

    CGFloat x = self.isUserMessage ? _anImageView.x : _anImageView.relativeWidth;
    _counterView.center = CGPointMake(x, _anImageView.y);
    
    [self layoutTimestampLabelBelowView:_containerView];
    
    [self layoutDeleteTimerInCorner];
}

-(void) layoutDeleteTimerInCorner {
    
    CGFloat xDeletePos = self.isUserMessage ? _containerView.x + 5 : _containerView.x + _anImageView.relativeWidth;
    CGFloat yDeletePos = _containerView.y + _anImageView.relativeHeight;
    
    self.deleteTimerButtonView.center = CGPointMake(xDeletePos, yDeletePos);
}

-(void) updateWithModel:(ModelMessage *)message {
    
    [super updateWithModel:message];
    
    [_counterView updateWithModel:message];
    
    UIImage *image = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:[MessageCell imageUrlForMessage:message]]];
    
    if (image) {
        _anImageView.image = image;
        
    }else{
        
        _anImageView.image = nil;;
        
        [_anImageView startSpinnerAnimation];
        
        __weak MessageTypeImageCell *this = self;
        
        [[HUHTTPClient sharedClient] imageFromURL:[NSURL URLWithString:[MessageCell imageUrlForMessage:message]]
            completion:^(NSURL *imageURL, UIImage *image) {
                if(image)
                    [this downloadDone:[imageURL absoluteString] image:image];
        }];
    }

}

- (void) downloadDone:(NSString *)downloadDoneUrl image:(UIImage *)image{
    
    NSString *currentUrl = [MessageCell imageUrlForMessage:self.message];

    if([currentUrl isEqualToString:downloadDoneUrl]){
        _anImageView.image = image;        
    }else{
        [_anImageView startSpinnerAnimation];
    }
    
}

#pragma mark - Override

+(CGFloat) cellHeightForMessage:(ModelMessage *)message{
    
    CGFloat height = ImageWidth;
    height += [MessageCell totalExtraHeight];
    
    return height;
    
}

+ (BOOL) isArrowHidden {
    
    return NO;
}

+(CGFloat) extraSpaceAtTheTop {
    
    return 8;
}

+(BOOL) isImageContainerBackgroundColorHidden {
    
    return NO;
}

+(BOOL) isCommentCounterHidden {
    
    return NO;
}

+(NSString *) imageUrlForMessage:(ModelMessage *)message {
    
    return message.imageThumbUrl;
}


-(void) tapGestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer {
    
    [super tapGestureRecognizerDidTap:tapRecognizer];
    
    if ([tapRecognizer.view isEqual:_containerView]) {
        if ([self.delegate respondsToSelector:@selector(messageImageCell:didTapPhotoView:)]) {
            NSString *classString = NSStringFromClass([self class]);
            NSString *allowedClassString = NSStringFromClass([MessageTypeImageCell class]);
            if ([classString compare:allowedClassString] == NSOrderedSame) {
                [self.delegate messageImageCell:self didTapPhotoView:self.message];
            }
        }
    }
    
}

@end
